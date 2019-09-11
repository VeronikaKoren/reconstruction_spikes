% plots cross-correlation function for subnetworks of + and - neurons in V1 and V4 during target and test
% one condition
% regular and permuted

clear all 
close all
clc 

savefig=1;

task='plot correlation plus minus regular permuted';
savefile='/home/veronika/Dropbox/reconstruction/figures/sign/';

figname='sign_corr_rp';
pos_vec=[0,0,13,9];

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};

fs=10; 
lw=1.5;

blue=[0,0.48,0.74];
red=[0.85,0.32,0.1];
gray=[0.7,0.7,0.7];
col=[blue;red];

%% load results

addpath('/home/veronika/reconstruction/result/sign/xcorr_1c/')
addpath('/home/veronika/reconstruction/result/sign/xcorr_perm1c/')

regular=cell(2,2);
permuted=cell(2,2);

for ba=1:2
    for period=1:2
        
        loadname=['xcorr_sign_',namea{ba},'_',namep{period}];
        load(loadname)
        
        regular{ba,period}=nanmean(r_sign);                                         % average across sessions
        
        loadname2=['xcorr_perm_',namea{ba},'_',namep{period}];
        load(loadname2)
        permuted{ba,period}=squeeze(nanmean(r_perm));
    end
end

%%
nlag=size(regular{1},2);
K=(nlag+1)/2;
lags=-K+1:K-1;
L=length(lags);
nperm=size(permuted{1},1);

%% upper and lower bound

alpha=0.025/K;
idx=max([floor(alpha*nperm),1]);
lower_bound=cell(2,2);
upper_bound=cell(2,2);

for ba=1:2
    for per=1:2
        
        lb=zeros(L,1);
        ub=zeros(L,1);
        for l=1:L
            x=sort(permuted{ba,per}(:,l));
            lb(l)=x(idx);
            ub(l)=x(end-(idx-1));
        end
        lower_bound{ba,per}=lb;
        upper_bound{ba,per}=ub;
        
    end
end

%% plot

mini=1.2*min(min(cellfun(@(x) x(K),regular)));
maxi=2*max(max(cellfun(@(x) max(x),regular)));
yt=-0.2:0.1:0;
xt=-300:300:300;

H=figure('name',figname,'visible','on');
for ba=1:2
    for period=1:2
        subplot(2,2,period+(ba-1)*2)
        hold on
        
        x=regular{ba,period};
        y1=lower_bound{ba,period}';                           
        y2=upper_bound{ba,period}';
        patch([lags fliplr(lags)], [y1 fliplr(y2)], gray,'FaceAlpha',0.5,'EdgeColor',gray)
        
        plot(lags,zeros(nlag,1),'--','color',gray)
        plot(lags,x,'m','linewidth',lw)
        
        hold off
        ylim([-0.2,0.05])
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
        %}
        if ba==1
            title(namep{period},'FontName','Arial','fontsize',fs,'fontweight','normal')
        end
        box off
        
        if ba==1&&period==1
            text(0.10,0.25,'regular','units','normalized','color','m','FontName','Arial','fontsize',fs)
            text(0.10,0.15,'permuted','units','normalized','color',[0.3,0.3,0.3],'FontName','Arial','fontsize',fs)
        end
        if period==2
            text(1.05,0.5,namea{ba},'units','normalized','FontName','Arial','fontsize',fs)
        end
        
        set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
        
    end
end

axes
text(-0.15,1.05,'B','units','normalized','FontName','Arial','fontsize',fs,'fontweight','bold')
h1 = xlabel ('Time lag (ms)','units','normalized','Position',[0.5,-0.07,0],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Correlation function','units','normalized','Position',[-0.11,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)])

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end


