
%% plots low-dimensional reconstruction of plus and minus neurons in V1 and V4 during target and test

clear all 
close all
clc 

savefig=1;
period=2;

%%

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namesign={'minus','plus'};
letter={'B','C'};

task=['plot diff sign ',namep{period}];
display(task)

savefile='/home/veronika/Dropbox/reconstruction/figures/sign/';
figname=['diff_sign_',namep{period}];
pos_vec=[0,0,13,9];

fs=10; % figure settings
lw=1.5;

blue=[0,0.48,0.74];
red=[0.85,0.32,0.1];
gray=[0.2,0.2,0.2];
col=[blue;red];    

%% load results

addpath('/home/veronika/reconstruction/result/sign/regular/')

diff=cell(2,2);

for ba=1:2
    
    loadname=['sign_',namea{ba},'_',namep{period}];
    load(loadname)
    
    diff{1,ba}=squeeze(nanmean(x_minus(:,2,:)-x_minus(:,1,:)))';                                                 % difference match - non-match
    diff{2,ba}=squeeze(nanmean(x_plus(:,2,:)-x_plus(:,1,:)))';
    
end

%% load permuted

addpath('/home/veronika/reconstruction/result/sign/permuted/')

diffp=cell(2,2);
for ba=1:2
    
    loadname=['sign_perm_',namea{ba},'_',namep{period}];
    load(loadname)
    
    diffp{1,ba}=squeeze(mean(x_minus(:,:,2,:) - x_minus(:,:,1,:)));                                            % match-non-match, average acrss sessions 
    diffp{2,ba}=squeeze(mean(x_plus(:,:,2,:) - x_plus(:,:,1,:)));
   
end

%% compute boundaries

K=size(diff{1},2);
alpha=0.025/K;
nperm=size(diffp{1},1);
idx=max([floor(alpha*nperm),1]);
lower_bound=cell(2,2);
upper_bound=cell(2,2);

for sgn=1:2
    for ba=1:2
        
        lb=zeros(1,K);
        ub=zeros(1,K);
        for k=1:K
            x=sort(diffp{sgn,ba}(:,k));
            lb(k)=x(idx);
            ub(k)=x(end-(idx-1));
        end
        lower_bound{sgn,ba}=lb;
        upper_bound{sgn,ba}=ub;
        
    end
end



%% plot

maxy=max(cell2mat(diff(:)))*1.3;

if period==1
    ylimit= [-0.07,0.07];
    yt=-0.05:0.05:0.05;
else
    ylimit= [-0.15,0.15];
    yt=-0.1:0.1:0.1;
end

xt=0:200:400;
xvec=1:K;

H=figure('name',figname);
for sgn=1:2
    for ba=1:2
        subplot(2,2,ba+(sgn-1)*2)
        hold on
        
        y1=lower_bound{sgn,ba};
        y2=upper_bound{sgn,ba};
        
        patch([xvec fliplr(xvec)], [y1 fliplr(y2)], gray,'FaceAlpha',0.3,'EdgeColor',gray)
        plot(diff{sgn,ba},'m','linewidth',lw)
        
        plot(1:400,zeros(400,1),'--','color',gray)
        
        hold off
        ylim(ylimit)
        xlim([-2,K+2])
        
        set(gca,'YTick',yt)
        set(gca,'XTick',xt)
        
        set(gca,'XTickLabel',[])
        set(gca,'YTickLabel',[])
        
        if sgn==2
            set(gca,'XTickLabel',xt)
        end
        if ba==1
            set(gca,'YTickLabel',yt)
        end
        
        if sgn==1
            title(namea{ba},'FontName','Arial','fontsize',fs,'fontweight','normal')
        end
        box off
        
        if sgn==1&&ba==1
            text(0.1,0.9,'regular','units','normalized','color','m','FontName','Arial','fontsize',fs)
            text(0.1,0.75,'permuted','units','normalized','color',gray,'FontName','Arial','fontsize',fs)
        end
        
        if ba==2
            text(1.05,0.5,namesign{sgn},'units','normalized','FontName','Arial','fontsize',fs)
        end
        
        set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
        
    end
end

axes
text(-0.15,1.05,letter{period},'units','normalized','FontName','Arial','fontsize',fs,'fontweight','bold')
h1 = xlabel ('Time (ms)','units','normalized','Position',[0.5,-0.08,0],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Difference of signals (a.u.)','units','normalized','Position',[-0.11,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h1,'visible','on')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec)                                                      % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)])      % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end
