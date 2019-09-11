% reconstruct regular with different time constants

clear all 
close all
clc

place=1;
saveres=1;
pltfig=0;

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
if place==1
    addpath('/home/veronika/Dropbox/reconstruction/code/functions/')
else
    addpath('/home/veronika/reconstruction/code/functions/')
end

addpath('/home/veronika/reconstruction/result/input/')                                                                       
addpath('/home/veronika/reconstruction/result/weights/univariate/');


%% reconstruct the signal as the weighted sum of spikes
%tic
     
loadname=['wauc_',namea{ba},namep{period}];
load(loadname,'auc_perm')

%%
loadname2=['input_mc_',namea{ba},'_', namep{period}];
load(loadname2,'spikes_mc')

nbses=length(auc_perm);
K=size(spikes_mc{1}{1},3);
nperm=size(auc_perm{1},1);

x_nmup=cell(nbses,1);
x_mup=cell(nbses,1);

tic
parfor sess=1:2%:nbses
    %display(sess)
    
    w_sess=auc_perm(sess);
    spikes=cellfun(@(x) double(x),spikes_mc{sess},'UniformOutput',false);
    N=size(spikes{1,1},2);
    spikes_one=cellfun(@(x,y) cat(1,x,y), spikes(:,1),spikes(:,2),'UniformOutput', false);
    J=cellfun(@(x) size(x,1),spikes(1,:));
    Jtot=sum(J);
    
    x_nms=zeros(N,nperm,K);
    x_ms=zeros(N,nperm,K);
    
    for perm=1:nperm
        spike_perm=cellfun(@(x) x(randperm(Jtot),:,:),spikes_one, 'UniformOutput',false);
        spikes(:,1)=cellfun(@(x) x(1:J(1),:,:), spike_perm, 'UniformOutput',false);
        spikes(:,2)=cellfun(@(x) x(J(1)+1:sum(J),:,:), spike_perm, 'UniformOutput',false);
        weights=squeeze(w_sess{:}(1,:,:));
    
        [x_uni] = reconstruct_uni_fun(weights,spikes,kernel);                            % reconstruct with single neurons (AUC weights)
    
        x_nms(:,perm,:) = x_uni(1,:,:);                                                 % collect results across sessions; non-match
        x_ms(:,perm,:) = x_uni(2,:,:);                                                  % match
    
    end
    
    x_nmup{sess}=x_nms;
    x_mup{sess}=x_ms;
    
end
toc
%%

deltax=cellfun(@(x,y) x-y, x_mup,x_nmup,'UniformOutput', false);                % difference between conditions
xp=cell2mat(deltax);
mnp=squeeze(mean(xp));                                                          % average across neurons

    
%% save

if saveres==1
        
    savename=['univar_',namea{ba},'_',namep{period}];
    savefile= '/home/veronika/reconstruction/result/univariate/';
    save([savefile,savename],'x_nmup','x_mup', 'mnp')
        
end
    
