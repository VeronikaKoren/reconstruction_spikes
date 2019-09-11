% plots cross-correlation function of + and - neurons in V1 and V4 during tar, delay and test

clear all 
close all
clc 

savefig=1;

task='plot sign correlation';
savefile='/home/veronika/Dropbox/reconstruction/figures/sign/';
figname='sign_corr';
pos_vec=[0,0,13,9];


fs=10; 
lw=1.5;

blue=[0,0.48,0.74];
red=[0.85,0.32,0.1];
gray=[0.2,0.2,0.2];
col=[blue;red];

%% load results

addpath('/home/veronika/reconstruction/result/sign/xcorr_2c/')
addpath('/home/veronika/Dropbox/reconstruction/code/functions/')

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};

corr_nm=cell(2,2);
corr_m=cell(2,2);

for ba=1:2
    for period=1:2
        
        loadname=['xcorr_sign_',namea{ba},'_',namep{period}];
        load(loadname)
        
        corr_nm{ba,period}=squeeze(r_sign(:,1,:));
        corr_m{ba,period}=squeeze(r_sign(:,2,:));
        
  
    end
end

nlag=size(corr_m{1},2);
K=(nlag+1)/2;
lags=-K+1:K-1;
nbses=[size(corr_m{1,1},1),size(corr_m{2,1},1)];

%% mean and std across sessions

mnm=cellfun(@(x) nanmean(x),corr_nm,'UniformOutput',false);
mm=cellfun(@(x) nanmean(x),corr_m,'UniformOutput',false);
snm=cellfun(@(x) nanstd(x),corr_nm,'UniformOutput',false);
sm=cellfun(@(x) nanstd(x),corr_m,'UniformOutput',false);

%% plot

mini=1.5*min(min(cellfun(@(x) x(K),mnm)));
maxi=2*max(max(cellfun(@(x) max(x),mnm)));
yt=-0.2:0.1:0;
xt=-300:300:300;

H=figure('name',figname);
for ba=1:2
    for period=1:2
        subplot(2,2,period+(ba-1)*2)
        hold on
        
        y1=mnm{ba,period}-snm{ba,period}./sqrt(nbses(ba));                           % mean +/- SEM
        y2=mnm{ba,period}+snm{ba,period}./sqrt(nbses(ba));
        patch([lags fliplr(lags)], [y1 fliplr(y2)], blue,'FaceAlpha',0.3,'EdgeColor',blue)
        
        z1=mm{ba,period}-sm{ba,period}./sqrt(nbses(ba));
        z2=mm{ba,period}+sm{ba,period}./sqrt(nbses(ba));
        patch([lags fliplr(lags)], [z1 fliplr(z2)], red,'FaceAlpha',0.3,'EdgeColor',red)
        
        plot(lags,zeros(nlag,1),'--','color',gray)
        
        hold off
        ylim([mini,0.05])
        xlim([-K,K])
        grid on
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
            text(0.06,0.3,namebeh{1},'units','normalized','color',col(1,:),'FontName','Arial','fontsize',fs)
            text(0.06,0.4,namebeh{2},'units','normalized','color',col(2,:),'FontName','Arial','fontsize',fs)
        end
        
        if period==2
            text(1.05,0.5,namea{ba},'units','normalized','FontName','Arial','fontsize',fs)
        end
        %}
        set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
        
    end
end

axes
text(-0.15,1.05,'D','units','normalized','FontName','Arial','fontsize',fs,'fontweight','bold')
h1 = xlabel ('Time lag (ms)','units','normalized','Position',[0.5,-0.08,0],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Correlation function','units','normalized','Position',[-0.11,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)])

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end


