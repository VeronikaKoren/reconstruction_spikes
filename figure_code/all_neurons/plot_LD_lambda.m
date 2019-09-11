% plots low-dimensional reconstruction (all neurons) in all cases (target, delay, test in V1 and V4)

clear all 
close all
clc 

savefig=1;
period=2;

%% figure settings

pos_vec=[0,0,13,10];

tau_prime=[10,20,50];

fs=10; 
lw=1.5;

blue=[0,0.48,0.74];
red=[0.85,0.32,0.1];
gray=[0.2,0.2,0.2];
col={'m','k',blue};

namea={'V1','V4'};
namelam={'10','20','50'};
namep={'target','test'};

task='plot_LD_lambda';
savefile='/home/veronika/Dropbox/reconstruction/figures/all_neurons/';
figname=['LD_lambda_', namep{period}];



%% load results

d_all=cell(2,3);

for ba=1:2
    for lam=1:3
        
        addpath(['/home/veronika/reconstruction/result/all_neurons/tau_', namelam{lam}])
        loadname=['no_perm_',namea{ba},'_',namep{period}];    
        load(loadname)
        
        d_all{ba,lam}=x_m-x_nm;
  
    end
end

%% mean and standard error of the mean

K=size(d_all{1},2);                                                                            % number of time steps
nbses=cellfun(@(x) size(x,1),d_all(:,1));                                                      % number of sessions

mean_d=cellfun(@mean,d_all,'UniformOutput', false);

%% normalization factor for convolution
                                                                                            
L=100;                                                                                      % length of the kernel                                  
tau=0:L;                                                                                    % support

norm_factor=zeros(3,1);
for tp=1:length(tau_prime)
    
    lambda=1/tau_prime(tp);                                                                        
    kernel=exp(-lambda.*tau); 
    norm_factor(tp)=sum(kernel);
end

scale_factor=norm_factor./norm_factor(end);

%% plot

namelambda={'10^{-1}','20^{-1}','50^{-1}'};

if period==2
    yt=[0.0,0.2];
else
    yt=[-0.1,0,0.1];
end
xt=0:200:400;
x=1:K;
pltidx=[1,3];

H=figure('name',figname);
for ba=1:2
    subplot(2,2,pltidx(ba))
    hold on
    for lam=1:3
        plot(1:K,mean_d{ba,lam},'color',col{lam},'linewidth',lw)
        if ba==1
            if period==2
                text(0.05,0.88 - 0.18*(lam-1),['\lambda=',namelambda{lam}],'color',col{lam},'units','normalized')
            else
                text(0+0.38*(lam-1) ,0.83,['\lambda=',namelambda{lam}],'color',col{lam},'units','normalized')
            end
        end
    end
    plot(1:K,zeros(K,1),'--','color',[0.5,0.5,0.5])
    hold off
    
    xlim([0,K])
    if period==1
        ylim([-0.2,0.2])
    else
        ylim([-0.1,0.4])
    end
    
    set(gca,'YTick',yt)
    set(gca,'XTick',xt)
    
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',yt)
   
    if ba==1
        title('not scaled','fontweight','normal','FontName','Arial','fontsize',fs)
    end
    if ba==2
        set(gca,'XTickLabel',xt)
    end
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    subplot(2,2,pltidx(ba)+1)
    hold on
    for lam=1:3
        plot(1:K,mean_d{ba,lam}./scale_factor(lam),'color',col{lam},'linewidth',lw)
    end
    plot(1:K,zeros(K,1),'--','color',[0.5,0.5,0.5])
    hold off
    
    text(1.05,0.5,namea{ba},'units','normalized','FontName','Arial','fontsize',fs)
    xlim([0,K])
    
    if period==1
        ylim([-0.2,0.2])
    else
        ylim([-0.1,0.4])
    end
    
    set(gca,'YTick',yt)
    set(gca,'XTick',xt)
    
    set(gca,'XTickLabel',[])
    set(gca,'YTickLabel',[])
    if ba==1
        title('scaled','fontweight','normal','FontName','Arial','fontsize',fs)
    end
    if ba==2
        set(gca,'XTickLabel',xt)
    end
    set(gca,'LineWidth',1.0,'TickLength',[0.025 0.025]);
    
end

axes
text(-0.15,1.05,'A','units','normalized','FontName','Arial','fontsize',fs,'fontweight','bold')
h1 = xlabel ('Time (ms)','units','normalized','Position',[0.5,-0.08,0],'FontName','Arial','fontsize',fs);
h2 = ylabel ('Difference of signals (a.u.)','units','normalized','Position',[-0.11,0.5,0],'FontName','Arial','fontsize',fs);
set(gca,'Visible','off')
set(h2,'visible','on')
set(h1,'visible','on')

set(H, 'Units','centimeters', 'Position', pos_vec) % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)]) % for saving in the right size

if savefig==1
    saveas(H,[savefile,figname],'svg');
end
