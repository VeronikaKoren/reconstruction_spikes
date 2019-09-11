
% reconstruct for plus and minus neurons

clear all 
close all
clc

saveres=0;
        
ba=2;
period=2;
                                                                        
%%
namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namesign={'minus','plus'};

task=['compute LDR sign ', namea{ba},' ', namep{period}];
display(task)
     
tau_prime=20;                                                                         % exponential kernel for convolution: time constant
L=100;                                                                                % length of the kernel                                  
tau=0:L;                                                                              % support
lambda=1/tau_prime;                                                                   % inverted time constant
kernel=exp(-lambda.*tau); 

%% load weights and spikes

addpath('/home/veronika/Dropbox/reconstruction/code/functions/')
addpath('/home/veronika/v1v4/reconstruction/result/input/')
addpath('/home/veronika/v1v4/reconstruction/result/weights/w_mc/')                                                                 
      
loadname=['weight_',namea{ba},'_',namep{period}];
load(loadname)

loadname2=['input_mc_',namea{ba},'_', namep{period}];
load(loadname2,'spikes_mc')

%% reconstruct for subnetworks of plus and minus neurons

nbses=length(w_all);
K=size(spikes_mc{1}{1},3);

x_minus=zeros(nbses,2,K);
x_plus=zeros(nbses,2,K);

for sess=1:nbses
    %display(sess)
    
    w_sess=w_all{sess};
    N=size(w_sess,2);
    
    for sgn=1:2
        if sgn==1
            mask=w_sess<0;
        else
            mask=w_sess>0;
        end
        
        ratio=sum(mask,2)/N;
        cfactor=(ratio./0.5).^(-1);
        
        cfmat=repmat(cfactor,1,N);
        
        weights=w_sess.*mask.*cfmat;
        spikes=cellfun(@(x) single(x),spikes_mc{sess},'UniformOutput',false);
        
        [x_cv] = reconstruct_mc_fun(weights,spikes,kernel);
        
        if sgn==1
            x_minus(sess,:,:)=x_cv;                                                  % collect results across sessions; minus
        else
            x_plus(sess,:,:)=x_cv;
        end
        
    end
    
end


%% save

if saveres==1
    
    savename=['sign_',namea{ba},'_',namep{period}];
    savefile= '/home/veronika/reconstruction/result/sign/regular/';
    save([savefile,savename],'x_minus','x_plus')
    
end
        
       
