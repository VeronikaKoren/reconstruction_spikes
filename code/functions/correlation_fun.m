function [rxy] = correlation_fun(x,y)


%% cross-correlation function between signals in every trial 
% average across trials and across cross-validations

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ncv=size(x,1);
ntrial=size(x,2);
K=size(x,3);

%%

Rxy=zeros(ncv,ntrial,2*K-1);
for cv=1:ncv
     
    for j=1:ntrial
        
        xi=squeeze(x(cv,j,:));
        yi=squeeze(y(cv,j,:));
        
        Rxx_raw=xcorr(xi,xi);                                                     % autocorrelation 1
        Ryy_raw=xcorr(yi,yi);                                                     % autocorrelation 2
        
        Rxy_raw=xcorr(xi,yi);                                                     % cross-correlation
        Rxy(cv,j,:)=Rxy_raw./sqrt(Rxx_raw(K)*Ryy_raw(K));
        
    end
end

rxy=squeeze(nanmean(nanmean(Rxy,2),1));                                             % mean across trials and across cv

end


