% plot LDR in layers during test (average)
% plot the significance line from distribution of results of models with
% permutation

clear all 
close all
clc 

savefig=1;
period=2;

% figure settings
pos_vec=[0,0,14,12];
fs=10; 
lw=1.5;

blue=[0,0.48,0.74];
red=[0.85,0.32,0.1];
gray=[0.2,0.2,0.2];
col=[blue;red];    

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
namelay={'SG','G','IG'};

task=['plot_lay_regular_permuted_',namep{period}];
display(task)

savefile='/home/veronika/Dropbox/reconstruction/figures/layer/';
figname=['diff_layer_', namep{period}];

%% load results

addpath('/home/veronika/reconstruction/result/layer/regular/')

diff_regular=cell(3,2);
cf=zeros(3,2);

for ba=1:2
    
    loadname=['layer_',namea{ba},'_',namep{period}];
    load(loadname)
  
    diff_regular{1,ba}=squeeze(nanmean(x_sg(:,2,:)-x_sg(:,1,:)));                                                 % condition nm
    diff_regular{2,ba}=squeeze(nanmean(x_g(:,2,:) - x_g(:,1,:)));
    diff_regular{3,ba}=squeeze(nanmean(x_ig(:,2,:) - x_ig(:,1,:)));
    
end

%%

addpath('/home/veronika/v1v4/reconstruction/result/layer/permuted/')
diff_permuted=cell(3,2);

for ba=1:2
    
    loadname=['layer_perm_',namea{ba},'_',namep{period}];
    load(loadname)
    
    diff_permuted{1,ba}=squeeze(mean(x_sgp(:,:,2,:)-x_sgp(:,:,1,:)));
    diff_permuted{2,ba}=squeeze(mean(x_gp(:,:,2,:)-x_gp(:,:,1,:)));
    diff_permuted{3,ba}=squeeze(mean(x_igp(:,:,2,:)-x_igp(:,:,1,:)));
    
end

nperm=size(diff_permuted{1,1},1);
K=size(diff_permuted{1,1},2);

%% compute 95 % line

alpha=0.025/400;
idx=max([floor(alpha*nperm),1]);
lower_bound=cell(3,2);
upper_bound=cell(3,2);

for r=1:3
    for ba=1:2
        
        lb=zeros(K,1);
        ub=zeros(K,1);
        
        for k=1:K
            x=sort(diff_permuted{r,ba}(:,k));
            lb(k)=x(idx);
            ub(k)=x(end-idx);
        end
        
        lower_bound{r,ba}=lb;
        upper_bound{r,ba}=ub;
        
    end
end

%% plot

max_val=cellfun(@(x) max(max(x)),diff_regular);
maxy=1.1*max(max_val(:));

if period==1
    yt=-0.02:0.02:0.02;
else
    yt=0:0.05:0.1;
end

xt=0:200:400;

annotate={'A','B'};

xvec=1:K;

H=figure('name',figname);
for r=1:3
    for ba=1:2
        
        subplot(3,2,ba+(r-1)*2)
        hold on
        
        % 95 percent line
        
        y1=lower_bound{r,ba}';
        y2=upper_bound{r, ba}';
        
        y=diff_regular{r, ba};
        
        patch([xvec fliplr(xvec)], [y1 fliplr(y2)], gray,'FaceAlpha',0.3,'EdgeColor',[0.7,0.7,0.7])
        plot(y,'m','linewidth',lw)
        plot(1:400,zeros(400,1),'--','color',[0.2,0.2,0.2])
        hold off
        
        if r==1
            title(namea{ba},'FontName','Arial','fontsize',fs,'fontweight','normal')
        end
        box off
        if ba==2
            text(1.05,0.5,namelay{r},'units','normalized','FontName','Arial','fontsize',fs)
        end
        
        if period==1
            ylim([-maxy,maxy])
        else
            ylim([-0.05,maxy])
        end
        xlim([-2,K+2])
        
        set(gca,'YTick',yt)
        set(gca,'XTick',xt)
        set(gca,'XTickLabel',[])
        if ba==2
            set(gca,'YTickLabel',[])
        end
        if r==3
            set(gca,'XTickLabel',xt)
        end
  
        if ba==1&&r==1
            text(0.10,0.88,'regular','units','normalized','color','m','FontName','Arial','fontsize',fs)
            text(0.10,0.73,'permuted','units','normalized','color',gray,'FontName','Arial','fontsize',fs)
        end
        set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
        
    end
end

axes
text(-0.15,1.05,'B','units','normalized','FontName','Arial','fontsize',fs,'fontweight','bold')
h1 = xlabel ('Time (ms)','units','normalized','Position',[0.5,-0.08,0],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Difference of signals (a.u.)','units','normalized','Position',[-0.12,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h1,'visible','on')
set(h2,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)])

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end
    
    
