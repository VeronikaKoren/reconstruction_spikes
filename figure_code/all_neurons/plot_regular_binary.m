% plots the distance between the signals x_nm and x_m
% compares the distance in case of the regular LDR and in case of LDR with a specified permutation

clear all 
close all
clc 

savefig=0;
showb=1;

choose_perm={'1:permute_weight','2:permute_wsign','3:permute_timing','4:permute_class'};
nameperms=cellfun(@(x) x(3:end),choose_perm,'UniformOutput',false);

perm_type=4;

alpha=0.001;                                                                % 2.5 percent on each tail of the distribution
namep={'target','test'};
namebeh={'non-match','match'};
namea={'V1','V4'};
nameperm=nameperms{perm_type};


np=2;

% figure settings
pos_vec=[0,0,12,9];
savefile='/home/veronika/Dropbox/reconstruction/figures/all_neurons/';

if showb==1
    figname='regular_binary';
else
    figname='regular_permuted';
end
disp(figname)

fs=10; 
lw=1.5;
gray=[0.2,0.2,0.2];

                           
%% load results regular model

addpath('/home/veronika/reconstruction/result/all_neurons/tau_20/')
xnm_all=cell(2,np);
xm_all=cell(2,np);

for ba=1:2
    for per=1:np
        loadname=['no_perm_',namea{ba},'_',namep{per}];
        %loadname=['allneur_',namea{ba},'_',namep{per}];
        load(loadname)
        
        xnm_all{ba,per}=x_nm;
        xm_all{ba,per}=x_m;
    end
    
end

diff=cellfun(@(x,y) squeeze(nanmean(x-y)),xm_all,xnm_all,'UniformOutput',false); % difference of signals [ x_m (t) - x_nm (t) ]

%% load results binary weights

addpath('/home/veronika/reconstruction/result/all_neurons/binary/')
xnm_all=cell(2,np);
xm_all=cell(2,np);

for ba=1:2
    for per=1:np
        
        loadname=['no_perm_',namea{ba},'_',namep{per}];
        %loadname=['allneur_',namea{ba},'_',namep{per}];
        load(loadname)
        
        xnm_all{ba,per}=x_nm;
        xm_all{ba,per}=x_m;
    end
    
end

diff_binary=cellfun(@(x,y) squeeze(nanmean(x-y)),xm_all,xnm_all,'UniformOutput',false); 
K=size(x_nm,2);
%% load the permuted  

addpath(['/home/veronika/reconstruction/result/all_neurons/',nameperm,'/'])

xnm_perms=cell(2,np);
xm_perms=cell(2,np);

for ba=1:2
    for per=1:np
        
        loadname=[nameperm,'_',namea{ba},'_',namep{per}];
        load(loadname)
        
        xnm_perms{ba,per}=x_nmp; % non-match
        xm_perms{ba,per}=x_mp;   % match
    end
end

diffp=cellfun(@(x,y) squeeze(nanmean(x-y)),xm_perms,xnm_perms,'UniformOutput',false); % difference between signals match and nonmatch with permutation


nperm=size(x_nmp,2);

%% compute the 99% line (leaving 2.5 percent on the top and on the bottom)

idx=floor(alpha*nperm);
lower_bound=cell(2,2);
upper_bound=cell(2,2);

for ba=1:2
    for per=1:np
        
        lb=zeros(K,1);
        ub=zeros(K,1);
        for k=1:K
            x=sort(diffp{ba,per}(:,k));
            lb(k)=x(idx);
            ub(k)=x(end-(idx-1));
        end
        lower_bound{ba,per}=lb;
        upper_bound{ba,per}=ub;
        
    end
end

%% plot
savefig=1
col={'m','b'};

yt=-0.1:0.1:0.2;
xt=0:200:400;

x=1:K;

H=figure('name',figname);
for ba=1:2
    for per=1:2
        
        subplot(2,2,per+(ba-1)*2)
        hold on
        
        y1=lower_bound{ba,per}';
        y2=upper_bound{ba,per}';
        
        plot(x,diff{ba,per},'color',col{1},'linewidth',lw)
        if showb==1
            plot(x,diff_binary{ba,per},'color',col{2},'linewidth',lw)
        end
        patch([x fliplr(x)], [y1 fliplr(y2)], gray,'FaceAlpha',0.3,'EdgeColor',gray)
        
        plot(1:K,zeros(400,1),'--','color',gray)
        
        hold off
        box off
        ylim([-0.07,0.15])
        xlim([0,K])
        set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
        
        set(gca,'YTick',yt)
        set(gca,'XTick',xt)
        
        set(gca,'XTickLabel',[])
        set(gca,'YTickLabel',[])
        
        if per==1
            set(gca,'YTickLabel',yt)
        end
        if ba==2
            set(gca,'XTickLabel',xt)
        end
        if ba==1&&per==1
            text(0.1,0.88,'regular','color',col{1},'units','normalized')
            if showb==1
                text(0.1,0.73,'binary weights','color',col{2},'units','normalized')
                text(0.1,0.58,'permuted','color',gray,'units','normalized')
            else
                text(0.1,0.68,'permuted','color',gray,'units','normalized')
            end
        end
        if per==2
            text(1.05,0.5,namea{ba},'units','normalized','FontName','Arial','fontsize',fs)
        end
        if ba==1
            title(namep{per},'Fontweight','normal','FontName','Arial','fontsize',fs)
        end
        
        set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
        
    end
    
end

axes
text(-0.15,1.05,'B','units','normalized','FontName','Arial','fontsize',fs,'fontweight','bold')
h1 = xlabel ('Time (ms)','units','normalized','Position',[0.5,-0.08,0],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Difference of signals (a.u.)','units','normalized','Position',[-0.11,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec)                                                          % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)])          % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'pdf');
end
    
   