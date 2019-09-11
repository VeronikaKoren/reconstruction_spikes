function [x_cv] = reconstruct_binary_fun(weights,spikes,kernel)

%% Low-dimensional reconstruction of spike trains
% computes low-dimensional reconstruction of spike trains as the weighted
% sum of spikes, convolved with an expenential kernel

%%
ncv=size(weights,1);                                                                % number of neurons
K=size(spikes{1},3);                                                                 % number timesteps
J=(cellfun(@(x) size(x,1),spikes(1,:),'UniformOutput',false)');                              % number of trials

%% weighted sum of spikes in every trial

w_abs=mean(mean(abs(weights)));

all_nm=zeros(ncv,K);
all_m=zeros(ncv,K);

for cv=1:ncv
    
    x_full=cell(2,1);
    w=weights(cv,:);    
    nidx= w<0;
    pidx= w>0;
    w(nidx)=-w_abs;
    w(pidx)=w_abs;
    
    for c=1:2
        
        o=spikes{cv,c};
        xsig=zeros(J{c},K);
        for trial=1:J{c}
            
            oj=squeeze(o(trial,:,:));
            xsig(trial,:)=conv(w*oj,kernel,'same');                                     % reconstruct
            
        end
        x_full{c}=xsig;
    end
    
    % subtract the running mean
    z=mean(cat(1,x_full{1},x_full{2}));
    repz=cellfun(@(x,y) repmat(x,y,1),[{z};{z}],J,'UniformOutput',false);
    nsig=cellfun(@(x,z) x-z,x_full,repz,'UniformOutput',false);                             % deviation from the mean
    msig=cellfun(@mean, nsig,'UniformOutput',false);                                        % average across trials
    
    all_nm(cv,:)= msig{1};
    all_m(cv,:)= msig{2};
    
end
  
%%
x_cv=zeros(2,K);
x_cv(1,:)=nanmean(all_nm);
x_cv(2,:)=nanmean(all_m);

end

