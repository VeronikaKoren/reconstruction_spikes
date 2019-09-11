function [x_uni] = reconstruct_uni_fun(weights,spikes,kernel)

%% Low-dimensional reconstruction of spike trains

% computes low-dimensional reconstruction of spike trains as the weighted
% sum of spikes, convolved with an exponential kernel

% computes LDR in trials and in cross-validations and averages across
% trials and across cvs
%%

ncv=size(weights,1);                                                                % number of neurons
K=size(spikes{1},3);                                                                % number timesteps
J=(cellfun(@(x) size(x,1),spikes(1,:),'UniformOutput',false)');                     % number of trials
N=size(spikes{1,1},2);

%% compute LDR

cat_nm=zeros(ncv,N,K);
cat_m=zeros(ncv,N,K);

for cv=1:ncv
    
    
    
    for n=1:N
        x_full=cell(2,1);
        for c=1:2
        
            w=weights(cv,n);
            xsig=zeros(J{c},K);
            
            for trial=1:J{c}
                oj=squeeze(spikes{cv,c}(trial, n,:));
                xsig(trial,:)=conv(w*oj,kernel,'same');                                         % reconstruct
                
            end
            
            x_full{c}=xsig;
            
        end
        
        
        % subtract the running mean
        z=mean(cat(1,x_full{1},x_full{2}));
        repz=cellfun(@(x,y) repmat(x,y,1),[{z};{z}],J,'UniformOutput',false);
        nsig=cellfun(@(x,z) x-z,x_full,repz,'UniformOutput',false);                             % deviation from the mean
        msig=cellfun(@mean, nsig,'UniformOutput',false); 
        
        cat_nm(cv,n,:)=msig{1};
        cat_m(cv,n,:)=msig{2};
        
    end
    
    
end
  
%%
x_uni=zeros(2,N,K);
x_uni(1,:,:)=nanmean(cat_nm);                                                                  % average across cross-validations
x_uni(2,:,:)=nanmean(cat_m);

%%
%{
nn=11
figure()
hold on
plot(squeeze(x_uni(1,nn,:)))
plot(squeeze(x_uni(2,nn,:)))
hold off
%}
end

%%




