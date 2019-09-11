

clear all
close all
clc
                                                                  
saveres=0;
ba=1; 
period=1;
                                                                          
%%
if period==1
    time_vec=200:600;                                                                            

else
    time_vec=500:900;
end


ccond=[1,3];                                                                  % conditions correct non-match and correct match

namep={'target','test'};
namea={'V1','V4'};
ending={'_all','_lay'};

variables={'spikes_tar','spikes_test';'spikes_tarV4_lay','spikes_testV4_lay'};

%% get spike counts for the SVM and spike trains for testing with leave-one-out 


dname=['/home/veronika/v1v4/data/',namea{ba},ending{ba},'/'];

addpath(dname)
fname=dir([dname filesep '*.mat']);
nbses=length(fname);

cvar=variables{ba,period};

task=['compute weights in ', namea{ba}, ' during ',namep{period}];
display(task)

dt=1/1000;

fr_nm=[];
fr_m=[];
J_all=zeros(nbses,2);

for sess=1:length(fname)                                                               % loop across sessions
    
    s=load([dname filesep fname(sess).name],cvar);                                      % load spike trains
    
    
    x=s.(cvar)(ccond,:);                                                                % take 2 conditions
    x_col=cellfun(@(x,y,z) cat(2,x,y,z),x(:,1),x(:,2),x(:,3),'UniformOutput',false);    % concatenate layers
    
    %% get spike counts for training and spike trains for testing with monte-carlo cv
    
    N=size(x_col{1},2);
    J=cellfun(@(x) size(x,1),x_col);                                                   % number of trials
    x_time=cellfun(@(x) x(:,:,time_vec),x_col,'UniformOutput',false);
    x_perm=cellfun(@(x) x(randperm(size(x,1)),:,:),x_time, 'UniformOutput',false);                            % permute the order of trials
    x_cut=cellfun(@(x) x(1:min(J),:,:), x_perm, 'UniformOutput',false);                                   % take same number of trials
    
    x_count=cellfun(@(x) squeeze(mean(x,3)), x_cut, 'UniformOutput',false);                                   % spike count
    x_std=cellfun(@(x) std(x), x_count, 'UniformOutput',false);
    x_mean=cellfun(@(x) mean(x)./dt, x_count, 'UniformOutput',false);
    
    %CV=cellfun(@(x,y) y./x, x_mean, x_std,  'UniformOutput',false);
    J_all(sess,:)=J;
    
    
    %% collect across sessions
    
    
    fr_nm=cat(2, fr_nm, x_mean{1});
    fr_m=cat(2, fr_m, x_mean{2});
    
end

%% save result

if saveres==1
    savename=['frate_',namea{ba},'_', namep{period}];
    savefile='/home/veronika/reconstruction/result/general/frate/';
    save([savefile,savename],'fr_nm','fr_m')
end

%%

figure('visible','off')
plot(fr_nm)
hold on
plot(fr_m)

disp('mean nb trials')
disp(mean(J_all))

%%
