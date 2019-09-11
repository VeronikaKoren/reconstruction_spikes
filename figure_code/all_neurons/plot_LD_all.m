% plots low-dimensional reconstruction (all neurons) in all cases (target & test in V1 and V4)

clear all 
close all
clc 

savefig=0;

%%
namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};

task='plot LD all neurons';
savefile='/home/veronika/Dropbox/reconstruction/figures/all_neurons/';
figname='LD_all';

pos_vec=[0,0,12,9];

fs=10; 
lw=1.5;

blue=[0,0.48,0.74];
red=[0.85,0.32,0.1];
gray=[0.2,0.2,0.2];
col=[blue;red]; 

%np=2;
%% load results

addpath('/home/veronika/reconstruction/result/all_neurons/tau_20/')

xnm_all=cell(2,2);
xm_all=cell(2,2);

for ba=1:2
    for period=1:2
    
        loadname=['allneur_',namea{ba},'_',namep{period}];    
        load(loadname)
        
        xnm_all{ba,period}=x_nm;
        xm_all{ba,period}=x_m;
    end
end

%% mean and standard error of the mean

K=size(xm_all{1},2);                                                                            % number of time steps
nbses=[size(xm_all{1,1},1),size(xm_all{2,1},1)];                                                % number of sessions

mnm=cellfun(@(x) nanmean(x),xnm_all,'UniformOutput',false);
mm=cellfun(@(x) nanmean(x),xm_all,'UniformOutput',false);
snm=cellfun(@(x) nanstd(x),xnm_all,'UniformOutput',false);
sm=cellfun(@(x) nanstd(x),xm_all,'UniformOutput',false);

%% plot

  
max_val=cat(1,cellfun(@(x,y) max(x+(y./sqrt(10))),mm,sm),cellfun(@(x,y) max(x+(y./sqrt(10))),mnm,snm));
maxy=max(max_val(:)).*1.4;

yt=-0.05:0.05:0.05;
xt=0:200:400;
x=1:K;

H=figure('name',figname);
for ba=1:2
    for period=1:2
        subplot(2,2,period+(ba-1)*2)
        hold on
        
        % errorbars for the mean and the standard error of the mean(std(x)/sqrt(N))
        y1=mnm{ba,period}-snm{ba,period}./sqrt(nbses(ba));
        y2=mnm{ba,period}+snm{ba,period}./sqrt(nbses(ba));
        patch([x fliplr(x)], [y1 fliplr(y2)], blue,'FaceAlpha',0.3,'EdgeColor',blue)
        
        z1=mm{ba,period}-sm{ba,period}./sqrt(nbses(ba));
        z2=mm{ba,period}+sm{ba,period}./sqrt(nbses(ba));
        patch([x fliplr(x)], [z1 fliplr(z2)], red,'FaceAlpha',0.3,'EdgeColor',red)
        
        plot(1:400,zeros(400,1),'--','color',gray)
        
        hold off
        ylim([-maxy,maxy])
        xlim([-2,K+2])
        
        set(gca,'YTick',yt)
        set(gca,'XTick',xt)
        
        set(gca,'XTickLabel',[])
        set(gca,'YTickLabel',[])
        
        if ba==2
            set(gca,'XTickLabel',xt)
        end
        if period==1
            set(gca,'YTickLabel',yt)
        end
        
        if ba==1
            title(namep{period},'FontName','Arial','fontsize',fs,'fontweight','normal')
        end
        box off
        
        if ba==1&&period==1
            text(0.2,0.1,namebeh{1},'units','normalized','color',col(1,:),'FontName','Arial','fontsize',fs)
            text(0.2,0.25,namebeh{2},'units','normalized','color',col(2,:),'FontName','Arial','fontsize',fs)
        end
        
        if period==2
            text(1.05,0.5,namea{ba},'units','normalized','FontName','Arial','fontsize',fs)
        end
        %}
        set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
        
    end
end

axes
%text(-0.15,1.05,'A','units','normalized','FontName','Arial','fontsize',fs,'fontweight','bold')
h1 = xlabel ('Time (ms)','units','normalized','Position',[0.5,-0.08,0],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Population signal (a.u.)','units','normalized','Position',[-0.12,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec)                                                      % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)])      % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end
