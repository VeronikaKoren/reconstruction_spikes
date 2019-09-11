% compute feature weights of the linear SVM in sessions
% use half of the data for determining weights, save other half for
% reconstruction

clear all
close all
clc
                                                                  
saveres=0;
                                                                              % 0 do not permute, 1~random assignment of the class label 
%%
                                                                              % ratio nb of trials for training vs. reconstruction
starting_time=[200,500];
K=400;
ccond=[1,3];                                                                  % conditions correct non-match and correct match

namep={'target','test'};
namea={'V1','V4'};
ending={'_all','_lay'};

variables={'spikes_tar','spikes_test';'spikes_tarV4_lay','spikes_testV4_lay'};

ratio=0.5;                                                                   % ration nb trials for target and for test
ncv=100;

%% get spike counts for the SVM and spike trains for testing with leave-one-out 

for ba=1:2                                                                    % [V1, V4]      
    for period=1:2                                                            % [target, test]
        
        start=starting_time(period);
        dname=['/home/veronika/v1v4/data/',namea{ba},ending{ba},'/'];
        
        addpath(dname)
        fname=dir([dname filesep '*.mat']);
        nbses=length(fname);
        
        if period==1
            epoch=1;                                                                
        else
            epoch=2;
        end
        cvar=variables{ba,epoch};
        
        task=['compute weights in ', namea{ba}, ' during ',namep{period}];
        display(task)
        
        count_mc=cell(nbses,1);
        session_names=cell(nbses,1);
        spikes_mc=cell(nbses,1);
        label_all=cell(nbses,1);
        
        for sess=1:length(fname)                                                               % loop across sessions   
            
            s=load([dname filesep fname(sess).name],cvar);                                      % load spike trains  
            
            sess_name=fname(sess).name(7:end-7);                                                % get the session name
            disp(sess)
            
            x=s.(cvar)(ccond,:);                                                                % take 2 conditions
            x_col=cellfun(@(x,y,z) cat(2,x,y,z),x(:,1),x(:,2),x(:,3),'UniformOutput',false);    % concatenate layers
            
            %% get spike counts for training and spike trains for testing with monte-carlo cv
            
            N=size(x_col{1},2);                                                                           
            J=cellfun(@(x) size(x,1),x_col,'UniformOutput',false);                                                   % number of trials
            idxcut=cellfun(@(x) round(x/2),J, 'UniformOutput',false);                                                % index for dividing the data into training and testing
            x_time=cellfun(@(x) x(:,:,start:start+K-1),x_col,'UniformOutput',false);                                 % take the time window
            
            count_train=cell(ncv,2);
            x_validate=cell(ncv,2);
            
            for cv=1:ncv
                
                x_perm=cellfun(@(x) x(randperm(size(x,1)),:,:),x_time,'UniformOutput',false);                         % permute the order of trials within each condition
                count_train(cv,:)=cellfun(@(x,y) single(squeeze(sum(x(1:y,:,:),3))),x_perm,idxcut,'UniformOutput',false);     % use half of the trials, compuute spike counts  
                x_validate(cv,:)=cellfun(@(x,y) int8(x(y+1:end,:,:)),x_perm,idxcut,'UniformOutput',false);                  % use other half of the trials and remember spikes
            
            end
                
            %% collect across sessions
            
            count_mc{sess}=count_train;
            session_names{sess}=sess_name;
            spikes_mc{sess}=x_validate;
            
        end
        
        %% save result
        
        if saveres==1
            savename=['input_mc_',namea{ba},'_', namep{period}];
            savefile='/home/veronika/v1v4/reconstruction/result/input/';
            save([savefile,savename],'session_names','count_mc','spikes_mc') 
        end
        
    end
end
