% plots low-dimensional reconstruction (all neurons) in all cases (target, delay, test in V1 and V4)

clear all 
close all
clc 

savefig=1;
period=1; % target or test

%%
namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namesign={'minus','plus'};
letter={'A','A'};

task=['plot LD sign ',namep{period}];
display(task)

savefile='/home/veronika/Dropbox/reconstruction/figures/sign/';
figname=['sign_sess_',namep{period}];
pos_vec=[0,0,13,9];

fs=10; % figure settings
lw=1.5;

blue=[0,0.48,0.74];
red=[0.85,0.32,0.1];
gray=[0.2,0.2,0.2];
col=[blue;red];    

%% load results

addpath('/home/veronika/reconstruction/result/sign/regular/')

xnm_all=cell(2,2);
xm_all=cell(2,2);


for ba=1:2
    
    loadname=['sign_',namea{ba},'_',namep{period}];
    load(loadname)
    
    xnm_all{1,ba}=squeeze(x_minus(:,1,:));                                                 % condition nm
    xnm_all{2,ba}=squeeze(x_plus(:,1,:));
    
    xm_all{1,ba}=squeeze(x_minus(:,2,:));                                                  % condition match
    xm_all{2,ba}=squeeze(x_plus(:,2,:));
    
end


%% mean and standard error of the mean

K=size(xm_all{1},2);                                                                            % number of time steps
nbses=size(xm_all{1,1},1);                                                                      % number of sessions

mnm=cellfun(@(x) nanmean(x),xnm_all,'UniformOutput',false);
mm=cellfun(@(x) nanmean(x),xm_all,'UniformOutput',false);
snm=cellfun(@(x) nanstd(x),xnm_all,'UniformOutput',false);
sm=cellfun(@(x) nanstd(x),xm_all,'UniformOutput',false);

%% plot

%{
max_val=cat(1,cellfun(@(x,y) max(x+(y./nbses)),mm,sm),cellfun(@(x,y) max(x+(y./nbses)),mnm,snm));
maxy=max(max_val(:)).*2;
if period ==1
    yt=-0.03:0.03:0.03;
else
    yt=-0.05:0.05:0.05;
end
%}
savefig=1
maxy=0.089;
yt=-0.05:0.05:0.05;

xt=0:200:400;
xvec=1:K;

H=figure('name',figname);
for ba=1:2
    for sgn=1:2
        subplot(2,2,ba+(sgn-1)*2)
        hold on
        
        % errorbars for the mean and the standard error of the mean(std(x)/sqrt(N))
        y1=mnm{sgn,ba}-snm{sgn,ba}./sqrt(nbses);
        y2=mnm{sgn,ba}+snm{sgn,ba}./sqrt(nbses);
        patch([xvec fliplr(xvec)], [y1 fliplr(y2)], blue,'FaceAlpha',0.3,'EdgeColor',blue)
        
        z1=mm{sgn,ba}-sm{sgn,ba}./sqrt(nbses);
        z2=mm{sgn,ba}+sm{sgn,ba}./sqrt(nbses);
        patch([xvec fliplr(xvec)], [z1 fliplr(z2)], red,'FaceAlpha',0.3,'EdgeColor',red)
        
        plot(1:400,zeros(400,1),'--','color',gray)
        
        hold off
        ylim([-maxy,maxy])
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
            text(0.2,0.9,namebeh{1},'units','normalized','color',col(1,:),'FontName','Arial','fontsize',fs)
            text(0.2,0.75,namebeh{2},'units','normalized','color',col(2,:),'FontName','Arial','fontsize',fs)
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

h2 = ylabel ('Population signal (a.u.)','units','normalized','Position',[-0.12,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h1,'visible','on')
if period==1
    set(h2,'visible','on')
else
    set(h2,'visible','on')
end
set(H, 'Units','centimeters', 'Position', pos_vec)                                                      % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)])      % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end
