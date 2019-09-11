% get number of neurons in the layer

ba=1; % 1 for V1 and 2 for V4
saveres=1;

namea={'V1','V4'};
ending={'_all','_lay'};
var={'spikes_tar','spikes_tarV4_lay'};
cvar=var{ba};

dname=['/home/veronika/v1v4/data/',namea{ba},ending{ba},'/'];

addpath(dname)
fname=dir([dname filesep '*.mat']);
nbses=length(fname);
%%
ncell_lay=zeros(nbses,3);
for sess=1:length(fname)
    
    s=load([dname filesep fname(sess).name],cvar);
    str=s.(cvar);
    ncell_lay(sess,:)=cellfun(@(x) size(x,2),str(1,:));
    
end
%%
if saveres==1 
    savename=['ncell_lay_',namea{ba}];
    savefile='/home/veronika/reconstruction/result/layer/ncell/';
    save([savefile,savename],'ncell_lay')
    
end
