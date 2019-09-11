% plots LDR of models with permutation (weights, sign of weights, timing) in
% the two conditions

%clear all 
close all
clc 

savefig=0;

choose_perm={'1:permute_weight','2:permute_wsign','5:permute_amp', '3:permute_timing'};
perms=cellfun(@(x) x(3:end),choose_perm,'UniformOutput',false);

alpha=0.025;       % 5 percent
period=2;          % use the test time window

%%
pos_vec=[0,0,16,10];
savefile='/home/veronika/Dropbox/reconstruction/figures/all_neurons/';
figname='permutations';

namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};

fs=12; 
lw=1.5;

gray=[0.2,0.2,0.2];
blue=[0,0.48,0.74];
red=[0.85,0.32,0.1];
col=[blue;red];

%% load the permuted           
np=length(perms);
xnm_perms=cell(np,2);
xm_perms=cell(np,2);

for p=1:np
    
    addpath(['/home/veronika/reconstruction/result/all_neurons/',perms{p},'/'])
    for ba=1:2
        
        loadname=[perms{p},'_',namea{ba},'_',namep{period}];
        load(loadname)
       
        xnm_perms{p,ba}=squeeze(nanmean(x_nmp));                                        % non-match
        xm_perms{p,ba}=squeeze(nanmean(x_mp));                                          % match
        
    end
end
%%

K=size(x_nmp,3);
nperm=size(x_nmp,2);

%% compute the boundaries (leaving alpha percent on the top and on the bottom)

idx=floor(alpha*nperm);
lower_bound=cell(np,2);
upper_bound=cell(np,2);

for p=1:np
    for ba=1:2
        
        lb=zeros(K,2);
        ub=zeros(K,2);
        for k=1:K
            
            x=sort(xnm_perms{p,ba}(:,k));
            lb(k,1)=x(idx);
            ub(k,1)=x(end-idx);
            
            y=sort(xm_perms{p,ba}(:,k));
            lb(k,2)=y(idx);
            ub(k,2)=y(end-idx);
            
        end
        lower_bound{p,ba}=lb;
        upper_bound{p,ba}=ub;
        
    end
end


%% plot

titles={'weight','sign','modulus','timing'};

yt=-0.05:0.05:0.05;
xt=0:200:400;
x=1:K;

H=figure('name',figname);
for p=1:np
    for ba=1:2
        
        y1=lower_bound{p,ba}(:,1)';
        y2=upper_bound{p,ba}(:,1)';
        
        z1=lower_bound{p,ba}(:,2)';
        z2=upper_bound{p,ba}(:,2)';
        
        subplot(2,4,p+(ba-1)*4)
        hold on
        
        patch([x fliplr(x)], [y1 fliplr(y2)], col(1,:),'FaceAlpha',0.3,'EdgeColor', col(1,:))
        patch([x fliplr(x)], [z1 fliplr(z2)], col(2,:),'FaceAlpha',0.3,'EdgeColor', col(2,:))
        plot(1:K,zeros(400,1),'--','color',gray)
        
        hold off
        box off
        ylim([-0.11,0.11])
        xlim([0,K])
        set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
        
        set(gca,'YTick',yt)
        set(gca,'XTick',xt)
        
        set(gca,'XTickLabel',[])
        set(gca,'YTickLabel',[])
        
        if p==1
            set(gca,'YTickLabel',yt, 'FontName','Arial','fontsize',fs)
        end
        if ba==2
            set(gca,'XTickLabel',xt, 'FontName','Arial','fontsize',fs)
        end
        if ba==1&&p==1
            text(0.1,0.08, 'non-match', 'color', col(1,:),'units','normalized', 'FontName','Arial','fontsize',fs)
            text(0.2,0.18, 'match', 'color', col(2,:),'units','normalized', 'FontName','Arial','fontsize',fs)
        end
        %{
        if p==np
            text(1.05,0.5,namea{ba},'units','normalized','FontName','Arial','fontsize',fs)
        end
        %}
        if ba==1
            title(titles{p},'Fontweight','normal','FontName','Arial','fontsize',fs)
        end
        set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
        
    end
    
end

axes
text(-0.15,1.05,'A','units','normalized','FontName','Arial','fontsize',fs,'fontweight','bold')
h1 = xlabel ('Time (ms)','units','normalized','Position',[0.5,-0.08,0],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Population signal (a.u.)','units','normalized','Position',[-0.11,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end
