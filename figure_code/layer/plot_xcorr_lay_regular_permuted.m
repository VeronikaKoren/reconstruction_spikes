% plots cross-correlation function of + and - neurons in V1 and V4 during target and test
% one condition
% regular and permuted

clear all 
close all
clc 

savefig=0;
period=2;

task='plot correlation across layers regular & permuted';
savefile='/home/veronika/Dropbox/reconstruction/figures/layer/';

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namelay={'SG','G','IG'};

figname=['lay_corr_rp_', namep{period}];
pos_vec=[0,0,13,9];
fs=10; 
lw=1.5;

gray=[0.7,0.7,0.7];

%% load results

addpath('/home/veronika/reconstruction/result/layer/xcorr_1c/')
addpath('/home/veronika/reconstruction/result/layer/xcorr_perm/')


%%
regular=cell(3,2);

for ba=1:2
    
    
    loadname=['xcorr_layer_',namea{ba},'_',namep{period}];
    load(loadname)
    
    for c=1:3
        regular{c,ba}=nanmean(squeeze(r_layer(:,c,:)));                                         % average across sessions
    end
    
    
end

nlag=size(regular{1},2);
K=(nlag+1)/2;
lags=-K+1:K-1;
L=length(lags);

%% load permuted

permuted=cell(3,2);

for ba=1:2
    
    
    loadname=['xcorr_layp_',namea{ba},'_',namep{period}];
    load(loadname)
    
    
    permuted{1,ba}=squeeze(nanmean(r_perm1));                                         % average across sessions
    permuted{2,ba}=squeeze(nanmean(r_perm2));
    permuted{3,ba}=squeeze(nanmean(r_perm3));
    
end

nperm=size(permuted{1},1);

%% upper and lower bound

alpha=0.025/K;
idx=max([floor(alpha*nperm),1]);
lower_bound=cell(3,2);
upper_bound=cell(3,2);

for d=1:3
    for ba=1:2
        
        lb=zeros(1,L);
        ub=zeros(1,L);
        for l=1:L
            x=sort(permuted{d,ba}(:,l));
            lb(l)=x(idx);
            ub(l)=x(end-(idx-1));
        end
        lower_bound{d,ba}=lb;
        upper_bound{d,ba}=ub;
        
    end
end
%}

%% plot


idx1=[1,1,2];
idx2=[2,3,3];
name2lay=cell(1,3);
for lc=1:3
    name2lay{lc}=[namelay{idx1(lc)},' & ',namelay{idx2(lc)}];
end

maxi=1.2*max(max(cellfun(@(x) max(x),regular)));
yt=[0,0.05];
xt=-300:300:300;

H=figure('name',figname,'visible','on');
for d=1:3
    for ba=1:2
        subplot(3,2,ba + (d-1)*2)
        hold on
        
        x=regular{d,ba};
        
        y1=lower_bound{d,ba};                           
        y2=upper_bound{d,ba};
        patch([lags fliplr(lags)], [y1 fliplr(y2)], gray,'FaceAlpha',0.5,'EdgeColor',gray)
        
        plot(lags,x,'m','linewidth',lw)
        
        hold off
        
        line([-K,K],[0 0],'linewidth', lw-1, 'color',gray,'linestyle','--'); % horizontal
        line([0,0],[-0.01 maxi],'linewidth', lw-1, 'color',gray,'linestyle','-');
        
        ylim([-0.02,maxi])
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
            text(0.08,0.8,'regular','units','normalized','color','m','FontName','Arial','fontsize',fs)
            text(0.08,0.62,'permuted','units','normalized','color',[0.3,0.3,0.3],'FontName','Arial','fontsize',fs)
        end
        if period==2
            if ba==2
                text(0.95,0.5,name2lay{d},'units','normalized','FontName','Arial','fontsize',fs)
            end
        end
        set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
        
    end
end

axes
if period==1
    text(-0.15,1.05,'A','units','normalized','FontName','Arial','fontsize',fs,'fontweight','bold')
end
h1 = xlabel ('Time lag (ms)','units','normalized','Position',[0.5,-0.07,0],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Correlation function','units','normalized','Position',[-0.1,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)])

if savefig==1
    saveas(H,[savefile,figname],'svg');
end


