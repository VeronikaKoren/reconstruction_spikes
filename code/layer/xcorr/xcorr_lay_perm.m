% reconstruct in layers with permutations

clear all 
clc

place=1;
saveres=1;


ba=1;
period=2;

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namelay={'SG','G','IG'};

task=['xcorr layer perm ',namea{ba},' ',namep{period}];
display(task)

L=100;                          % exponential kernel for convolution, length of the kernel
tau=0:L;                        % support
lambda=1/20;                	% time constant
kernel=exp(-lambda.*tau); 

%% load weights and spikes

addpath('/home/veronika/reconstruction/result/input/')
addpath('/home/veronika/reconstruction/result/weights/w_mc/');
addpath('/home/veronika/reconstruction/result/layer/ncell/')

if place==1
    addpath('/home/veronika/Dropbox/reconstruction/code/functions/')
else
    addpath('/home/veronika/reconstruction/code/functions/')
end
    
loadname=['weight_',namea{ba},'_',namep{period}];
load(loadname)

loadname2=['input_mc_',namea{ba},'_', namep{period}];                           % load spike trains
load(loadname2,'spikes_mc')

loadname3=['ncell_lay_',namea{ba}];
load(loadname3);

%%

nbses=length(spikes_mc);
K=size(spikes_mc{1}{1},3);
ncv=size(spikes_mc{1},1);
nperm=1000;

tic
 
r_perm1=zeros(nbses,nperm,2*K-1);
r_perm2=zeros(nbses,nperm,2*K-1);
r_perm3=zeros(nbses,nperm,2*K-1);

for sess=1:nbses
    
    display(sess)
   
    w_sess=w_all{sess};                                                             % weights (ncv,N)
    w_pos=wp.*w_sign;
    w_abs=max(max(abs(w_sess)));
    
    N=size(w_sess,2);                                                               % nb of neurons
    
    ratio=sum(ncell_lay)./sum(sum(ncell_lay));					    % correction factor
    cfactor=0.33./ratio;
    ncell_layer=ncell_lay(sess,:);                                                  % nb cells in the layer
    
    s=cumsum([0,ncell_layer]);
    
    spikes_one=cellfun(@(x,y) double(cat(1,x,y)),spikes_mc{sess}(:,1),spikes_mc{sess}(:,2),'UniformOutput',false);        % concatenate conditions NM and M
    J=size(spikes_one{1},1);
   
    %% use weights with permuted labels and permute class for spikes
    
    r1=zeros(nperm,2*K-1);
    r2=zeros(nperm,2*K-1);
    r3=zeros(nperm,2*K-1);
    
    for perm=1:10%nperm
        
        spikes_p=cellfun(@(x) x(randperm(J),:,:), spikes_one, 'UniformOutput',false);       % permute the order of trials
        wrs=sign(- w_abs + (w_abs + w_abs).*rand(N,100)'); 				    % random sign
        w_p=w_pos.*wrs; 								    % assign random sign						
        rp=randperm(N);
        
        %% compute LDR in layers and keep cv and trials
        
        xp=cell(3,1); 											
        
        for r = 1:3                                                                         % layers                                            
            
            delta = s(r) + 1 : s(r+1);
            mask= zeros(1,N);
            mask(rp(delta)) = ones(length(delta),1); 					    % randomly assigned mask
            bmask=repmat(mask,ncv,1);
            weights=w_p.*bmask;                                         % use weights from the svm with permuted class labels  
            
            spikes=cellfun(@(x) x.*cfactor(r),spikes_p,'UniformOutput',false);
            
            [x_rec] = reconstruct_1c_fun(weights,spikes,kernel);                            % compute reconstruction in trials
            xp{r}=x_rec;                                                                    % collect across permutations
            
        end
        
        %% compute correlation function between pairs of layers
        
        idx1=[1,1,2];
        idx2=[2,3,3];
        rl=zeros(length(idx1),2*K-1);
        for c=1:length(idx1)
            
            x=xp{idx1(c)}; % layer 1
            y=xp{idx2(c)}; % layer 2
            
            rl(c,:) = correlation_fun(x,y); % correlation between plus and minus signals in trials and cv, averged across trials and cv
            
        end
        
        r1(perm,:)=rl(1,:);
        r2(perm,:)=rl(2,:);
        r3(perm,:)=rl(3,:);
        
    end
    
    r_perm1(sess,:,:)=r1;
    r_perm2(sess,:,:)=r2;
    r_perm3(sess,:,:)=r3;
    
end
toc


%% save

if saveres==1
        
    savename=['xcorr_layp_',namea{ba},'_',namep{period}];
    savefile='/home/veronika/reconstruction/result/layer/xcorr_perm/';
    save([savefile,savename],'r_perm1','r_perm2','r_perm3')
    
end
    
clear all 

%%

