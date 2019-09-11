% reconstruct with permutations

close all
clear all 
clc

place=1;
saveres=0;
pltfig=0;

ba=2;
period=2;

choose_perm={ '1:permute_weight','2:permute_wsign', '3:permute_timing','4:permute_class','5:permute_amp'};
nameperms=cellfun(@(x) x(3:end),choose_perm,'UniformOutput',false);

perm_type=5; 

nameperm=nameperms{perm_type};

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};

task=['reconstruct all neurons ',nameperm,' ' ,namea{ba},' ',namep{period}];
display(task)

L=100;                          % length of the kernel                                  % exponential kernel for convolution
tau=0:L;                        % support
lambda=1/20;                	% time constant
kernel=exp(-lambda.*tau); 

%% load weights and spikes

if place==1
    
    addpath('/home/veronika/Dropbox/reconstruction/code/functions/')
    addpath('/home/veronika/v1v4/reconstruction/result/input/')
    if perm_type==4
        addpath('/home/veronika/v1v4/reconstruction/result/weights/w_squeeze/');
    else
        addpath('/home/veronika/v1v4/reconstruction/result/weights/w_mc/');
    end
else
    addpath('/home/veronika/reconstruction/functions/')
    addpath('/home/veronika/reconstruction/result/input/')
    if perm_type==4
        addpath('/home/veronika/reconstruction/result/weights/w_squeeze/');
    else
        addpath('/home/veronika/reconstruction/result/weights/w_mc/');
    end

end

if perm_type==4
    loadname=['weight_perm_',namea{ba},'_',namep{period}];                          % load weights
    load(loadname)
    w_all=w_perm;
else
    loadname=['weight_',namea{ba},'_',namep{period}];
    load(loadname)
end

loadname2=['input_mc_',namea{ba},'_', namep{period}];                               % load spike trains
load(loadname2,'spikes_mc')

%% reconstruct the signal with permutation

tic

nbses=length(spikes_mc);
K=size(spikes_mc{1}{1},3);
nperm=1000;

x_nmp=zeros(nbses,nperm,K);
x_mp=zeros(nbses,nperm,K);
    
for sess=1%:nbses
    disp(sess)
    
    weights=w_all{sess};
    spikes=cellfun(@(x) single(x),spikes_mc{sess},'UniformOutput',false);
    
    [x_cv] = reconstruct_perm_fun(weights,spikes,kernel,perm_type);
    x_nmp(sess,:,:) = x_cv(1,:,:);                                                  % collect results across sessions; non-match
    x_mp(sess,:,:) = x_cv(2,:,:);                                                   % match
    
end
toc

%% plot

if pltfig==1
        
    xmean=squeeze(nanmean(x_nmp));
    ymean=squeeze(nanmean(x_mp));
   
    nstep=size(xmean,2);
    figname=[namea{ba},'_',namep{period}];
    
    figure('name',figname)
    hold on
    for perm=1:10
        plot(xmean(perm,:),'color','b')
        plot(ymean(perm,:),'color','r')
    end
    plot(zeros(nstep,1),'k')
    hold off
    box off
    
    ylim([-0.02,0.02])
    text(0.1,0.95,'match','units','normalized','color','r')
    text(0.1,0.87,'non-match','units','normalized','color','b')
    xlabel('time (ms)')
    ylabel('low-dimensional reconstruction all')
    
end
 
%% save
    

if saveres==1
        
    savename=[nameperm,'_',namea{ba},'_',namep{period}];
    savefile=['/home/veronika/reconstruction/result/all_neurons/',nameperm,'/'];
    save([savefile,savename],'x_nmp','x_mp')
    clear all 
    
end
    


%%


