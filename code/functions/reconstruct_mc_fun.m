function [x_cv] = reconstruct_mc_fun(weights,spikes,kernel)

%% Low-dimensional reconstruction of spike trains

% computes low-dimensional reconstruction of spike trains as the weighted
% sum of spikes, convolved with an exponential kernel

% computes LDR in trials and in cross-validations and averages across
% trials and across cvs
%%
format short
ncv=size(weights,1);                                                                % number of neurons
K=size(spikes{1},3);                                                                % number timesteps
J=(cellfun(@(x) size(x,1),spikes(1,:),'UniformOutput',false)');                     % number of trials

%% compute LDR

cat_nm=zeros(ncv,K);
cat_m=zeros(ncv,K);

for cv=1:ncv
    
    x_full=cell(2,1);
    w=weights(cv,:);
    
    for c=1:2
        
        o=spikes{cv,c};
        xsig=zeros(J{c},K);
        for trial=1:J{c}
            
            oj=squeeze(o(trial,:,:));
            xsig(trial,:)=conv(w*oj,kernel,'same');                                         % reconstruct
            
        end
        x_full{c}=xsig;
    end
    
    % subtract the running mean
    z=mean(cat(1,x_full{1},x_full{2}));
    repz=cellfun(@(x,y) repmat(x,y,1),[{z};{z}],J,'UniformOutput',false);
    nsig=cellfun(@(x,z) x-z,x_full,repz,'UniformOutput',false);                             % deviation from the mean
    msig=cellfun(@mean, nsig,'UniformOutput',false);                                        % average across trials
    
    cat_nm(cv,:)=msig{1};
    cat_m(cv,:)=msig{2};
    
end
  
%%
x_cv=zeros(2,K);
x_cv(1,:)=nanmean(cat_nm);                                                                  % average across cross-validations
x_cv(2,:)=nanmean(cat_m);

end

