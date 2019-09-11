% computes the area under the ROC curve (auc score) of single neurons 
% uses difference of spike counts sc_test-sc_target in all 3 pairs of conditions 
% computes the regular auc score (1 per neuron) and the auc score  with permuted class labels (nperm auc scores for each single neuron) 

close all
clear all
clc
format long

saveres=1;                                                                     % save result?

ba=1;                                                                          % brain area; 1 for V1 and 2 for V4
period=2;

nperm=1000;                                                                    % number of permutation of class labels

%%

namea={'V1','V4'};
namep={'target','test'};

if place==1
    addpath('/home/veronika/Dropbox/reconstruction/code/functions/')
else
    addpath('/home/veronika/reconstruction/code/functions/')
end
addpath('/home/veronika/reconstruction/result/input/')

loadname=['input_mc_',namea{ba},'_', namep{period},'.mat'];                                            % load difference of spike counts
load(loadname,'count_mc');
%%

xvec=linspace(0,160,200);                                                % support for the probability distribution (used for computing the area under the ROC curve)
ncv=size(count_mc{1},1);
%% compute area under the curve for difference of spike counts

nbses=length(count_mc);
auc=cell(nbses,1);
auc_perm=cell(nbses,1);

tic
disp(['computing auc score in ', namea{ba},' ', namep{period} ' with cross-validation'])

                                                                     
for sess=1:nbses                                                            % across recording sessions
  
    sc_all=count_mc{sess};
    N=size(sc_all{1},2);
    J=cellfun(@(x) size(x,1),sc_all(1,:));
    
    auc_cv=zeros(ncv,N);
    auc_p=zeros(nperm,ncv,N,'single');
    
    for cv=1:ncv                                                                       	   % [cross-validation for splits into training and testing]
        
        count=sc_all(cv,:)';
        a=zeros(N,1);
        a_perm=zeros(N,nperm);
        for i=1:N                                                              % across cells in a session
            
            data1=sc_all{cv,1}(:,i);                                           % spike counts condition 1
            data2=sc_all{cv,2}(:,i);                                           % condition 2
            
            [auc_score, bw] = get_auc(data1,data2,xvec);                       % computes the area under the ROC curve
            a(i)=auc_score-0.5;                                                %% center around zero and collect across neurons
            
            [aucp]= get_auc_permuted( data1,data2, xvec,bw,nperm );            % auc with permutation of labels
            a_perm(i,:)=aucp-0.5;                                              %% center around zero and collect across neurons
        end
                                                                     
        auc_cv(cv,:)=a./sqrt(sum(a.^2));                                     % normalize with L2 norm (to be comparable to weights of the SVM)
        auc_p(:,cv,:)=(a_perm./(repmat(sqrt(sum(a_perm.^2)),N,1)))';
        
    end
    
             
    auc{sess}=auc_cv;
    auc_perm{sess}=auc_p;
        
end
    

toc


if saveres==1
    address='/home/veronika/reconstruction/result/weights/univariate/';
    filename=['wauc_',namea{ba},namep{period}];
    save([address, filename],'auc','auc_perm')
end
