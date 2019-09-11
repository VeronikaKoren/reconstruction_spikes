function [x_rec] = reconstruct_1c_fun(weights,spikes,kernel)

%% Low-dimensional reconstruction of spike trains
% computes low-dimensional reconstruction of spike trains as the weighted
% sum of spikes, convolved with an expenential kernel
% returns the reconstruction in trials

%%
ncv=size(weights,1);                                                                % number of neurons
K=size(spikes{1},3);                                                                % number timesteps
J=size(spikes{1},1);                              % number of trials

%% weighted sum of spikes in every trial

x_rec=zeros(ncv,J,K);

for cv=1:ncv
    
    w=weights(cv,:);
     
    o=spikes{cv};
    xsig=zeros(J,K);
    for trial=1:J
        
        oj=squeeze(o(trial,:,:));
        xsig(trial,:)=conv(w*oj,kernel,'same');                                     % reconstruct
        
    end
    %%
    
    % subtract the running mean
    z=nanmean(xsig);
    repz=repmat(z,J,1);                             % deviation from the mean
    x_rec(cv,:,:)=xsig-repz;
    
end


end

%%
