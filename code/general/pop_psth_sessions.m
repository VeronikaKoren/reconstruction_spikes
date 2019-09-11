%% mean population psth in sessions from V1 or V4, from both monkeys
% average across all trials and across neurons, but keep reconrding
% sessions

clear all

saveres=1;
ba = 1;
beh=[1,3];

dt=1/1000;
time=1:999;

namea={'V1','V4'};

%% collect psths across sessions for target and test

if ba==1
    dnames = '/home/veronika/v1v4/data/V1_all/';
else
    dnames='/home/veronika/v1v4/data/V4_lay/';
end
fnames = dir([dnames filesep '*.mat']);
nbses=length(fnames);

% gaussian kernel
xw=-10:10;
mu=0;
sigma=10;
w=exp((-(xw-mu).^2)./(2*sigma));


psth_sess=cell(1,4);
for j=1:nbses
    
    s=load([dnames filesep fnames(j).name]);
    
    % concatenate layers
    for i=1:length(beh)
        if ba==1
            btar{i}=cat(2,s.spikes_tar{beh(i),:});
            btest{i}=cat(2,s.spikes_test{beh(i),:});
        else
            btar{i}=cat(2,s.spikes_tarV4_lay{beh(i),:});
            btest{i}=cat(2,s.spikes_testV4_lay{beh(i),:});
        end
    end
    
    b=cat(2,btar,btest); % 1:2 ~ tar, 3:4~ test
    
    average_trials = cellfun(@(x) squeeze(mean(x(:,:,time))),b,'UniformOutput',false);            % average across trials
    average_fr=cellfun(@(x) x./dt, average_trials,'UniformOutput',false);                         % firing rate
    pop=cellfun(@(x) mean(x,1), average_fr,'UniformOutput',false);                                % average across neurons
    
    padded=cellfun(@(x) [ones(1,20)*x(1,1),x,ones(1,20)*x(1,end)],pop, 'UniformOutput',false);    % pad with first and last values
    convolved=cellfun(@(x) conv(x,w,'same')./sum(w),padded, 'UniformOutput',false);               % convolve
    cut=cellfun(@(x) x(21:end-20), convolved, 'UniformOutput',false);                             % cut away the padded
   
    psth_sess=cellfun(@(x,xi) cat(1,x,xi),psth_sess,pop, 'UniformOutput',false);                  % collect across sessions
end

psth_sess=reshape(psth_sess,2,2);
%%
figure('visible','off')
plot(pop{1}(1,:))
hold on
plot(cut{1}(1,:))
%% save

if saveres==1
    savefile='/home/veronika/reconstruction/result/psth/';
    savename=['psth_',namea{ba}];
    save([savefile,savename],'psth_sess')
end
