% general settings
settings.paradigm = 4; % 1 - threshold; 2 - cue; 3 - mask; 4 - faces; 5 - scenes

% topoplot cluster permutation test settings
settings.n_perm = 10000;
settings.fwer = .01;
settings.tail = 0;
settings.oldway = 0; % 0 for 4 topoplots [-800 -600; -600 -400; -400 -200; -200 0]; 1 for multiple topoplots with averaged timewindow (specified by settings.step)


settings.log10 = 0;
% cluster permutation test settings
settings.perm = 10000;
settings.p_val = 0.01;

% general plotting settings
settings.limits.up = 0.06;
settings.limits.down = -0.06;
settings.prefix = 'more_liberal_'; % additional prefix for naming plots


if settings.paradigm == 1
    root = 'D:\Drive\1 - Threshold\';
elseif settings.paradigm == 2
    root = 'D:\Drive\2 - Cue\';
elseif settings.paradigm == 3
    root = 'D:\Drive\3 - Mask\';
elseif settings.paradigm == 4
    root = 'D:\Drive\4 - Faces\';
elseif settings.paradigm == 5
    root = 'D:\Drive\5 - Scenes\';
end
pathTFData = [root '\tfdata\']
pathEEGData = [root '\MARA\']

mkdir(pathTFData, 'plots');
savepath = [pathTFData '\plots\']

addpath 'C:\Program Files\MATLAB\R2019b\toolbox\stats\stats'

eeglab nogui

listTFData=dir([pathTFData '*mat' ]);
listEEGData=dir([pathEEGData '*.set'  ]);
participants = length(listEEGData);




try
    
    load([root 'events.mat']);
    fileEEGData=listEEGData(1).name;
    EEG = pop_loadset('filename',fileEEGData,'filepath',pathEEGData);
    
catch
    for s=[1:participants]
        fileEEGData=listEEGData(s).name;
        EEG = pop_loadset('filename',fileEEGData,'filepath',pathEEGData);
        if settings.paradigm ==1
            EEG = pop_selectevent( EEG, 'type',[120 121 126 127 130 131 136 137 140 141 146 147 150 151 156 157] ,'deleteevents','on','deleteepochs','on','invertepochs','off');
        elseif settings.paradigm == 2
            EEG = pop_selectevent( EEG, 'type',[61 62 63 64] ,'deleteevents','on','deleteepochs','on','invertepochs','off');
        elseif settings.paradigm == 3
            EEG = pop_selectevent( EEG, 'type',[101 100 106 107] ,'deleteevents','on','deleteepochs','on','invertepochs','off');
        elseif settings.paradigm == 4
            EEG = pop_selectevent( EEG, 'type',[103 104] ,'deleteevents','on','deleteepochs','on','invertepochs','off');
        elseif settings.paradigm == 5
            
        end
        chanlocs_all{s} = EEG.chanlocs;
        events{s} = EEG.event;
    end
    save([root 'events.mat'], 'events');
end
clear ALLCOM ALLEEG CURRENTSET CURRENTSTUDY globalvars LASTCOM PLUGINLIST STUDY







[~,~,~,settings.times,settings.freqs,~,~] = newtimef(EEG.data(1,:,:), EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate, [3 8], 'freqs', [6 40], 'baseline', NaN);
clear temp data y* x* beta* EEG B file s
close all


try
    load([savepath 'tfdata_before_avg_highpas.mat']);
    load([savepath 'tfdata_before_avg_lowpas.mat']);
    load([savepath 'tfdata_before_avg_corr.mat']);
    load([savepath 'tfdata_before_avg_inc.mat']);
    if settings.paradigm == 4
        load([savepath 'tfdata_before_avg_fearfull.mat']);
        load([savepath 'tfdata_before_avg_neutral.mat']);
    end
catch
    for s=1:length(listTFData)
        participantID = listTFData(s).participant;
        channel = listTFData(s).channel;
        participant_event = events{participantID};
        temp = load([pathTFData listTFData(s).name]);
        data = abs(temp.tfdata);
        data = data(:,:,:);
        
        idx_highpas = [participant_event.pas] >= 3;
        idx_lowpas = [participant_event.pas] < 3;
        
        if settings.paradigm==1 | settings.paradigm == 4
            idx_corr = [participant_event.identification2] ==1;
            idx_inc = [participant_event.identification2] == 0;
        elseif settings.paradigm == 3
            idx_corr = [participant_event.corr_corr] == 1
            idx_inc = [participant_event.corr_corr] == 0
        end
        
        data_all_lowpas(participantID, channel, :, :) = squeeze(mean(data(:,:, idx_lowpas), 3));
        data_all_highpas(participantID, channel, :, :) = squeeze(mean(data(:,:, idx_highpas), 3));
        data_all_corr_id(participantID, channel, :, :) = squeeze(mean(data(:,:, idx_corr), 3));
        data_all_inc_id(participantID, channel, :, :) = squeeze(mean(data(:,:, idx_inc), 3));
        
        
        if settings.paradigm == 4
            idx_neutral = [participant_event.stimulus] == 103
            idx_fearful = [participant_event.stimulus] == 104
            data_all_fearful(participantID, channel, :, :) = squeeze(mean(data(:,:, idx_fearful), 3));
            data_all_neutral(participantID, channel, :, :) = squeeze(mean(data(:,:, idx_neutral), 3));
        end
        
        
        display(['currently processing: ' num2str(s) ' of ' num2str(length(listTFData)) ]);
    end
    save([savepath 'tfdata_before_avg_highpas.mat'], 'data_all_highpas');
    save([savepath 'tfdata_before_avg_lowpas.mat'], 'data_all_lowpas');
    save([savepath 'tfdata_before_avg_corr.mat'], 'data_all_corr_id');
    save([savepath 'tfdata_before_avg_inc.mat'], 'data_all_inc_id');
    if settings.paradigm == 4
        save([savepath 'tfdata_before_avg_fearfull.mat'], 'data_all_fearful');
        save([savepath 'tfdata_before_avg_neutral.mat'], 'data_all_neutral');
    end
    
    
end
fileEEGData=listEEGData(1).name;
EEG = pop_loadset('filename',fileEEGData,'filepath',pathEEGData);
chanlocs = EEG.chanlocs;
channels(1).M1 = find(strcmp({chanlocs.labels}, 'M1')==1);               %INDEX CHANNEL
channels.M2 = find(strcmp({chanlocs.labels}, 'M2')==1);              	%INDEX CHANNEL
channels.CP1 = find(strcmp({chanlocs.labels}, 'CP1')==1);
channels.CPz = find(strcmp({chanlocs.labels}, 'CPz')==1);
channels.CP2 = find(strcmp({chanlocs.labels}, 'CP2')==1);
channels.P1 = find(strcmp({chanlocs.labels}, 'P1')==1);
channels.Pz = find(strcmp({chanlocs.labels}, 'Pz')==1);
channels.P2 = find(strcmp({chanlocs.labels}, 'P2')==1);
channels.O1 = find(strcmp({chanlocs.labels}, 'O1')==1);
channels.Oz = find(strcmp({chanlocs.labels}, 'Oz')==1);
channels.O2 = find(strcmp({chanlocs.labels}, 'O2')==1);
channels.PO7 = find(strcmp({chanlocs.labels}, 'PO7')==1);
channels.PO8 = find(strcmp({chanlocs.labels}, 'PO8')==1);
channels.PO3 = find(strcmp({chanlocs.labels}, 'PO3')==1);
channels.PO4 = find(strcmp({chanlocs.labels}, 'PO4')==1);
channels.POz = find(strcmp({chanlocs.labels}, 'POz')==1);
channels.Iz = find(strcmp({chanlocs.labels}, 'Iz')==1);
channels.VEOG = find(strcmp({chanlocs.labels}, 'VEOG')==1);				 %INDEX CHANNEL
channels.HEOG = find(strcmp({chanlocs.labels}, 'HEOG')==1);				 %INDEX CHANNEL


settings.selected_channels = [channels.O1 channels.Oz channels.O2 channels.PO7 channels.PO8 channels.PO3 channels.PO4 channels.POz channels.Iz channels.P1 channels.Pz channels.P2];





%% TEST Z BASELINEM
clear data_all*
load([savepath 'tfdata_before_avg_highpas.mat']);
load([savepath 'tfdata_before_avg_lowpas.mat']);
load([savepath 'tfdata_before_avg_corr.mat']);
load([savepath 'tfdata_before_avg_inc.mat']);
if settings.paradigm == 4
    
    
    load([savepath 'tfdata_before_avg_neutral.mat']);
    load([savepath 'tfdata_before_avg_fearfull.mat']);
    
end
if settings.paradigm == 5
data_all_corr_id = data_all_corr_id_background;
data_all_inc_id = data_all_inc_id_background;
data_all_highpas = data_all_highpas_background;
data_all_lowpas = data_all_lowpas_background;

data_all_corr_id = data_all_corr_id_object;
data_all_inc_id = data_all_inc_id_object;
data_all_highpas = data_all_highpas_object;
data_all_lowpas = data_all_lowpas_object;


end
settings.baseline = [1:10];
for i = 1:size(data_all_corr_id, 1)
    for n = 1:size(data_all_corr_id, 2)
        for m = 1:size(data_all_corr_id, 3)
            if settings.log10 == 1
                data_all_corr_id_log = squeeze(abs(10*log10(data_all_corr_id(i,:,:,:))));
                baseline(n, m) = mean(data_all_corr_id_log(n,m, settings.baseline), 'omitnan');
                data_all_corr_id_new(i,n,m, :) = data_all_corr_id_log (n,m, :) - baseline( n, m);
                clear baseline;
                
                data_all_inc_id_log = squeeze(abs(10*log10(data_all_inc_id(i,:,:,:))));
                baseline(n, m) = mean(data_all_inc_id_log(n,m, settings.baseline), 'omitnan');
                data_all_inc_id_new(i,n,m, :) = data_all_inc_id_log (n,m, :) - baseline( n, m);
                clear baseline;
                
                data_all_highpas_log = squeeze(abs(10*log10(data_all_highpas(i,:,:,:))));
                baseline(n, m) = mean(data_all_highpas_log(n,m, settings.baseline), 'omitnan');
                data_all_highpas_new(i,n,m, :) = data_all_highpas_log (n,m, :) - baseline(n, m);
                clear baseline;
                
                data_all_lowpas_log = squeeze(abs(10*log10(data_all_lowpas(i,:,:,:))));
                baseline(n, m) = mean(data_all_lowpas_log(n,m, settings.baseline), 'omitnan');
                data_all_lowpas_new(i,n,m, :) = data_all_lowpas_log (n,m, :) - baseline(n, m);
                clear baseline;
                
                if settings.paradigm == 4
                    
                    baseline(i, n, m) = mean(data_all_fearful(i,n,m, settings.baseline), 'omitnan');
                    data_all_fearful(i,n,m, :) = data_all_fearful (i,n,m, :) - baseline(i, n, m);
                    clear baseline;
                    
                    
                    baseline(i, n, m) = mean(data_all_neutral(i,n,m, settings.baseline), 'omitnan');
                    data_all_neutral(i,n,m, :) = data_all_neutral (i,n,m, :) - baseline(i, n, m);
                    clear baseline;
                end
            else
                data_all_corr_id_log = squeeze(data_all_corr_id(i,:,:,:));
                baseline(n, m) = mean(data_all_corr_id_log(n,m, settings.baseline), 'omitnan');
                data_all_corr_id_new(i,n,m, :) = data_all_corr_id_log (n,m, :) - baseline( n, m);
                clear baseline;
                
                data_all_inc_id_log = squeeze(data_all_inc_id(i,:,:,:));
                baseline(n, m) = mean(data_all_inc_id_log(n,m, settings.baseline), 'omitnan');
                data_all_inc_id_new(i,n,m, :) = data_all_inc_id_log (n,m, :) - baseline( n, m);
                clear baseline;
                
                data_all_highpas_log = squeeze(data_all_highpas(i,:,:,:));
                baseline(n, m) = mean(data_all_highpas_log(n,m, settings.baseline), 'omitnan');
                data_all_highpas_new(i,n,m, :) = data_all_highpas_log (n,m, :) - baseline(n, m);
                clear baseline;
                
                data_all_lowpas_log = squeeze(data_all_lowpas(i,:,:,:));
                baseline(n, m) = mean(data_all_lowpas_log(n,m, settings.baseline), 'omitnan');
                data_all_lowpas_new(i,n,m, :) = data_all_lowpas_log (n,m, :) - baseline(n, m);
                clear baseline;
            end
            %display(['currently freq: ' num2str(m) ' for channel: ' num2str(n) ' for participant: ' num2str(i) ' out of: ' num2str(size(data_all_corr_id, 1)) ]);
               
        end
    end
    display(['currently participant: ' num2str(i) ' out of: ' num2str(size(data_all_corr_id, 1)) ]);
    %% deb8gging
    %     fig = figure('Position', [0 0 ss(3) ss(4)], 'Visible', 'off');
    %     heatmap(squeeze(mean(data_all_corr_id_new(i, settings.selected_channels,:,:), 2)));
    %     colormap jet
    %     grid off
    %     saveas(fig,[savepath '\debugging\' num2str(i) ' inc.png']);
    %     fig = figure('Position', [0 0 ss(3) ss(4)], 'Visible', 'off');
    %     heatmap(squeeze(mean(data_all_inc_id_new(i, settings.selected_channels,:,:), 2)));
    %     colormap jet
    %     grid off
    %     saveas(fig,[savepath '\debugging\' num2str(i) ' highpas.png']);
    %     fig = figure('Position', [0 0 ss(3) ss(4)], 'Visible', 'off');
    %     heatmap(squeeze(mean(data_all_highpas_new(i, settings.selected_channels,:,:), 2)));
    %     colormap jet
    %     grid off
    %     saveas(fig,[savepath '\debugging\' num2str(i) ' corr.png']);
    %     fig = figure('Position', [0 0 ss(3) ss(4)], 'Visible', 'off');
    %     heatmap(squeeze(mean(data_all_lowpas_new(i, settings.selected_channels,:,:), 2)));
    %     colormap jet
    %     grid off
    %     saveas(fig,[savepath '\debugging\' num2str(i) ' lowpas.png']);
end
    save([savepath 'highpas.mat'], 'data_all_highpas_new');
    save([savepath 'lowpas.mat'], 'data_all_lowpas_new');
    save([savepath 'corrid.mat'], 'data_all_corr_id_new');
    save([savepath 'incid.mat'], 'data_all_inc_id_new');

    if settings.paradigm == 4
    save([savepath 'fearful.mat'], 'data_all_fearful');
    save([savepath 'neutral.mat'], 'data_all_neutral');
    end
        
        

%% search for outliers
for i = 1: size(data_all_lowpas_new, 1)
    
    mean_vals(i).lowpas = mean(mean(mean( data_all_lowpas_new(i, settings.selected_channels,:,:), 2), 3), 4)
    mean_vals(i).highpas = mean(mean(mean( data_all_highpas_new(i, settings.selected_channels,:,:), 2), 3), 4)
    mean_vals(i).corr_id = mean(mean(mean( data_all_corr_id_new(i, settings.selected_channels,:,:), 2), 3), 4)
    mean_vals(i).inc_id = mean(mean(mean( data_all_inc_id_new(i, settings.selected_channels,:,:), 2), 3), 4)
    
end
%figure; histogram(mean_vals);

%heatmap(squeeze(mean(mean(data_baselined, 1, 'omitnan'), 2, 'omitnan'))); colormap jet


find([mean_vals.highpas] == min([mean_vals.highpas]))
find([mean_vals.highpas] == max([mean_vals.highpas]))

if settings.paradigm == 1
participants_to_drop = [5 6]
end
if settings.paradigm==3
    participants_to_drop = [99 82]
end
if settings.paradigm==4
    participants_to_drop = [53 61 62 63]
end
if settings.paradigm==5
    participants_to_drop = [34]
end
data_all_lowpas_new(participants_to_drop, :,:,:) = [];
data_all_highpas_new(participants_to_drop, :,:,:) = [];
data_all_corr_id_new(participants_to_drop, :,:,:) = [];
data_all_inc_id_new(participants_to_drop, :,:,:) = [];
if settings.paradigm == 4
    data_all_fearful(participants_to_drop, :,:,:) = [];
    data_all_neutral(participants_to_drop, :,:,:) = [];
end
events(participants_to_drop) = [];


%%

mean_all_corr_id = squeeze(mean(data_all_corr_id_new, 1, 'omitnan'));
mean_all_inc_id = squeeze(mean(data_all_inc_id_new, 1, 'omitnan'));
mean_all_highpas = squeeze(mean(data_all_highpas_new, 1, 'omitnan'));
mean_all_lowpas = squeeze(mean(data_all_lowpas_new, 1, 'omitnan'));
if settings.paradigm == 4
    mean_all_fearfull = squeeze(mean(data_all_fearful, 'omitnan'));
    mean_all_neutral = squeeze(mean(data_all_neutral, 'omitnan'));
end

selected_chann_corr_id = squeeze(mean(mean_all_corr_id(settings.selected_channels, :,:), 1, 'omitnan'));
selected_chann_inc_id =squeeze(mean(mean_all_inc_id(settings.selected_channels, :,:), 1, 'omitnan'));
selected_chann_highpas =squeeze(mean(mean_all_highpas(settings.selected_channels, :,:), 1, 'omitnan'));
selected_chann_lowpas =squeeze(mean(mean_all_lowpas(settings.selected_channels, :,:), 1, 'omitnan'));
if settings.paradigm == 4
    selected_chann_fearfull =squeeze(mean(mean_all_fearfull(settings.selected_channels, :,:), 1, 'omitnan'));
    selected_chann_neutral =squeeze(mean(mean_all_neutral(settings.selected_channels, :,:), 1, 'omitnan'));
end



ss=get(0, 'ScreenSize');
m = length(settings.freqs);
n = size(settings.times, 2);

frekwencje = string(int64(settings.freqs));

try
    
    load('C:\Users\user\Desktop\edited czasy decimal.mat'); % manually edited version of ([round(settings.times_roi,-1)])
catch
    czasy = ([round(settings.times_roi,-1)]);
end


for i = 1:length(czasy)
    if mod(czasy(i), 200) == 0 % selecting labels for X axis - every 200 ms;
        czasy2(i) = czasy(i);
    else
        czasy2(i) = 0;
    end
end
czasy3 = string(czasy2);
czasy3(czasy2==0) = " ";
czasy = czasy3;
czasy(100) = "0";

every_3d_element = [1:length(settings.freqs)];
every_3d_element(mod(every_3d_element,3) == 0) = 0;
frekwencje(every_3d_element~=0) = " ";
clear every_3d_element

% to_plot.raw_highpas = (10 * log10(selected_chann_highpas))
% to_plot.raw_lowpas = (10 * log10(selected_chann_lowpas))
% to_plot.raw_correct = (10 * log10(selected_chann_corr_id))
% to_plot.raw_incorrect =  (10 * log10(selected_chann_inc_id))
%
%
% to_plot.difference_objective = [(10 * log10(selected_chann_corr_id))      -      (10 * log10(selected_chann_inc_id))];
% to_plot.difference_subjective = [(10 * log10(selected_chann_highpas))      -      (10 * log10(selected_chann_lowpas))];
% if settings.paradigm == 4
% to_plot.raw_fearfull =(10 * log10(selected_chann_fearfull))
% to_plot.raw_neutral = (10 * log10(selected_chann_neutral))
%     to_plot.additional = [(10 * log10(selected_chann_fearfull))      -      (10 * log10(selected_chann_neutral))];
%
% end
to_plot.raw_highpas = selected_chann_highpas
to_plot.raw_lowpas = selected_chann_lowpas
to_plot.raw_correct = selected_chann_corr_id
to_plot.raw_incorrect =  selected_chann_inc_id


to_plot.difference_objective = [selected_chann_corr_id     -        selected_chann_inc_id];
to_plot.difference_subjective = [selected_chann_highpas      -      selected_chann_lowpas];
if settings.paradigm == 4
    to_plot.raw_fearfull =selected_chann_fearfull
    to_plot.raw_neutral = selected_chann_neutral
    to_plot.difference_fene = selected_chann_fearfull - selected_chann_neutral;
    
end
fnames = fieldnames(to_plot);


%% new plot - using contour * imagesc
for i=1:length(fnames)
    clear temp* mean_data n m
    % preparing data to plot
    
    m = length(settings.freqs);
    n = size(settings.times, 2);
    temp_data = to_plot.(fnames{i,1});
    settings.prefix = 'baseline';
    %temp_data = to_plot.(fnames{i,1})(1:8, :);
    fig = figure('Position', [0 0 ss(3) ss(4)], 'Visible', 'off');
    heatmap(temp_data, 'ColorLimits',[-1 1])
    if contains((fnames{i,1}), 'difference')
        heatmap(temp_data, 'ColorLimits',[-2 2])
    else
        heatmap(temp_data, 'ColorLimits',[-8 6])
    end
    %heatmap(temp_data)
    colormap('jet')
    grid off
    %xline(100.5)
    
    
    saveas(fig,[savepath settings.prefix fnames{i,1} '.png']);
    saveas(fig,[savepath settings.prefix fnames{i,1} '.fig']);
    close all
    
    clear temp_data
    
    
    
end


%
%
% figure;
% heatmap(selected_chann_corr_id-selected_chann_inc_id, 'ColorLimits',[-1 1])
% colormap('jet')
% grid off
%
% figure;
% heatmap(selected_chann_highpas-selected_chann_lowpas, 'ColorLimits',[-1 1])
% colormap('jet')
% grid off
%
% figure;
% heatmap(selected_chann_fearfull-selected_chann_neutral, 'ColorLimits',[-1 1])
% colormap('jet')
% grid off
%
%
%
%
%
% _________________________________________________________________________________________________________
% all_events=[]
% for i=1:length(events)
%
%
%     curr_events = events{i}
%
%     all_events = cat(2, all_events, curr_events)
%
% end
%
%
% for i=1:length(all_events)
%
% if isempty(all_events(i).pas)
% idx_remove(i) = 0;
% else
% idx_remove(i) = 1;
% end
% end
%
% all_events = all_events(logical(idx_remove));
%
% idx_highpas = [all_events.pas] <=2
% idx_lowpas = [all_events.pas] >= 3
% idx_corr = [all_events.identification2] == 1
% idx_incorr = [all_events.identification2] == 0
% idx_meutral = [all_events.stimulus] == 103
% idx_fearful = [all_events.stimulus] == 104
%
%
%
% idx_highpascorr = idx_highpas & idx_corr
% idx_lowpascorr = idx_lowpas & idx_corr
% idx_highpasinc = idx_highpas & idx_incorr
% idx_lowpasinc = idx_lowpas & idx_incorr
%
% idx_fe_highpas = idx_highpas & idx_fearful
% idx_fe_lowpas = idx_lowpas & idx_fearful
% idx_ne_highpas = idx_highpas & idx_meutral
% idx_ne_lowpas = idx_lowpas & idx_meutral
%
% bar([sum(idx_fe_highpas) sum(idx_fe_lowpas) sum(idx_ne_highpas) sum(idx_ne_lowpas)])
%
% bar([sum(idx_highpas) sum(idx_lowpas)])