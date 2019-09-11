% reconstruct regular with different time constants

clear all 
close all
clc

saveres=0;

ba=2;
tau_prime=20;                                                                           % choose between [10,20,50]

%%

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namet={'regular','binary'};

task=['compute signal univariate all neurons (lambda)^-1 = ', sprintf('%1.0i',tau_prime)];
display(task)
                                                                                      % exponential kernel for convolution
L=100;                                                                                % length of the kernel                                  
tau=0:L;                                                                              % support
lambda=1/tau_prime;                                                                   % time constant
kernel=exp(-lambda.*tau); 

period=2;

%% load weights and spikes

addpath('/home/veronika/Dropbox/reconstruction/code/functions/')
addpath('/home/veronika/reconstruction/result/input/')                                                                       
addpath('/home/veronika/reconstruction/result/weights/univariate/');


%% reconstruct the signal as the weighted sum of spikes
%tic
     
loadname=['wauc_',namea{ba},namep{period}];
load(loadname,'auc')

%%
loadname2=['input_mc_',namea{ba},'_', namep{period}];
load(loadname2,'spikes_mc')

nbses=length(auc);
K=size(spikes_mc{1}{1},3);

x_nmu=[];
x_mu=[];

for sess=1:nbses
    
    weights=auc{sess};
    spikes=cellfun(@(x) double(x),spikes_mc{sess},'UniformOutput',false);
    %N=size(spikes{1,1},2);
    
    [x_uni] = reconstruct_uni_fun(weights,spikes,kernel);                                   % reconstruct with single neurons (AUC weights)
    
    x_nmu=cat(1,x_nmu,squeeze(x_uni(1,:,:)));                                               % collect results across sessions; non-match
    x_mu=cat(1,x_mu,squeeze(x_uni(2,:,:)));                                                 % match
    
    
end

%% save

if saveres==1
        
    savename=['univar_',namea{ba},'_',namep{period}];
    savefile= '/home/veronika/reconstruction/result/univariate/';
    save([savefile,savename],'x_nmu','x_mu')
        
end
    
