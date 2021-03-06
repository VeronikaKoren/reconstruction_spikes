% reconstruct with permutations

clear all 
clc

saveres=0;

ba=1;
period=2;

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namesign={'minus','plus'};

task=['xcorr sign 1c ',namea{ba},' ',namep{period}];
display(task)

L=100;                          % length of the kernel                                  % exponential kernel for convolution
tau=0:L;                        % support
lambda=1/20;                	% time constant
kernel=exp(-lambda.*tau); 

%% load weights and spikes
    
addpath('/home/veronika/Dropbox/reconstruction/code/functions/')
addpath('/home/veronika/v1v4/reconstruction/result/input/')
addpath('/home/veronika/v1v4/reconstruction/result/weights/w_mc/');

loadname=['weight_',namea{ba},'_',namep{period}];
load(loadname)

loadname2=['input_mc_',namea{ba},'_', namep{period}];                           % load spike trains
load(loadname2,'spikes_mc')

%%

tic

nbses=length(spikes_mc);
K=size(spikes_mc{1}{1},3);
r_sign=zeros(nbses,2*K-1);
    
for sess=1:nbses
    
    display(sess)
    
    weight_all=w_all{sess};
    sp=cellfun(@(x) single(x),spikes_mc{sess},'UniformOutput',false);
    spikes=cellfun(@(x,y) cat(1,x,y),sp(:,1),sp(:,2),'UniformOutput',false);        % concatenate trials
    J=size(spikes{1},1);                                                            % nb trials
    
    %% compute LDR for plus and minus neurons in trials
    
    xp=cell(2,1); 											%(sign, condition)
    
    for sign=1:2
        
        if sign==1
            mask=weight_all<0;                                             % use positive or negative weights
        else
            mask=weight_all>0;
        end
        weights=weight_all.*mask;
        [x_rec] = reconstruct_1c_fun(weights,spikes,kernel);                               % compute reconstruction in trials
        
        xp{sign}=x_rec;                                                                    % collect across permutations
            
    end
    
    %% compute correlation function between plus and minus neurons
    
    x=xp{1}; % minus
    y=xp{2}; % plus
    
    [rxy] = correlation_fun(x,y); % correlation between plus and minus signals in trials and cv, averged across trials and cv
    r_sign(sess,:)=rxy;
    
end
toc

%% save
    
if saveres==1
        
    savename=['xcorr_sign_',namea{ba},'_',namep{period}];
    savefile='/home/veronika/reconstruction/result/sign/xcorr_1c/';
    save([savefile,savename],'r_sign')
    
end
    
clear all 

%%

