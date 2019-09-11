% compute feature weights of the linear SVM in sessions
% PERMUTED LABELS S
% use pre-computed data for monte-carlo cross-validation 



clear all
close all
clc
  
format short

place=1;
saveres=0;                                                               

ba=1;
period=3;
quarter=1;

nperm=1000;

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

task=['compute weights in ', namea{ba}, ' during ',namep{period},', monte-carlo cross-val'];
disp(task)

%% compute weights of the linear SVM with monte-carlo cv

tic
                                                                                
loadname=['input_mc_',namea{ba},'_',namep{period}];
load(loadname,'count_mc')

nbses=length(count_mc);
ncv=size(count_mc{1},1);
      
w_all=cell(nbses,1);
for sess=1%:nbses                                                                          
    
    disp(sess)
    sc_all=count_mc{sess};
    N=size(sc_all{1},2);
    J=cellfun(@(x) size(x,1),sc_all(1,:));
    
    label_correct=cat(1,ones(J(1),1),ones(J(2),1).*(-1));
    weight_perm=zeros(nperm,ncv,N,'single');
    
    for perm=1:nperm
        
        label=label_correct(randperm(sum(J)));
        for cv=1:ncv
            
            count=sc_all(cv,:)';
            weight = compute_svmw_fun(count,nfold,Cvec,label);
            weight_perm(perm,cv,:)=weight;
        end      
    end
    
    w_all{sess}=weight_perm;
   
end

toc
%% save result 
if saveres==1
    
    savename=['weight_perm_',namea{ba},'_',namep{period},'_quarter', sprintf('%1.0i',quarter)];
    if place==1
        savefile='/home/veronika/v1v4/reconstruction/result/weights/w_perm/';
    else
        savefile='/home/veronika/reconstruction/result/weights/w_perm/';
    end
    save([savefile,savename],'w_all')
    
end
 
%clear all


        
      
        

   

