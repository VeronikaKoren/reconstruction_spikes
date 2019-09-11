% reconstruct with permutations

clear all 
close all
clc

saveres=1;
pltfig=0;

ba=1;
period=2;

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namelay={'SG','G','IG'};

task=['xcorr layer 1c ',namea{ba},' ',namep{period}];
display(task)

L=100;                          % exponential kernel for convolution, length of the kernel
tau=0:L;                        % support
lambda=1/20;                	% time constant
kernel=exp(-lambda.*tau); 

%% load weights and spikes

    
addpath('/home/veronika/Dropbox/reconstruction/code/functions/')
addpath('/home/veronika/v1v4/reconstruction/result/input/')
addpath('/home/veronika/v1v4/reconstruction/result/weights/w_mc/');
addpath('/home/veronika/v1v4/reconstruction/result/layer/ncell/')

loadname=['weight_',namea{ba},'_',namep{period}];
load(loadname)

loadname2=['input_mc_',namea{ba},'_', namep{period}];                           % load spike trains
load(loadname2,'spikes_mc')

loadname3=['ncell_lay_',namea{ba}];
load(loadname3);

%%

ratio=sum(ncell_lay)./sum(sum(ncell_lay));
cfactor=0.33./ratio;

nbses=length(spikes_mc);
K=size(spikes_mc{1}{1},3);
ncv=size(w_all{1},1);

idx1=[1,1,2];
idx2=[2,3,3];
r_layer=zeros(nbses,length(idx1),2*K-1);

tic
    
for sess=1:nbses
    
    display(sess)
   
    w=w_all{sess};                                                                  % weights (ncv,N)
    spikes_one=cellfun(@(x,y) double(cat(1,x,y)),spikes_mc{sess}(:,1),spikes_mc{sess}(:,2),'UniformOutput',false);        % concatenate conditions NM and M 
    N=size(w,2);                                                                    % nb of neurons
    
    ncell_layer=ncell_lay(sess,:);                                                  % nb cells in the layer
    s=cumsum([0,ncell_layer]);
    
    %% compute LDR in layers and keep cv and trials
    
    xp=cell(3,1); 											%(sign, condition)
    
    for r = 1:3                                             % reconstruct the signal in every layer
                                                            % keep trials
        delta = s(r) + 1 : s(r+1);
        mask= zeros(1,N);
        mask(delta) = ones(length(delta),1);
        bmask=repmat(mask,ncv,1);
        weights=w.*bmask;
        
        spikes=cellfun(@(x) x.*cfactor(r),spikes_one,'UniformOutput',false);
        
        [x_rec] = reconstruct_1c_fun(weights,spikes,kernel);                               % compute reconstruction in trials
        xp{r}=x_rec;                                                                    % collect across permutations
            
    end
    
    %% compute correlation function between pairs of layers
    
    for c=1:length(idx1)
        
        x=xp{idx1(c)}; % layer 1
        y=xp{idx2(c)}; % layer 2
        
        [rxy] = correlation_fun(x,y); % correlation between plus and minus signals in trials and cv, averged across trials and cv
        r_layer(sess,c,:)=rxy;
    end
    
end
toc

%% plot

if pltfig==1
    r_mean=squeeze(nanmean(r_layer,1));
    figure()
    for c=1:3
        subplot(3,1,c)
        plot(r_mean(c,:))
    end
end


%% save

if saveres==1
        
    savename=['xcorr_layer_',namea{ba},'_',namep{period}];
    savefile='/home/veronika/reconstruction/result/layer/xcorr_1c/';
    save([savefile,savename],'r_layer')
    
end
    
clear all 


%%

