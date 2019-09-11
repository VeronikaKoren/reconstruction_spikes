% reconstruct with permutations

clear all 
close all

place=1;
saveres=0;

ba=2;
period=1;

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};

task=['reconstruct sign permuted ',namea{ba},' ',namep{period}];
display(task)

L=100;                          % length of the kernel                                  
tau=0:L;                        % support
lambda=1/20;                	% time constant
kernel=exp(-lambda.*tau);       

%% load weights and spikes

addpath('/home/veronika/reconstruction/result/input/monte_carlo/')
addpath('/home/veronika/reconstruction/result/weights/w_squeeze/');

if place==1
    addpath('/home/veronika/Dropbox/reconstruction/code/functions/')
else
    addpath('/home/veronika/reconstruction/code/functions/')
end

loadname=['weight_perm_',namea{ba},'_',namep{period}];
load(loadname)

loadname2=['input_mc_',namea{ba},'_', namep{period}];                           % load spike trains
load(loadname2,'spikes_mc')

%% reconstruct the signal as the weighted sum of spikes

tic

nbses=length(spikes_mc);
K=size(spikes_mc{1}{1},3);
nperm=size(w_perm{1},1);
ncv=size(spikes_mc{1},1);

x_minus=zeros(nbses,nperm,2,K);
x_plus=zeros(nbses,nperm,2,K);

%%
    
for sess=1:nbses
    
    disp(sess)
    spikes_one=cellfun(@(x,y) single(cat(1,x,y)), spikes_mc{sess}(:,1),spikes_mc{sess}(:,2),'UniformOutput', false);    % concatenate conditions
    
    N=size(spikes_sess{1},2);                                                                             % nb of neurons
    np=floor(N/2);
    J=[size(spikes_sess{1,1},1),size(spikes_sess{1,2},1)];                                                % nb trials
    
    %% compute LDR for plus and minus neurons in trials, with permutation
    
    xm=zeros(nperm,2,K);                                                                             % (condition, perm,time)
    xp=zeros(nperm,2,K); 
    
    for perm=1:nperm
        w=squeeze(w_perm{sess}(perm,:,:));                                                                                                                                             
        rp=randperm(N);        
        
        spikes_perm=cellfun(@(x) x(randperm(sum(J)),:,:),spikes_one, 'UniformOutput',false);
        spikes=cell(ncv,2);
        spikes(:,1)=cellfun(@(x) x(1:J(1),:,:), spikes_perm, 'UniformOutput',false);
        spikes(:,2)=cellfun(@(x) x(J(1)+1:sum(J),:,:), spikes_perm, 'UniformOutput',false);
        
        for sgn=1:2
            
            if sgn==1
                idx_use=rp(1:np);                                                                       % use half of randomly selected neurons
            else
                idx_use=rp(np+1:end);
            end
            
            weights=zeros(100,N);
            weights(:,idx_use)=w(:,idx_use);                                                       % use half of the weights (randomly assigned)
            
            [x_cv] = reconstruct_mc_fun(weights,spikes,kernel);                          
            if sgn==1
                xm(perm,:,:)=x_cv;                                                                 % collect across permutations
            else
                xp(perm,:,:)=x_cv;
            end
        end 
    end
    
    x_minus(sess,:,:,:)=xm;
    x_plus(sess,:,:,:)=xp;
    
end
toc

%% save
   
if saveres==1
        
    savename=['sign_perm_',namea{ba},'_',namep{period}];
    if place==1
        savefile='/home/veronika/reconstruction/result/sign/permuted/';
    else
        savefile='/home/veronika/reconstruction/result/sign/permuted/';
    end
    save([savefile,savename],'x_minus','x_plus')
    
end
    
clear all 

%%

