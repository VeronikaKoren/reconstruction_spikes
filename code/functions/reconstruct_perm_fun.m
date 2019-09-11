function [x_cv] = reconstruct_perm_fun(weights,spikes,kernel,perm_type)

%% Low-dimensional reconstruction of spike trains with permutation
                                               
K=size(spikes{1},3);                                                                            % number timesteps
J=(cellfun(@(x) size(x,1),spikes(1,:),'UniformOutput',false)');                                 % number of trials
N=size(spikes{1,1},2);                                                                          % number of neurons
nperm=1000;
ncv=size(spikes,1);


%% weighted sum of spikes in every trial

w_abs=max(max(abs(weights)));

perm_nm=zeros(nperm,K);
perm_m=zeros(nperm,K);

for perm=1:nperm
    
    if or(perm_type==1,perm_type==5)==1    
        w=-w_abs + (w_abs + w_abs).*rand(N,1)';
        
        if perm_type==5
            w_amp=abs(w);                                                                           % amplitude of the random draw
        end
    end
    
    if perm_type==2
        wrs=sign(- w_abs + (w_abs + w_abs).*rand(N,1)');                                            % sign of a random draw from the uniform distribution
                                                                                                    % assign random sign (from uniform distribution)
    end
    %%
    if perm_type==3
        for c=1:2
            spike_timing=randperm(400);                                                             % permute spike timing vector
            spikes(:,c)=cellfun(@(x) x(:,:,spike_timing),spikes(:,c),'UniformOutput',false);
        end
    end
  %%
    if perm_type==4                                                                                 % permute class (trial order) for spikes
        new_order=randperm(J{1}+J{2});
        spikes_all=cellfun(@(x,y) cat(1,x,y),spikes(:,1),spikes(:,2),'UniformOutput',false);        % concatenate trials from both conditions
        spikes_allp=cellfun(@(x) x(new_order,:,:),spikes_all, 'UniformOutput',false);               % apply permuted trial order
        spikes(:,1)=cellfun(@(x) x(1:J{1},:,:),spikes_allp,'UniformOutput',false);                  % get into previous shape
        spikes(:,2)=cellfun(@(x) x(J{1}+1:end,:,:),spikes_allp,'UniformOutput',false);
        
    end
    
        
    cv_nm=zeros(ncv,K);
    cv_m=zeros(ncv,K);
   
    for cv=1:ncv
        
        if or(perm_type==2,perm_type==3)==1                                                                             % assign random sign (same for all cv)
            w=weights(cv,:);
            
            if perm_type==2
                wsign=sign(w);
                w_pos=w.*wsign;
                w=w_pos.*wrs;                                                                                           % apply random sign of weights
            end
        end
        
        if perm_type==4 
            w=squeeze(weights(perm,cv,:))';                                                                             % use weights from the SVM on random permutation of class labels
        end
        
        if perm_type==5
            w_sign=sign(weights(cv,:));
            w=w_amp.*w_sign;
        end
            
        spikes_cv=spikes(cv,:);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        x_full=cell(2,1);
        for c=1:2
            xsig=zeros(J{c},K);
            for trial=1:J{c}
                
                oj=squeeze(spikes_cv{c}(trial,:,:));
                xsig(trial,:)=conv(w*oj,kernel,'same');                                         % reconstruct
                
            end
            x_full{c}=xsig;
        end
        
        z=mean(cat(1,x_full{1},x_full{2}));                                                     % running mean across trials and conditions
        repz=cellfun(@(x,y) repmat(x,y,1),[{z};{z}],J,'UniformOutput',false);
        nsig=cellfun(@(x,z) x-z,x_full,repz,'UniformOutput',false);                             % deviation from the mean
        msig=cellfun(@mean, nsig,'UniformOutput',false);                                        % average across trials
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        cv_nm(cv,:)=msig{1};                                                              % collect across cv and perm
        cv_m(cv,:)=msig{2};
        
    end
    %%
    perm_nm(perm,:)=nanmean(cv_nm);                                                      % average across cross-validations
    perm_m(perm,:)=nanmean(cv_m);
    
end
  
% output
x_cv=zeros(2,size(perm_m,1),K);
x_cv(1,:,:)=perm_nm;
x_cv(2,:,:)= perm_m;


end

