
% reconstruct layers

clear all 
close all
clc

saveres=0;
pltfig=0;
        
ba=2;
period=2;

tau_prime=20;                                                                % choose between [10,20,50]

%%
namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namelay={'SG','G','IG'};

task=['compute LDR in layers ', namea{ba},' ', namep{period}];
display(task)

blue=[0,0.48,0.74];
red=[0.85,0.32,0.1];
                                                                                      % exponential kernel for convolution
L=100;                                                                                % length of the kernel                                  
tau=0:L;                                                                              % support
lambda=1/tau_prime;                                                                   % time constant
kernel=exp(-lambda.*tau); 

%% load weights and spikes

addpath('/home/veronika/Dropbox/reconstruction/code/functions/')
addpath('/home/veronika/reconstruction/result/input/')
addpath('/home/veronika/reconstruction/result/weights/w_mc/')                                                                 
addpath('/home/veronika/reconstruction/result/layer/ncell/')

%% reconstruct the signal as the weighted sum of spikes
      
loadname=['weight_',namea{ba},'_',namep{period}];
load(loadname)

loadname2=['input_mc_',namea{ba},'_', namep{period}];
load(loadname2,'spikes_mc')

loadname3=['ncell_lay_',namea{ba}];
load(loadname3);

%%

nbses=length(w_all);
K=size(spikes_mc{1}{1},3);
ncv=size(w_all{1},1);

x_sg=zeros(nbses,2,K);
x_g=zeros(nbses,2,K);
x_ig=zeros(nbses,2,K);

tic
for sess = 1:nbses
    %display(sess)
    
    w_sess=w_all{sess};
    ncl=ncell_lay(sess,:);
    s=cumsum([0,ncl]);
    N=size(w_sess,2);
    
    ratio=ncl./sum(ncl);
    cfactor=((1/3)./ratio);                                                   % correction factor for the number of neurons in the layer
    %%
    for r = 1:3
        
        delta = s(r) + 1 : s(r+1);
        mask= zeros(1,N);
        mask(delta) = ones(length(delta),1).*cfactor(r);
        bmask=repmat(mask,ncv,1);
      
        weights=w_sess.*bmask;
        spikes=cellfun(@(x) double(x),spikes_mc{sess},'UniformOutput',false);
        
        [x_cv] = reconstruct_mc_fun(weights,spikes,kernel);
       
        if r==1
            x_sg(sess,:,:)=x_cv;                                                  % collect results across sessions; non-match
        elseif r==2
            x_g(sess,:,:)=x_cv;
        elseif r==3
            x_ig(sess,:,:)=x_cv;
        end
        
    end
    
end
toc

%% plot

if pltfig==1
    
    x_show=x_sg;
    figure()
    shadedErrorBar(1:K,nanmean(x_show(:,1,:)),nanstd(x_show(:,1,:))./sqrt(nbses),{'color',blue},1)
    hold on
    shadedErrorBar(1:K,nanmean(x_show(:,2,:)),nanstd(x_show(:,1,:))./sqrt(nbses),{'color',red},1)
    plot(zeros(K,1),'k')
    hold off
    box off
    
    %ylim([-0.11,0.11])
    text(0.1,0.95,'match','units','normalized','color',red)
    text(0.1,0.87,'non-match','units','normalized','color',blue)
    xlabel('time (ms)')
    ylabel('low-dimensional reconstruction all')
    
end

%% save

if saveres==1
    
    savename=['layer_',namea{ba},'_',namep{period}];
    savefile= '/home/veronika/reconstruction/result/layer/regular/';
    save([savefile,savename],'x_sg','x_g','x_ig')
    
end
        
       
