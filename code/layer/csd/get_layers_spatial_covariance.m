function csd_mat=get_layers_spatial_covariance(csd_matrix,session_name,visible,savefig,save_address,cut,before_stim)

%% determines borders of the granular layer with spatial covariance of the current surce density (csd)

% inputs: "csd_matrix" is a matrix of the shape (nb. recording channels x nb. time steps), computed as the second spatial derivative of the trial-averaged local field potential
% "session_name" is of the type "char" and is the name of the recording session
% "visible" is 1 for showing the figure and 0 for not showing the figure
% "savefig" is 1 for saving and 0 for not saving the figure
% "save_address" is the address for saving the figure
% "cut" is a vector with two entries [scalar 1, scalar 2]; scalar 1 and 2
% determine the beginning and the end of the period where the spatial
% covariance is estimated 
% "before_stim" is a scalar telling how many time steps are there before the
% stimulus appears

% outputs: "csd_mat" is the csd matrix, convolved with a 2-dimensional
% gaussian for smoothing, as used for the figure
% the function also outputs a figure
% figure: csd with the border between SG and G and between G and IG layers (left plot), 
% spatial covariance of the CSD (upper right)
% vector of the spatial covariance that passes through the global maximum
% (lower right)

% procedure:
% (1) filter the CSD matrix with 2-dim Gaussian filter
% (2) compute the spatial covariance of the CSD matrix and the global
% maximum (strongest current sink)
% (3) find the vector of the covariance that goes through the global
% maximum ("vec_s"). The global maximum is one of the peaks of that vector. Find a
% trough on the left and right side of that peak.
% (4) The crossing of the zero of the vector of covariance "vec_s" between the
% peak and the neighboring troughs determines the upper and the lower
% border of the granular layer.

%%

visibility={'off','on'};
npoints = 200; % number of points to plot in space
npoints_t=size(csd_matrix,2); % nb points in time

delta=50; % window for finding the troughs around the peak of the covariance vector

% extrapolates values from 16 channels into 200 spatial points

nElectrodes = size(csd_matrix,1);
el_pos=(0.1:0.1:1.6)/1000;
if (nElectrodes == 16)
  el_pos_plot=el_pos;
else
  el_pos_plot = el_pos(2:length(el_pos)-1); % if not Vaknin electrodes
end

le = length(el_pos_plot);
first_z = el_pos_plot(1)-(el_pos_plot(2)-el_pos_plot(1))/2; %plot starts at z1-h/2;
last_z = el_pos_plot(le)+(el_pos_plot(le)-el_pos_plot(le-1))/2; %ends at zN+h/2;
zs = first_z:(last_z-first_z)/(npoints-1):last_z;
el_pos_plot(le+1) = el_pos_plot(le)+(el_pos_plot(le)-el_pos_plot(le-1)); 

new_CSD_matrix=zeros(npoints,npoints_t);
j=1; 
for i=1:length(zs) % all new positions
    if zs(i)>(el_pos_plot(j)+(el_pos_plot(j+1)-el_pos_plot(j))/2) % > el_pos_plot(j) + h/2
        j = min(j+1,le);
    end
    new_CSD_matrix(i,:)=-csd_matrix(j,:);% Minus to have the right convention (sink = red with positive values)

end

%% (1) filter csd with Gaussian filter and normalize

mu = [0 0];
Sigma = [.5 -.2; -.2 .5];

x1 = -25:.2:25; 
x2 = -5:.2:5;
[X1,X2] = meshgrid(x1,x2);
F = mvnpdf([X1(:) X2(:)],mu,Sigma);
w = reshape(F,length(x2),length(x1));

Aconv=conv2(new_CSD_matrix,w,'same'); % convolution with Gaussian kernel

Anorm=Aconv./(max(abs(Aconv(:)))); % normalize between 1 and -1

%% (2) compute the spatial covariance of the CSD and the global max of the CSD 

As=Anorm(:,cut(1):cut(2)); % take the window of interest for the spatial cov
Cs=As*As'./(size(As,2)-1); % inner product (covariance) space
vars=diag(Cs); % diagonal (variance)

% global maximum 

[v, y1] = max(As); % global maximum ~ strongest sink
[~, xmax] = max(v); % time where there is sink
ymax = y1(xmax); % space where there is sink
%xplot=xmax+cut(1); %time index for the plot

%% (3) find troughs of the spatial covariance matrix

vec_s=Cs(ymax,:); % covariance vector that goes through the global maximum 

% trough on the right
if ymax+delta<size(As,1) 
    [~,idx_r]=min(vec_s(ymax:ymax+delta));
else
    [~,idx_r]=min(vec_s(ymax:end));
end

idx_trough=ymax+idx_r-1;

% trough on the left
if ymax-delta>1 
    [~,idx_l]=min(vec_s(ymax-delta:ymax));
    idx_trough2=idx_l+ymax-delta-1;
else
    [~,idx_l]=min(vec_s(1:ymax));
    idx_trough2=idx_l;
end

%{
ds=vec_s(ymax)-mean([vec_s(idx_trough),vec_s(idx_trough2)]); % peak to trough (mean across the peak-to trought on the left and on the right)
display(ds,'peak to trough')
%}
%% (4) determine borders with zeros of the vector of covariance

idx_a=find(diff(sign(vec_s(1:ymax)))>0); % find points where the covariance vector crosses the zero from below
idx_b=find(diff(sign(vec_s(ymax:end)))<0); % find points where is crosses from above

if isempty(idx_a)==1
    a=1;
else
    a=idx_a(end)+1; % take the last from the left
end

if isempty(idx_b)==1
    b=npoints;
else
    b=idx_b(1)+ymax; % take the first from the right
end

% lower and upper border of the granular layer
if b-a<100
    upper=a; 
    lower=b;
else 
    disp('too wide')
end

%% plot CSD with lower and upper border of the granular layer, covariance of the CSD, covariance vector of interest


deltax=41;
A_red=Anorm(deltax:end,:);

pos_vec=[0,0,12,10];

fs=10;
lw=1.5;
lwa=1;
%figname=session_name(1:end-8);
figname='csd';

H=figure('name',figname,'Visible',visibility{visible+1});

subplot(2,2,[1,3])
imagesc(A_red)
colormap jet
hold on

% borders of G layer
line([1,size(Anorm,2)],[lower-deltax,lower-deltax],'color',[0.5,0.5,0.5],'linewidth',2,'linestyle','--');
line([1,size(Anorm,2)],[upper-deltax,upper-deltax],'color',[0.5,0.5,0.5],'linewidth',2,'linestyle','--');

% annotate sink and sources
text(210,(lower-deltax+upper-deltax)/2,'sink','units','data','fontsize',fs,'fontname','Arial')
text(210,upper-deltax-15,'source','units','data','fontsize',fs,'fontname','Arial')
text(210,lower-deltax+15,'source','units','data','fontsize',fs,'fontname','Arial')

% annotate layers
text(380,(lower-deltax+upper-deltax)/2,'G','units','data','fontsize',fs,'fontname','Arial')
text(380,upper-deltax-10,'SG','units','data','fontsize',fs,'fontname','Arial')
text(380,lower-deltax+10,'IG','units','data','fontsize',fs,'fontname','Arial')

% delimits the stimulus time 
line([before_stim,before_stim],[0,size(Anorm,1)],'color','k','linewidth',1,'Linestyle','-.')
if size(Anorm,2)>500
    line([before_stim+300,before_stim+300],[0,size(Anorm,1)],'color','k','linewidth',1,'Linestyle','-.')
end
%
hold off

colormap jet
cb=colorbar;
cb.Limits=[-1,1];
cb.Ticks=[-1,1];
cb.FontSize=fs;
cb.Position;
cb.Position=[0.38, 0.7, 0.04, 0.2]; % [x,y,width, height]
title('CSD', 'fontsize',fs,'fontname','Arial', 'fontweight','normal')

% get ticks
z_ticks = get(gca,'YTick');
yt=[1,z_ticks(floor(length(z_ticks)/2)),z_ticks(end)];
ytl=[0,yt(2)/100,yt(3)/100];
set(gca,'YTick',yt)
set(gca,'YTickLabel',ytl,'fontsize',fs,'fontname','Arial')

xt=100:100:400;
set(gca,'XTick',xt)
set(gca,'XTickLabel',xt-200,'fontsize',fs,'fontname','Arial')
box off
xlim([160,450])

set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
ylabel('Relative depth (mm)' ,'FontName','Arial','fontsize',fs);
xlabel('Time from stim. (ms)','units','normalized','FontName','Arial','fontsize',fs);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

subplot(2,2,2)
imagesc(1:npoints,1:npoints,Cs);
hold on
%line([1,npoints],[1,npoints],'color',[0.5,0.5,0.5],'linewidth',lw-0.5);                            %diagonal
line([ymax,ymax],[1,npoints],'color','k','linewidth',lw+0.2);
hold off
 
text(ymax-65,ymax-100,'c_{max}','color','k','fontweight','bold','fontsize',fs,'fontname','Arial')
title('Covariance matrix', 'fontsize',fs,'fontname','Arial', 'fontweight','normal')

colormap jet
set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);

set(gca,'XTick',100)
set(gca,'YTick',100)

set(gca,'YTickLabel',ytl(2),'fontsize',fs,'fontname','Arial')
set(gca,'XTickLabel',ytl(2),'fontsize',fs,'fontname','Arial')

box off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

w_y=min(vec_s(idx_trough),vec_s(idx_trough2))-0.12;
w_x=(idx_trough+idx_trough2)/2-20;

subplot(2,2,4)
hold on

plot(1:npoints,vec_s,'k','linewidth',lw);

% peak and 2 troughs
plot(ymax,vars(ymax),'ko','MarkerFaceColor','r','Markersize',5,'Linewidth',1.5);

plot(idx_trough2,vec_s(idx_trough2),'ko','MarkerFaceColor','b','Markersize',5,'Linewidth',1.5)
plot(idx_trough,vec_s(idx_trough),'ko','MarkerFaceColor','b','Markersize',5,'Linewidth',1.5);

plot(zeros(1,length(vars)),'color',[0.5,0.5,0.5,0.5],'linewidth',lw,'linestyle','--')
hold off
box off

% annotate peaks and troughs
text(w_x,w_y,'sources','color','b','fontsize',fs,'fontname','Arial'); % troughts
text(ymax-10,vars(ymax)+0.15,'sink','color','r','fontsize',fs,'fontname','Arial')

set(gca,'YTick',[-0.5,0,0.5],'fontsize',fs,'fontname','Arial')
set(gca,'XTick',yt(2)+deltax-1)
set(gca,'XTickLabel',ytl(2),'fontsize',fs,'fontname','Arial')

xlim([deltax,npoints])
ylim([-0.5,0.5])
set(gca,'LineWidth',lwa,'TickLength',[0.025 0.025]);
xlabel('Relative depth (mm)','FontName','Arial','fontsize',fs)
ylabel('Covariance', 'FontName','Arial','fontsize',fs, 'units','normalized','Position',[-0.11,0.5,0])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

set(H, 'Units','centimeters', 'Position', pos_vec) % size of the figure
set(H,'PaperPositionMode','Auto','PaperUnits', 'centimeters','PaperSize',[pos_vec(3), pos_vec(4)])

if savefig==1
    saveas(H,[save_address,figname],'pdf');
end
if visible==0
    close(H)
end

csd_mat=Anorm; % numeric output

end