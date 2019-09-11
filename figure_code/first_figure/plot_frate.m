% plot population psths in sessions


clear all
close all
clc

savefig=1;

addpath('/home/veronika/reconstruction/result/general/frate/')

namep={'target','test'};
namea={'V1','V4'};
namebeh={'non-match','match'};

figname='frate';
savefile='/home/veronika/Dropbox/reconstruction/figures/f1/';
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

fr_sorted=cell(2,2);

for ba=1:2
    
    for period=1:2
    
        loadname=['frate_',namea{ba},'_',namep{period}];
        load(loadname)
   
        [val,order]=sort(fr_m);
        new_order=flip(order);
        fr_sorted{ba,period}= cat(1, fr_nm(new_order), fr_m(new_order));
        
        
    end
end

%% plot

maxy=80;

yt=0:30:60;
xt={[80,160],[50,100]};

H=figure('name',figname);
for ba=1:2
    for p=1:2
        
        x=fr_sorted{ba,p}(1,:);
        y=fr_sorted{ba,p}(2,:);
        
        
        subplot(2,2,p+(ba-1)*2)
        hold on
        plot(x,'color',blue, 'linewidth',lw)
        plot(y,'color', red)
        hold off
        
        ylim([0,maxy])
        xlim([0,length(x)])
        
        set(gca,'YTick',yt)
        set(gca,'XTick',xt{ba})
        
        %set(gca,'XTickLabel',[])
        set(gca,'YTickLabel',[])
        
        
        set(gca,'XTickLabel',xt{ba}, 'FontName','Arial','fontsize',fs)
       
        if p==1
            set(gca,'YTickLabel',yt, 'FontName','Arial','fontsize',fs)
        end
        
        if ba==1
            title(namep{p},'FontName','Arial','fontsize',fs,'fontweight','normal')
        end
        box off
        %}
        if ba==1&&p==1
            text(0.3,0.68,namebeh{1},'units','normalized','color',col(1,:),'FontName','Arial','fontsize',fs)
            text(0.3,0.8,namebeh{2},'units','normalized','color',col(2,:),'FontName','Arial','fontsize',fs)
        end
        if p==2
            text(1.05,0.5,namea{ba},'units','normalized','FontName','Arial','fontsize',fs)
        end
       
        set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
        
    end
end

axes
%text(-0.15,1.05,'D','units','normalized','FontName','Arial','fontsize',fs,'fontweight','bold')
h1 = xlabel ('Neuron index (sorted)','units','normalized','Position',[0.5,-0.08,0],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Spikes per second','units','normalized','Position',[-0.11,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec)                                                      % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)])      % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'svg');
end

