% plots cross-correlation function of + and - neurons in V1 and V4 during tar, delay and test

clear all 
close all
clc 

savefig=1;
period=2;

task='plot correlation layers 2 conditions';
savefile='/home/veronika/Dropbox/reconstruction/figures/layer/';

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namelay={'SG','G','IG'};
letter={'B','C'};

figname=['lay_corr_', namep{period}];
pos_vec=[0,0,13,9];
fs=10; 
lw=1.5;

blue=[0,0.48,0.74];
red=[0.85,0.32,0.1];
gray=[0.7,0.7,0.7];
col=[blue;red];

%% load results

addpath('/home/veronika/reconstruction/result/layer/xcorr_2c/')

corr_nm=cell(3,2);
corr_m=cell(3,2);

for ba=1:2
    
    loadname=['xcorr_lay2c_',namea{ba},'_',namep{period}];
    load(loadname)
    
    for d=1:3
        corr_nm{d,ba}=squeeze(r_layer(:,d,1,:));
        corr_m{d,ba}=squeeze(r_layer(:,d,2,:));
    end
end

%%
nlag=size(corr_nm{1},2);
K=(nlag+1)/2;
lags=-K+1:K-1;
nbses=[size(corr_nm{1,1},1),size(corr_nm{1,2},1)];

mnm=cellfun(@(x) nanmean(x),corr_nm,'UniformOutput',false);
mm=cellfun(@(x) nanmean(x),corr_m,'UniformOutput',false);
snm=cellfun(@(x) nanstd(x),corr_nm,'UniformOutput',false);
sm=cellfun(@(x) nanstd(x),corr_m,'UniformOutput',false);

%% plot

idx1=[1,1,2];
idx2=[2,3,3];
name2lay=cell(1,3);
for lc=1:3
    name2lay{lc}=[namelay{idx1(lc)},'  & ',namelay{idx2(lc)}];
end

maxi=1.5*max(max(cellfun(@(x) max(x),mnm)));

yt=[0, 0.1];
xt=-300:300:300;

H=figure('name',figname);
for ba=1:2
    for d=1:3
        subplot(3,2,ba+(d-1)*2)
        hold on
        
        y1=mnm{d,ba}-snm{d,ba}./sqrt(nbses(ba));                           % mean +/- SEM
        y2=mnm{d,ba}+snm{d,ba}./sqrt(nbses(ba));
        patch([lags fliplr(lags)], [y1 fliplr(y2)], blue,'FaceAlpha',0.3,'EdgeColor',blue)
        
        z1=mm{d,ba}-sm{d,ba}./sqrt(nbses(ba));
        z2=mm{d,ba}+sm{d,ba}./sqrt(nbses(ba));
        patch([lags fliplr(lags)], [z1 fliplr(z2)], red,'FaceAlpha',0.3,'EdgeColor',red)
        
        line([-K,K],[0 0],'linewidth', lw-1, 'color',gray,'linestyle','--'); % horizontal
        line([0,0],[-0.01 maxi],'linewidth', lw-1, 'color',gray,'linestyle','-');
        %plot(lags,zeros(nlag,1),'--','color',gray)
        
        hold off
        ylim([-0.01,maxi])
        xlim([-K,K])
        
        set(gca,'YTick',yt)
        set(gca,'XTick',xt)
        
        set(gca,'XTickLabel',[])
        set(gca,'YTickLabel',[])
        
        if d==3
            set(gca,'XTickLabel',xt)
        end
        if ba==1
            set(gca,'YTickLabel',yt)
        end
        
        if d==1
            title(namea{ba},'FontName','Arial','fontsize',fs,'fontweight','normal')
        end
        box off
        
        if ba==1&&d==1
            text(0.08,0.8,namebeh{1},'units','normalized','color',col(1,:),'FontName','Arial','fontsize',fs)
            text(0.08,0.62,namebeh{2},'units','normalized','color',col(2,:),'FontName','Arial','fontsize',fs)
        end
        
        if ba==2
            text(0.95,0.5,name2lay{d},'units','normalized','FontName','Arial','fontsize',fs)
        end
        
        set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
        
    end
end

axes
text(-0.15,1.05,letter{period},'units','normalized','FontName','Arial','fontsize',fs,'fontweight','bold')
h1 = xlabel ('Time lag (ms)','units','normalized','Position',[0.5,-0.08,0],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Correlation function','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)])

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end


