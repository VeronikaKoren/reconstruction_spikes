
addpath('/home/veronika/reconstruction/result/layer/ncell/')

ba=2;
namea={'V1','V4'};
loadname3=['ncell_lay_',namea{ba}];
load(loadname3);

ncell_layers=sum(ncell_lay);
ncell_tot=sum(ncell_layers);

ncell_sessions=sum(ncell_lay,2);
average_ncell=mean(sum(ncell_lay,2));

%% number pf plus and minus neurons
addpath('/home/veronika/reconstruction/result/weights/w_mc/');

ba=2;
period=1;
namep={'target', 'test'};
loadname=['weight_',namea{ba},'_',namep{period}];
load(loadname)

percent_pos=mean(cellfun(@(x) numel(find(x>0))/numel(x), w_all));
