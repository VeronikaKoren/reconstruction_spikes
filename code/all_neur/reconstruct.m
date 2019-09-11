% reconstruct regular with different time constants

clear all 
close all
clc

saveres=1;
pltfig=1;

type=1;                                                                                 % 1 for regular, 2 for binary
tau_prime=50;                                                                           % choose between [10,20,50]

%%
namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namet={'regular','binary'};

task=['compute LDR all neurons ', namet{type}, ' (lambda)^-1 = ', sprintf('%1.0i',tau_prime)];
display(task)
                                                                                      % exponential kernel for convolution
L=100;                                                                                % length of the kernel                                  
tau=0:L;                                                                              % support
lambda=1/tau_prime;                                                                   % time constant
kernel=exp(-lambda.*tau); 

%% load weights and spikes

addpath('/home/veronika/Dropbox/reconstruction/code/functions/')
addpath('/home/veronika/v1v4/reconstruction/result/input/')                                                                       
addpath('/home/veronika/v1v4/reconstruction/result/weights/w_mc/');


%% reconstruct the signal as the weighted sum of spikes
tic
for ba=1:2
    for period=1:2
        
        loadname=['weight_',namea{ba},'_',namep{period}];
        load(loadname)
        
        loadname2=['input_mc_',namea{ba},'_', namep{period}];
        load(loadname2,'spikes_mc')
        
        nbses=length(w_all);
        K=size(spikes_mc{1}{1},3);
        
        x_nm=zeros(nbses,K);
        x_m=zeros(nbses,K);
        
        for sess=1:nbses
            %display(sess)
            
            weights=w_all{sess};
            spikes=cellfun(@(x) double(x),spikes_mc{sess},'UniformOutput',false);
            
            if type==1
                [x_cv] = reconstruct_mc_fun(weights,spikes,kernel);                     % to reconstruct with regular weights
            else
                [x_cv] = reconstruct_binary_fun(weights,spikes,kernel);                 % to reconstruct with binary weights
            end
            x_nm(sess,:)=x_cv(1,:);                                                     % collect results across sessions; non-match
            x_m(sess,:)=x_cv(2,:);                                                      % match
            
        end
        
        %%
        if pltfig==1
            figname=[namea{ba},'_',namep{period}];
            nstep=size(x_nm,2);
            
            figure('name',figname)
            shadedErrorBar(1:nstep,nanmean(x_nm),nanstd(x_nm)./sqrt(nbses),{'color','b'},1)
            hold on
            shadedErrorBar(1:nstep,nanmean(x_m),nanstd(x_m)./sqrt(nbses),{'color','r'},1)
            plot(zeros(nstep,1),'k')
            hold off
            box off
            
            ylim([-0.11,0.11])
            text(0.1,0.95,'match','units','normalized','color','r')
            text(0.1,0.87,'non-match','units','normalized','color','b')
            xlabel('time (ms)')
            ylabel('low-dimensional reconstruction all')
             
        end
        
        %% save
        if saveres==1
            
            savename=['allneur_',namea{ba},'_',namep{period}];
            if type==1
                savefile=['/home/veronika/v1v4/reconstruction/result/all_neurons/','tau_',sprintf('%1.0i',tau_prime),'/'];
            else
                savefile= '/home/veronika/v1v4/reconstruction/result/all_neurons/binary/';
            end
            save([savefile,savename],'x_nm','x_m')
            
        end
        
    end
end
toc
%%


