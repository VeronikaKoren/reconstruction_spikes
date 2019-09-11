%% spike trains of all neurons in 3 example trials in condition 1 and 2

clear all

ba=2;
beh=[1,3];

savefig=1;

time=1:999;
ntr=3;                                                                              % how many trials to plot in each condition

figname='spike_trains';
savefile='/home/veronika/Dropbox/reconstruction/figures/f1/';
pos_vec=[0,0,8,8];

%%
namep={'target','test'};
namea={'V1','V4'};
namebeh={'non-match','match'};

blue=[0,0.48,0.74];
red=[0.85,0.32,0.1];

fs=9;
ms=5;
lwa=1;

%%

if ba==1
    dnames = '/home/veronika/v1v4/data/V1_all/';
else
    dnames = '/home/veronika/v1v4/data/V4_lay/';
end
fnames = dir([dnames filesep '*.mat']);
nbses=length(fnames);

display(['choose session from 1 to ', sprintf('%i',nbses)])
session=1;

s=load([dnames filesep fnames(session).name]);

if ba==1
    s1=s.spikes_test(beh(1),:);                                                        % take spike trains from a particular comp
    s2=s.spikes_test(beh(2),:);
else
    
    s1=s.spikes_testV4_lay(beh(1),:);
    s2=s.spikes_testV4_lay(beh(2),:);
end

col1=cellfun(@(x,y,z) cat(2,x,y,z),s1(1),s1(2),s1(3),'UniformOutput',false);            % concatenate layers
col2=cellfun(@(x,y,z) cat(2,x,y,z),s2(1),s2(2),s2(3),'UniformOutput',false);
cols=cat(1,col1,col2);

pcols=cellfun(@(x) x(randperm(size(x,1)),:,time), cols,'UniformOutput',false);          % take the time vector and permute the order of trials
pc=cellfun(@(x) x(1:ntr,:,:),pcols, 'UniformOutput',false);

ncell=size(pc{1,1},2);
ntime=length(time);

grid=meshgrid(1:ncell,1:ntime);
spikes=cell2mat(pc);
 
%% plot

cols={blue,red};
col=reshape(repmat(cols,ntr,1),2*ntr,1);
names={'NM','M'};
namebehs=reshape(repmat(names,ntr,1),2*ntr,1);

xtl=[0:300:600;-300:300:300];

H=figure('name',figname);
for c=1:2*ntr
    
    strain=squeeze(spikes(c,:,:)).*(grid');
    
    subplot(2*ntr,1,c)
    hold on
    rectangle('Position',[500,0,300,ncell],'FaceColor',[1,1,0,0.2],'EdgeColor','y','Linewidth',1)
    plot(1:ntime,strain,'.','color',col{c},'markersize',ms)
    hold off
    axis([300,1000,0.5,ncell+0.5])

    text(1.02,0.5,namebehs{c},'units','normalized','FontName','Arial','fontsize',fs)
      
    set(gca,'XTick',[100,500,900],'fontsize',fs, 'FontName','Arial')
    set(gca,'XTickLabel',[])
    if c==2*ntr 
        set(gca,'XTickLabel',[-400,0,400],'fontsize',fs,'FontName','Arial')
    end
    set(gca,'YTick',12)
    set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
    
end

axes;
h2 = ylabel ('Neuron index','units','normalized','Position',[-0.09,0.5,0],'FontName','Arial','fontsize',fs);
h1 = xlabel ('Time (ms)','units','normalized','Position',[0.5,-0.05,0],'FontName','Arial','fontsize',fs);

% make the global axis invisible
set(gca,'Visible','off');
set(h1,'visible','on')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end
       

%%
