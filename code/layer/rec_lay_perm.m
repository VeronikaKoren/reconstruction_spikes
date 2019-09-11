% reconstruct layers

clear all 
close 
clc
format short

place=1;
saveres=0;
pltfig=0;
        
ba=2;
period=2;

tau_prime=20;                                                                 

%%

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namelay={'SG','G','IG'};

task=['compute LDR perm in layers ', namea{ba},' ', namep{period}];
display(task)
                                                                                      % exponential kernel for convolution
L=100;                                                                                % length of the kernel                                  
tau=0:L;                                                                              % support
lambda=1/tau_prime;                                                                   % time constant
kernel=exp(-lambda.*tau); 

%% load weights and spikes

addpath('/home/veronika/reconstruction/result/input/')
addpath('/home/veronika/reconstruction/result/weights/w_squeeze/')
addpath('/home/veronika/reconstruction/result/layer/ncell/')

if place==1
    addpath('/home/veronika/Dropbox/reconstruction/code/functions/')    
else
    addpath('/home/veronika/reconstruction/code/functions/')
end

%% reconstruct the signal as the weighted sum of spikes

loadname0=['weight_perm_',namea{ba},'_',namep{period}];
load(loadname0)      

loadname2=['input_mc_',namea{ba},'_', namep{period}];
load(loadname2,'spikes_mc')

loadname3=['ncell_lay_',namea{ba}];
load(loadname3);

nbses=length(w_perm);
K=size(spikes_mc{1}{1},3);
ncv=size(w_perm{1},2);
nperm=size(w_perm{1},1);

%%

x_sgp=zeros(nbses,nperm,2,K);
x_gp=zeros(nbses,nperm,2,K);
x_igp=zeros(nbses,nperm,2,K);
%}

tic
for sess = 1:nbses
    disp(sess)
    
    x_sg=zeros(nperm,2,K);
    x_g=zeros(nperm,2,K);
    x_ig=zeros(nperm,2,K);
    
    ncl=ncell_lay(sess,:);
    s=cumsum([0,ncl]);
    N=s(end);
    J=[size(spikes_mc{sess}{1,1},1), size(spikes_mc{sess}{1,2},1)];
    
    ratio=ncl./sum(ncl);
    cfactor=((1/3)./ratio);  
    
    bmask=cell(3,1); 
    for r =1:3                                                                      % mask for layers
        delta = s(r) + 1 : s(r+1);
        mask= zeros(1,N);
        mask(delta) = ones(length(delta),1).*cfactor(r);
        bmask{r}=repmat(mask,ncv,1);
    end
 
    spikes_one=cellfun(@(x,y) single(cat(1,x,y)), spikes_mc{sess}(:,1),spikes_mc{sess}(:,2),'UniformOutput', false); 
    
    %%
    
    for perm=1:nperm                                                               % permutations
        
        w=squeeze(w_perm{sess}(perm,:,:));                                          % use weights from svm with permuted class labels
        
        spikes_perm=cellfun(@(x) x(randperm(sum(J)),:,:),spikes_one, 'UniformOutput',false);        % permute class label for spike trains
        spikes=cell(ncv,2);
        spikes(:,1)=cellfun(@(x) x(1:J(1),:,:), spikes_perm, 'UniformOutput',false);
        spikes(:,2)=cellfun(@(x) x(J(1)+1:sum(J),:,:), spikes_perm, 'UniformOutput',false);
        
        for r = 1:3
                
            weights=w.*bmask{r};
            
            [x_cv] = reconstruct_mc_fun(weights,spikes,kernel);
            
            if r==1
                x_sg(perm,:,:)=x_cv;                                                 % collect results across permutation
            elseif r==2
                x_g(perm,:,:)=x_cv;
            elseif r==3
                x_ig(perm,:,:)=x_cv;
            end
            
        end
        % lay
    end
    % perm
    
    x_sgp(sess,:,:,:)=x_sg;                                                % collect results across sessions
    x_gp(sess,:,:,:)=x_g;
    x_igp(sess,:,:,:)=x_ig;
    
end
% sess
toc


%% save

if saveres==1
    
    savename=['layer_perm_',namea{ba},'_',namep{period}];
    savefile= '/home/veronika/reconstruction/result/layer/permuted/';
    
    save([savefile,savename],'x_sgp','x_gp','x_igp')
    
end
        
clear all

