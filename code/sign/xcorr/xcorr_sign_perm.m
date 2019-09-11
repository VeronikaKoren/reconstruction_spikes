% reconstruct with permutations

clear all 
clc

place=1;
saveres=1;

ba=2;
period=2;

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namesign={'minus','plus'};

task=['xcorr sign permuted ',namea{ba},' ',namep{period}];
display(task)

L=100;                          % length of the kernel                                  % exponential kernel for convolution
tau=0:L;                        % support
lambda=1/20;                	% time constant
kernel=exp(-lambda.*tau); 

%% load weights and spikes

addpath('/home/veronika/reconstruction/result/input/')
addpath('/home/veronika/reconstruction/result/weights/w_mc/');

if place==1
    addpath('/home/veronika/Dropbox/reconstruction/code/functions/')
else
    addpath('/home/veronika/reconstruction/code/functions/')
end

loadname=['weight_',namea{ba},'_',namep{period}];
load(loadname)

loadname2=['input_mc_',namea{ba},'_', namep{period}];                           % load spike trains
load(loadname2,'spikes_mc')

%% correlation function between plus and minus neurons null model

tic

nbses=length(spikes_mc);
K=size(spikes_mc{1}{1},3);
nperm=1000;

r_perm=zeros(nbses,nperm,2*K-1);

%%
    
parfor sess=1:nbses
    
    display(sess)
    
    wp=w_all{sess}; 								    % regular weights
    w_abs=max(max(abs(wp)));                                                        % maximal range of weights
    w_sign=sign(wp);                                                                % sign of weights 
    w_pos=wp.*w_sign;                                                               % makes all weights positive  
    N=size(wp,2); 					
    np=floor(N/2);
    
    sp=cellfun(@(x) single(x),spikes_mc{sess},'UniformOutput',false);
    spikes=cellfun(@(x,y) cat(1,x,y),sp(:,1),sp(:,2),'UniformOutput',false);        % concatenate trials (the two conditions)
    J=size(spikes{1},1);                                                            % nb trials
    
    %% compute LDR for plus and minus neurons in trials, with permutation
    
    rxy_perm=zeros(nperm,2*K-1);
    for perm=1:nperm
        
        xp=cell(2,1);                                                                 %(sign, 1)
        wrs=sign(- w_abs + (w_abs + w_abs).*rand(N,100)');                            % random sign of weights
        weights_all=w_pos.*wrs;                                                       % weights with random sign 
        rp=randperm(N);        
        
        spikes=cellfun(@(x) x(randperm(J),:,:), spikes,'UniformOutput',false);
        for sgn=1:2
            
            if sgn==1
                idx_use=rp(1:np);
            else
                idx_use=rp(np+1:end);
            end
            weights=zeros(100,N);
            weights(:,idx_use)=weights_all(:,idx_use);
            
            [x_rec] = reconstruct_1c_fun(weights,spikes,kernel);                              % compute reconstruction in trials
            xp{sgn}=x_rec;                                                                    % collect across permutations
            
            
        end
        
        %% compute correlation function between plus and minus neurons
        
        x=xp{1}; % minus
        y=xp{2}; % plus
        
        [rxy] = correlation_fun(x,y); % correlation between plus and minus signals in trials and cv, averged across trials and cv
        rxy_perm(perm,:)=rxy;
        
    end
    
    r_perm(sess,:,:)=rxy_perm;
    
end
toc


%% save
    
if saveres==1
        
    savename=['xcorr_perm_',namea{ba},'_',namep{period}];
    savefile='/home/veronika/reconstruction/result/sign/xcorr_perm1c/';
    save([savefile,savename],'r_perm')
    
end
    
clear variables 	

%%

