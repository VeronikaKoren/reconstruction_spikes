% plots the distance between the signals x_nm and x_m
% compares the distance in case of the regular LDR and in case of LDR with a specified permutation

clear all 
close all
clc 

savefig=1;

alpha=0.05;                                                                % 2.5 percent on each tail of the distribution
namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};


% figure settings
pos_vec=[0,0,13,11];

savefile='/home/veronika/Dropbox/reconstruction/figures/all_neurons/';
figname='univariate';
disp(figname)

fs=10; 
lw=1.5;
gray=[0.2,0.2,0.2];
blue=[0,0.48,0.74];
red=[0.85,0.32,0.1];
col=[blue;red]; 
period=2;
                           
%% load results regular model

addpath('/home/veronika/reconstruction/result/univariate/')
xnm_all=cell(2,1);
xm_all=cell(2,1);

for ba=1:2
     
    loadname=['univar_',namea{ba},'_',namep{period}];
    load(loadname)
    
    xnm_all{ba}=x_nmu;
    xm_all{ba}=x_mu;
    
end

%%
diff=cellfun(@(x,y) squeeze(nanmean(x-y)),xm_all,xnm_all,'UniformOutput',false); % difference of signals [ x_m (t) - x_nm (t) ]

mnm=cellfun(@(x) nanmean(x),xnm_all,'UniformOutput',false);
mm=cellfun(@(x) nanmean(x),xm_all,'UniformOutput',false);
snm=cellfun(@(x) nanstd(x),xnm_all,'UniformOutput',false);
sm=cellfun(@(x) nanstd(x),xm_all,'UniformOutput',false);

Ntot=cellfun(@(x) size(x,1),xnm_all);

%% load the permuted  

diffp=cell(2,1);

for ba=1:2
    
    loadname=['uvarp_',namea{ba},'_',namep{period}];
    load(loadname,'mnp')
    
    diffp{ba}=mnp;
end

%%
K=size(diffp{1},2);
nperm=size(diffp{1},1);

%% compute the 99% line (leaving 2.5 percent on the top and on the bottom)

idx=max([1,floor(alpha*nperm)]);
lower_bound=cell(2,1);
upper_bound=cell(2,1);

for ba=1:2
    
    lb=zeros(K,1);
    ub=zeros(K,1);
    for k=1:K
        x=sort(diffp{ba}(:,k));
        lb(k)=x(idx);
        ub(k)=x(end-(idx-1));
    end
    lower_bound{ba}=lb;
    upper_bound{ba}=ub;
     
end

%% plot

yt=-0.01:0.01:0.01;
yt2=[0,0.02];

xt=0:200:400;
K=size(diff{1},2);
x=1:K;

H=figure('name',figname);
for ba=1:2
    
    subplot(2,2,ba)
    hold on
    
    % errorbars for the mean and the standard error of the mean(std(x)/sqrt(N))
    y1=mnm{ba}-snm{ba}./sqrt(Ntot(ba));
    y2=mnm{ba}+snm{ba}./sqrt(Ntot(ba));
    patch([x fliplr(x)], [y1 fliplr(y2)], blue,'FaceAlpha',0.3,'EdgeColor',blue)
    
    z1=mm{ba}-sm{ba}./sqrt(Ntot(ba));
    z2=mm{ba}+sm{ba}./sqrt(Ntot(ba));
    patch([x fliplr(x)], [z1 fliplr(z2)], red,'FaceAlpha',0.3,'EdgeColor',red)
    
    plot(1:400,zeros(400,1),'--','color',gray)
    hold off
    
    if ba==1
        text(0.1,0.95,'match','color',red,'units','normalized')
        text(0.1,0.85,'non-match','color',blue,'units','normalized')
    end
    title(namea{ba},'Fontweight','normal','FontName','Arial','fontsize',fs)
    ylim([-0.015,0.015])
    xlim([0,K])
    
    set(gca,'YTick',yt)
    set(gca,'XTick',xt)
    
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',[])
    
    if ba==1
        ylabel ('Signal (a.u.)','FontName','Arial','fontsize',fs);
        set(gca,'YTickLabel',yt)
    end
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    y1=lower_bound{ba}';
    y2=upper_bound{ba}';
    
    subplot(2,2,ba+2)
    hold on
  
    plot(x,diff{ba},'color','m','linewidth',lw)
    patch([x fliplr(x)], [y1 fliplr(y2)], gray,'FaceAlpha',0.3,'EdgeColor',gray)
    
    plot(1:K,zeros(400,1),'--','color',gray)
    
    hold off
    box off
    
    ylim([-0.01,0.03])
    xlim([0,K])
    
    
    set(gca,'YTick',yt2)
    set(gca,'XTick',xt)
    
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',[])
    
    if ba==1
        ylabel ('Diff. of signals (a.u.)','FontName','Arial','fontsize',fs);
        set(gca,'YTickLabel',yt2)
    end
    set(gca,'XTickLabel',xt)
    if ba==1
        text(0.1,0.9,'regular','color','m','units','normalized')
        text(0.1,0.8,'permuted','color',gray,'units','normalized')
    end
    
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
   
end

axes
text(-0.15,1.05,'B','units','normalized','FontName','Arial','fontsize',fs,'fontweight','bold')
h1 = xlabel ('Time (ms)','units','normalized','Position',[0.5,-0.08,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'svg');
end
    
   