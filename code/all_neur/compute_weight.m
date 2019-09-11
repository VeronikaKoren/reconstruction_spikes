% compute feature weights of the linear SVM in sessions
% use pre-computed data for monte-carlo cross-validation 
% REGULAR MODEL

clear all
close all
clc
  
place=1;
saveres=1;

%%                                                                          

namep={'target','delay','test'};
namea={'V1','V4'};

nfold=5;                                                                           % number of folds for the cross-validation (search of the best regularization param.)
Cvec=[0.0012,0.0015,0.002,0.005,0.01,0.05,0.1,0.5];

if place==1
    addpath('/home/veronika/Dropbox/reconstruction/code/functions/');
    addpath('/home/veronika/v1v4/reconstruction/result/input/');
else
    addpath('/home/veronika/reconstruction/functions/');
    addpath('/home/veronika/reconstruction/result/input/');
end

%% compute weights of the linear SVM with monte-carlo cv

tic

for ba=2                                                                                            % [V1, V4]      
    for period=1:3                                                                                    % [target, delay, test]
        
        loadname=['input_mc_',namea{ba},'_',namep{period}];
        load(loadname,'count_mc')
        task=['compute weights in ', namea{ba}, ' during ',namep{period},', monte-carlo cross-val'];
        disp(task)
        
        nbses=length(count_mc);
        ncv=size(count_mc{1},1);
        
        w_all=cell(nbses,1);
        for sess=1:nbses                                                                           % [sessions]
            
            disp(sess)
            sc_all=count_mc{sess};
            N=size(sc_all{1},2);
            J=cellfun(@(x) size(x,1),sc_all(1,:));
            label=cat(1,ones(J(1),1),ones(J(2),1).*(-1));
            
            weight_cv=zeros(ncv,N);
            for cv=1:ncv                                                                       	   % [cross-validation for splits into training and testing]
                
                count=sc_all(cv,:)';
                [weight] = compute_svmw_fun(count,nfold,Cvec,label);
                weight_cv(cv,:)=weight;
            end
            
            w_all{sess}=weight_cv;                                                                  % collect across sessions
        end
    
        %% save result
        
        if saveres==1  
            savename=['weight_',namea{ba},'_',namep{period}];
            if place==1
                savefile='/home/veronika/v1v4/reconstruction/result/weights/w_mc/';
            else
                savefile='/home/veronika/reconstruction/result/weights/w_mc/';
            end 
            save([savefile,savename],'w_all')
        end
        
        
    end
end

toc


