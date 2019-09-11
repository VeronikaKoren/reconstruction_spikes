% plot population psths in sessions


clear all
close all
clc

savefig=1;

addpath('/home/veronika/reconstruction/result/general/psth/')

namep={'target','test'};
namea={'V1','V4'};
namebeh={'non-match','match'};

figname='pop_psth';
savefile='/home/veronika/reconstruction/figures/f1/';
pos_vec=[0,0,8,8];

%%
fs=9;
lw=1.5;% linewidth for plots
lwb=3; % width for the black bar
lwa=1;

blue=[0,0.48,0.74];
red=[0.85,0.32,0.1];
col=[blue;red];

%% load

upper=cell(2,2);
lower=cell(2,2);

for ba=1:2
    
    loadname=['psth_',namea{ba}];
    load(loadname)
    
    x=psth_sess;
    meanx=cellfun(@mean,x,'UniformOutput', false);
    semx=cellfun(@(x) std(x)./sqrt(size(x,1)),x,'UniformOutput', false);
    
    up=cellfun(@(m,s) m+s, meanx,semx, 'UniformOutput', false);
    low=cellfun(@(m,s) m-s, meanx,semx, 'UniformOutput', false);
    
    for ep=1:2
        upper{ba,ep}=cat(1,up{1,ep},up{2,ep});                                     % put the two conditions into the same cell
        lower{ba,ep}=cat(1,low{1,ep},low{2,ep});
    end

    
end

%% plot

maxy=80;
K=size(upper{1},2);
yt=0:30:60;

xt={[200,600],[100,500,900]};
xtl={[0,400],[-400,0,400]};
x=1:K;

xr=[200,500];
xw={200,[100,500]};
L=400;

H=figure('name',figname);
for ba=1:2
    for p=1:2
        subplot(2,2,p+(ba-1)*2)
        hold on
        
        % errorbars for the mean and the standard error of the mean(std(x)/sqrt(N))
        y1=upper{ba,p}(1,:);
        y2=lower{ba,p}(1,:);
        pp=patch([x fliplr(x)], [y1 fliplr(y2)], blue,'FaceAlpha',0.3,'EdgeColor',blue,'EdgeAlpha',0.5,'Linewidth',0.5);
        
        z1=upper{ba,p}(2,:);
        z2=lower{ba,p}(2,:);
        patch([x fliplr(x)], [z1 fliplr(z2)], red,'FaceAlpha',0.3,'EdgeColor',red,'EdgeAlpha',0.5,'Linewidth',0.5)
        
        rectangle('position',[xr(p) 10 300 65],'Linewidth',1.5,'Linestyle','-','EdgeColor',[1,1,0,0.3],'FaceColor',[1,1,0,0.2])
        
        % black bars to indicate windows used for analysis
        %{
        if p==1 
            plot(xw{p}:xw{1}+L-1,ones(1,L)*5,'k','Linewidth',lwb)  % target
            if ba==1
                text(xw{p}+100,12,'target','fontsize',fs,'fontname','Arial')
            end
        else
            plot(xw{2}(2):xw{2}(2)+L-1,ones(1,L)*5,'k','Linewidth',lwb) % test
            if ba==1
                text(xw{2}(2)+100,12,'test','fontsize',fs,'fontname','Arial')
            end
        end
        %}
        hold off
        
        ylim([0,maxy])
        xlim([-2,K+2])
        
        set(gca,'YTick',yt)
        set(gca,'XTick',xt{p})
        
        set(gca,'XTickLabel',[])
        set(gca,'YTickLabel',[])
        
        if ba==2
            set(gca,'XTickLabel',xtl{p}, 'FontName','Arial','fontsize',fs)
        end
        if p==1
            set(gca,'YTickLabel',yt, 'FontName','Arial','fontsize',fs)
        end
        
        if ba==1
            title(namep{p},'FontName','Arial','fontsize',fs,'fontweight','normal')
        end
        box off
        
        if ba==1&&p==1
            text(0.4,0.68,namebeh{1},'units','normalized','color',col(1,:),'FontName','Arial','fontsize',fs)
            text(0.4,0.8,namebeh{2},'units','normalized','color',col(2,:),'FontName','Arial','fontsize',fs)
        end
        if p==2
            text(1.05,0.5,namea{ba},'units','normalized','FontName','Arial','fontsize',fs)
        end
       
        set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
        
    end
end

axes
%text(-0.15,1.05,'D','units','normalized','FontName','Arial','fontsize',fs,'fontweight','bold')
h1 = xlabel ('Time (ms)','units','normalized','Position',[0.5,-0.08,0],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Spikes per second','units','normalized','Position',[-0.11,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec)                                                      % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)])      % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end

