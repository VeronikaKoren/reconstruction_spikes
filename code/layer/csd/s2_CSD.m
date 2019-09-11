%% s2 CSD

% generates CSD from s2 files
% uses "compute_csd" function from Marcello, & "plot_csd_matrix_mod" function adapted from Marcello
% first run "s2_trialseparator_LFP" to cut up trials to desired length (pre:post), ie. -200 to 500 ms .
% revcor stim starts at 0+pre,
% created by AA, 2017.03.17, modified from s4_revcor_csd
% get_layers_spatial_covariance for determining the granular layer from CSD by Veronika

clear
close


visible=1; %1=ON, show figures ; 0=OFF, close figures
savefig=1; %1=SAVE figs; 0=don't

session=9;
before_stim=200;                      % time before stimulus
cut=[before_stim+20,before_stim+100]; % where you want to evaluate sinks and sources; before_stim+30 is 230 ms from the beginning of recording 


addpath('/home/veronika/Dropbox/csd_codes/compute_csd/CSD/')
addpath('/home/veronika/Dropbox/csd_codes/compute_csd/CSDplotter-0.1.1/')
addpath('/home/veronika/Dropbox/csd_codes/compute_csd/CSDplotter-0.1.1/methods/')
%%
address ='/home/veronika/v1v4/data/data_ariana/lfp/align_test_v4_short/';
dnames=dir([address filesep '*.mat']);

save_address='/home/veronika/Dropbox/reconstruction/figures/layer/';

session_name=dnames(session).name;
load([address filesep session_name]);

asig1_lfp_allt=lfp_str.Lfp_V;

total_ch=size(asig1_lfp_allt,1); % channel count

%disp(total_ch)
ntime=length(asig1_lfp_allt{1,1}); % total time window
ntrial=size(asig1_lfp_allt,1); % trial count

%% PROBE 1
%{
% make average lfpMatrix compatible
for ch=1:16
    for t=1:ntrial
        ch_lfp(t,:)=asig1_lfp_allt{t,ch}';
    end
    averageLfpMatrix(ch,:)=mean(ch_lfp);
    clear ch_lfp
end

%calculate & plot CSD
file = sprintf('%s%s',num2str(filename(1:size(filename,2)-4)),'_CSD_probe1'); %make file name
csd_matrix= compute_csd_mm(averageLfpMatrix, true);

%plot_csd_matrix_mod(csd_matrix, averageLfpMatrix,file, visible, save);
get_layers(csd_matrix,file,visible,save,save_address,before_stim)
clear averageLFPMatrix csd_matrix  
%}
%% for multiple probes
 
%{
% PROBE 2
if total_ch>16
    for ch=17:32
        for t=1:ntrial
            ch_lfp(t,:)=asig1_lfp_allt{t,ch}';
        end
        averageLfpMatrix(ch-16,:)=mean(ch_lfp);
        clear ch_lfp
    end

    file = sprintf('%s%s',num2str(filename(1:size(filename,2)-4)),'_CSD_probe2'); %make file name
    csd_matrix= compute_csd_mm(averageLfpMatrix, true);
    %OUPutCSD=plot_csd_matrix_mod(csd_matrix, averageLfpMatrix,file, visible, save);
    get_layers(csd_matrix,file,visible,save,save_address,before_stim)
    clear averageLFPMatrix csd_matrix
end
%}
%% PROBE 3
%%{
if total_ch > 32
    for ch=33:48
        for t=1:ntrial
            ch_lfp(t,:)=asig1_lfp_allt{t,ch}';
        end
        averageLfpMatrix(ch-32,:)=mean(ch_lfp);
        clear ch_lfp
    end
    %name = sprintf('%s%s',num2str(session_name(1:size(session_name,2)-4)),'_CSD_probe3'); %make file name
    %csd_mat=get_layers_simple(csd_matrix,file,visible,save_fig,save_address,cut,before_stim);
    csd_matrix= compute_csd_mm(averageLfpMatrix, true);
    csd_mat=get_layers_spatial_covariance(csd_matrix,session_name,visible,savefig,save_address,cut,before_stim);
    %clear averageLfpMatrix csd_matrix
end

%}
%% PLOT lfp trace average across channels

%{
time_vec=1:1:ntime;
time_plt=(time_vec-200);
figure
plot(time_plt, median(averageLfpMatrix,1), 'k-')
title('Probe 1 - Average LFP')
xlabel('time (ms)')
ylabel('voltage (uv)')
%}

%{ 
% pick a file
filename = uigetfile; %select *LFP_cut.mat file
load (filename);
%}

