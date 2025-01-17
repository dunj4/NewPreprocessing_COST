% general settings
settings.paradigm = 5; % 1 - threshold; 2 - cue; 3 - mask; 4 - faces; 5 - scenes
settings.inverted = 1; % 1 for regression equation with X as magnitude and Y as responses; 0 for reg. eq. with X as responses and Y as magnitude
settings.intercept = 0; % 1 for equation with intercept included; 0 for equation without intercept & interactions

% topoplot cluster permutation test settings
settings.n_perm = 10000;
settings.fwer = .01;
settings.tail = 0;
settings.oldway = 0; % 0 for 4 topoplots [-800 -600; -600 -400; -400 -200; -200 0]; 1 for multiple topoplots with averaged timewindow (specified by settings.step)

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
if settings.inverted== 1 & settings.intercept== 1
    mkdir(pathTFData, 'betas_odwrotne_intercept');
    pathBETAS = [root '\tfdata\betas_odwrotne_intercept\']
    mkdir(pathBETAS, '\plots_odwrotne_intercept\');
    savepath = [pathBETAS '\plots_odwrotne_intercept\']
elseif settings.inverted== 1 & settings.intercept== 0
    mkdir(pathTFData, 'betas_odwrotne');
    pathBETAS = [root '\tfdata\betas_odwrotne\']
    mkdir(pathBETAS, '\plots_odwrotne\');
    savepath = [pathBETAS '\plots_odwrotne\']
elseif settings.inverted == 0 & settings.intercept== 1
    mkdir(pathTFData, 'betas_intercept');
    pathBETAS = [root '\tfdata\betas_intercept\']
    mkdir(pathBETAS, '\plots_intercept\');
    savepath = [pathBETAS '\plots_intercept\']
elseif settings.inverted== 0 & settings.intercept== 0
    mkdir(pathTFData, 'betas');
    pathBETAS = [root '\tfdata\betas\']
    mkdir(pathBETAS, '\plots\');
    savepath = [pathBETAS '\plots\']
end
addpath 'C:\Users\user\Desktop\eeglab-eeglab2021.0'
addpath 'C:\Program Files\MATLAB\R2019b\toolbox\stats\stats'

eeglab nogui

listBetas=dir([pathBETAS '*.mat'  ]);
listEEGData=dir([pathEEGData '*.set'  ]);
participants = length(listEEGData);




try
    
    load([root 'events.mat']);
    
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


for s=1:length(listBetas)
    
    file=listBetas(s).name;
    if  ~strcmp(file, 'betas.mat')
    B = regexp(file,'\d*','Match');
    if length(B) == 2
        participantID = str2num(B{1, 1});
        channel =  str2num(B{1, 2});
    elseif length(B) == 3
        participantID = str2num(B{1, 1});
        channel =  str2num(B{1, 3});
    end
    
    listBetas(s).participant = participantID;
    listBetas(s).channel = channel;
    
    C = regexp(file,'s_\w*_chann','Match');
    currentFile = C{1,1}(3:end-6);
    
    
    
    listBetas(s).(currentFile) = 1;
    end
end

fnames = fieldnames(listBetas)
fnames(1:8) = []


EEG = pop_loadset('filename',listEEGData(1).name,'filepath',pathEEGData);
chanlocs = EEG.chanlocs;
[~,~,~,times,freqs,~,~] = newtimef(EEG.data(1,:,:), EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate, [3 8], 'freqs', [6 40], 'baseline', NaN);
clear EEG ALLCOM ALLEEG LASTCOM CURRENTSET CURRENTSTUDY STUDY PLUGINLIST currentFile channel B C participantID s
close all

if settings.paradigm == 1
    % 16942_1; 19520_1; 19933_1; 37104_1; 41820_1; 45997_1; 82170_1;
    % 87808_1; 96269_1
    participants_to_drop = [5 6 7 37 40 46 88 101 117]; % due to the poor ICA decoposition
end
if settings.paradigm == 3
    %
    participants_to_drop = [128 129]; % due to the poor ICA decoposition
end
if settings.paradigm == 4
    % 35464_4; 52235_4; 72692_4; 79587_4; 91259_4; 95229_4;
    participants_to_drop = [17 30 50 54 67 69]; % due to the poor ICA decoposition
end

events(participants_to_drop) = [];
to_reject = any([listBetas.participant] == participants_to_drop');
listBetas(to_reject) = []

try
    
    load([pathBETAS 'betas.mat']); % this process (loading beta results [Participants X electrodes]) may take a while, so we will try to load all beta files
catch
    for s=1:length(listBetas)
        
        clear temp;
        participantID = listBetas(s).participant;
        channel = listBetas(s).channel;
        for i =1:length(fnames)
            if    listBetas(s).(fnames{i,1}) == 1
                temp = struct2cell(load([pathBETAS listBetas(s).name]));
                betas.(fnames{i,1})(participantID, channel, :,:) = temp{1,1};
            end
        end
        
        
        
        clear temp;
        display(['Processing ' num2str(s) ' out of: ' num2str(length(listBetas))]);
        
    end
    save([pathBETAS 'betas.mat'], 'betas','-v7.3');
end


for i = 1:length(fnames)
    if size(betas.(fnames{i, 1}), 1) < participants_to_drop(end)
        betas.(fnames{i, 1})(participants_to_drop(1:end-1), :,:,:) = []
    else
        betas.(fnames{i, 1})(participants_to_drop, :,:,:) = []
    end
end

elec.CP1 = find(strcmp({chanlocs.labels}, 'CP1')==1)	;
elec.CPz = find(strcmp({chanlocs.labels}, 'CPz')==1)	;
elec.CP2 = find(strcmp({chanlocs.labels}, 'CP2')==1)	;
elec.P1 = find(strcmp({chanlocs.labels}, 'P1')==1)		;
elec.P2 = find(strcmp({chanlocs.labels}, 'P2')==1)		;
elec.Pz = find(strcmp({chanlocs.labels}, 'Pz')==1)		;
elec.O1 = find(strcmp({chanlocs.labels}, 'O1')==1)		;
elec.Oz = find(strcmp({chanlocs.labels}, 'Oz')==1)		;
elec.O2 = find(strcmp({chanlocs.labels}, 'O2')==1)		;
elec.PO7 = find(strcmp({chanlocs.labels}, 'PO7')==1)	;
elec.PO8 = find(strcmp({chanlocs.labels}, 'PO8')==1)	;
elec.PO3 = find(strcmp({chanlocs.labels}, 'PO3')==1)	;
elec.PO4 = find(strcmp({chanlocs.labels}, 'PO4')==1)	;

electrodes = [elec.CP1 elec.CPz elec.CP2 elec.P1 elec.P2 elec.Pz elec.O1 elec.Oz elec.O2 elec.PO7 elec.PO8 elec.PO3 elec.PO4];


for n = 1:length(fnames)
    for i=1:size(betas.(fnames{n,1}), 1)
        if any((find(betas.(fnames{n,1})( i, :, :,:) == -Inf)))
            error(i) = 1;
            warning(['found -Inf in ' num2str(i)]); % there was a case, where 1 participant had error in TimeFrequency decomposition resulting in -Inf values
        else
            error(i) = 0;
        end; end
    betas.(fnames{n,1})(logical(error), :, :,:) = [];
end





addpath('C:\Program Files\MATLAB\R2019b\toolbox\signal\signal');
addpath('C:\Program Files\MATLAB\R2019b\toolbox\stats\stats');
addpath('C:\Program Files\MATLAB\R2019b\toolbox\images\images');
addpath 'C:\Users\user\Documents\GitHub\permutation calculation'; % folder with permutest.m


settings.clean_participants = 1:(length(listEEGData)-length(participants_to_drop));

chan_hood = spatial_neighbors(chanlocs(1:64), 40); % 40 mm distance between electrodes seems to be working with EEGLAB headset.
settings.freqs_roi = freqs>=8 & freqs<=14; % we are picking up our frequencies of intrest
settings.times_roi_topo = times>= - 800 & times <= 0; % we are picking up our times (ms) of interest // this is used only if settings.old_way == 1;


for n=1:length(fnames)
    
    betas.selected_electrodes.(fnames{n,1})(:, :, :) = permute(squeeze(mean(betas.(fnames{n,1})(settings.clean_participants, electrodes, :,:), 2, 'omitnan')), [2 3 1]);
    %betas.topoplot_all.(fnames{n,1}) = permute(squeeze(mean(betas.(fnames{n,1})(settings.clean_participants,:,settings.freqs_roi, settings.times_roi_topo), 3, 'omitnan')), [2, 3, 1]);
    if settings.oldway == 0
        betas.topoplot_all.(fnames{n,1}) = permute(squeeze(mean(betas.(fnames{n,1})(settings.clean_participants,:,settings.freqs_roi, :), 3, 'omitnan')), [2, 3, 1]);
    elseif settings.oldway == 1
        betas.topoplot_all.(fnames{n,1}) = permute(squeeze(mean(betas.(fnames{n,1})(settings.clean_participants,:,settings.freqs_roi, settings.times_roi_topo), 3, 'omitnan')), [2, 3, 1]);
    end
end

m = size(betas.selected_electrodes.(fnames{1,1}), 1);
n = size(times, 2);
b = size(betas.selected_electrodes.(fnames{1,1}), 3);
zero = zeros(m, n, b); % matrix of zeros, same size as data times, freqs, participants - used in permutation test


for n=1:length(fnames)
    tic
    display(['processing: ' (fnames{n,1})]);
    display(['permutations: ' num2str(settings.perm)]);
    display(['p_val: ' num2str(settings.p_val)]);
    display(['electrodes: ' num2str(electrodes)]);
    [cluster.(fnames{n,1}).cluster, cluster.(fnames{n,1}).p_values, cluster.(fnames{n,1}).t_sums, cluster.(fnames{n,1}).permutation_distribution ] = permutest(betas.selected_electrodes.(fnames{n,1})(:, :, :), zero, false, settings.p_val, settings.perm, true, inf);
    
    display(['done: ' (fnames{n,1})]);
    display(['found ' num2str(sum(cluster.(fnames{n,1}).p_values<0.05)) ' significant clusters in ' (fnames{n,1}) ' condition']);
    toc
end


if settings.oldway == 1
    for n=1:length(fnames)
        n1=1;
        last_val = 1;
        settings.step = 7; % step used in
        for k=1:settings.step:size(betas.topoplot_all.(fnames{n,1}), 2)
            
            betas.topoplot.(fnames{n,1})(:, n1, :) = squeeze(mean(betas.topoplot_all.(fnames{n,1})(:, last_val:k, :), 2, 'omitnan'));
            display(['k ' num2str(k) ' n1 ' num2str(n1) '  lastval ' num2str(last_val)]);
            
            n1=n1+1;
            last_val = k;
            
            betas.topoplot2.(fnames{n,1})(:, n1, :) = squeeze(mean(betas.topoplot_all.(fnames{n,1})(:, last_val:k, :), 2, 'omitnan'));
            
            
        end
        endclear n1 last_val k
    end
    % permutation test for topoplot
    for n=1:length(fnames)
        settings.final_topo_times = times(settings.times_roi);
        
        
        [pval, t_orig, clust_info, seed_state, est_alpha]=clust_perm1(betas.topoplot.(fnames{n,1}),chan_hood,settings.n_perm,settings.fwer,settings.tail);
        data_topo.(fnames{n,1}).clust_info = clust_info;
        data_topo.(fnames{n,1}).pval = pval;
        data_topo.(fnames{n,1}).t_orig = t_orig;
        clear pval t_orig clust_info seed_state est_alpha;
        
    end
end


if settings.oldway == 0
    settings.timewindow.minus800to600 = times>= - 800 & times <= - 600;
    settings.timewindow.minus600to400 = times>= - 600 & times <= - 400;
    settings.timewindow.minus400to200 = times>= - 400 & times <= - 200;
    settings.timewindow.minus200to0   = times>= - 200 & times <= 0;
    
    settings.final_topo_times = ["-800 -600" "-600 -400" "-400 -200" "-200 0"];
    for n=1:length(fnames)
        for i = 1:length(settings.final_topo_times) %length of timewindow
            if i == 1
                betas.topoplot.(fnames{n,1})(:, i, :) = squeeze(mean(betas.topoplot_all.(fnames{n,1})(:, settings.timewindow.minus800to600, :), 2, 'omitnan'));
            elseif i == 2
                betas.topoplot.(fnames{n,1})(:, i, :) = squeeze(mean(betas.topoplot_all.(fnames{n,1})(:, settings.timewindow.minus600to400, :), 2, 'omitnan'));
            elseif i == 3
                betas.topoplot.(fnames{n,1})(:, i, :) = squeeze(mean(betas.topoplot_all.(fnames{n,1})(:, settings.timewindow.minus400to200, :), 2, 'omitnan'));
            elseif i == 4
                betas.topoplot.(fnames{n,1})(:, i, :) = squeeze(mean(betas.topoplot_all.(fnames{n,1})(:, settings.timewindow.minus200to0, :), 2, 'omitnan'));
            end
        end
    end
    % permutation test for topoplot
    for n=1:length(fnames)
        
        [pval, t_orig, clust_info, seed_state, est_alpha]=clust_perm1(betas.topoplot.(fnames{n,1}),chan_hood,settings.n_perm,settings.fwer,settings.tail);
        data_topo.(fnames{n,1}).clust_info = clust_info;
        data_topo.(fnames{n,1}).pval = pval;
        data_topo.(fnames{n,1}).t_orig = t_orig;
        clear pval t_orig clust_info seed_state est_alpha;
        
    end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%% plotting %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear ALLCOM ALLEEG B CURRENTSET CURRENTSTUDY globalvars LASTCOM PLUGINLIST STUDY
ss=get(0, 'ScreenSize');
m = length(freqs);
n = size(times, 2);

beta = char(946);
frekwencje = string(int64(freqs));
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

% every_5th_element = [1:length(settings.times_roi)];
% every_5th_element(mod(every_5th_element,5) == 0) = 0;
% czasy3(every_5th_element~=0) = " ";
% clear every_5th_element


every_3d_element = [1:length(freqs)];
every_3d_element(mod(every_3d_element,3) == 0) = 0;
frekwencje(every_3d_element~=0) = " ";
clear every_3d_element





%% new plot - using contour * imagesc
for i=1:length(fnames)
    clear temp* mean_data n m
    % preparing data to plot
    
    m = length(freqs);
    n = size(times, 2);
    temp_data = betas.selected_electrodes.(fnames{i,1});
    mean_data = mean(temp_data, 3, 'omitnan');
    
    % finding significant clusters
    temp_cluster = cluster.(fnames{i, 1});
    temp_cluster = temp_cluster.cluster;
    idx_clusters = zeros(length(freqs)*size(times, 2), 1);
    signif_clusters = ([cluster.(fnames{i, 1}).p_values] <0.05);
    for k=1:sum(signif_clusters)
        idx_clusters(temp_cluster{1,k}) = 1;
    end
    idx_clusters2 = reshape(idx_clusters, [m n]);
    
    
    
    close all
    fig = figure('Position', [0 0 ss(3) ss(4)], 'Visible', 'off');
    
    imagesc(mean_data)
    %cb = colorbar;
    %cb.Limits = [settings.limits.down settings.limits.up]
    title(['\fontsize{32} ' beta ' coefficient - ' fnames{i,1}]);
    ylabel('\fontsize{28} Frequency [Hz]');
    xlabel('\fontsize{28} Times [ms]');
    h_ax = gca;
    h_ax.Colormap = jet;
    h_ax.FontSize = 24;
    h_ax.CLim = [settings.limits.down settings.limits.up]
    cb = cbar;
    cb.Position = [0.91124072204465,0.11,0.024725137830286,0.815];
    ylim([settings.limits.down settings.limits.up]);
    cb.YLabel.String = ['\fontsize{20}' beta ' coefficient'];
    cb.FontSize = 18;
    cb.YAxisLocation = 'right';
    cb.YLabel.VerticalAlignment = 'top';
    h_ax_c = axes('position', get(h_ax, 'position'), 'Color', 'none');
    contour(h_ax_c, idx_clusters2, 'levels', 1,  'LineColor', 'r', 'LineWidth', 1.5);
    set(h_ax_c, 'YDir','reverse') % for some reason, contour plots are reversed on Y axis and needs to be flipped
    h_ax_c.Color = 'none';
    h_ax_c.XTick = [];
    h_ax_c.YTick = [];
    h_ax.XTick = 1:length(czasy);
    h_ax.XTickLabel = czasy;
    h_ax.YTick = 1:length(frekwencje);
    h_ax.YTickLabel = frekwencje;
    h_ax.TickLength = [0, 0]; % again, for some reason, figure has markers on edges.
    xline(100.5)
    %
    
    saveas(fig,[savepath settings.prefix fnames{i,1} '.png']);
    saveas(fig,[savepath settings.prefix fnames{i,1} '.fig']);
    close all
    
    clear idx_clusters* signif_clusters*
    
    
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% TOPOPLOT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

settings.timesx = settings.final_topo_times;

fnames_topo= fields(data_topo);

for i=1:length(fnames_topo)
    clear temp* mean_data mask_nonsignificant to_plot mean_scalp signif_el mask_significant
    
    mask_nonsignificant = data_topo.(fnames_topo{i, 1}).pval <0.05
    to_plot = zeros(size(data_topo.(fnames_topo{i, 1}).pval  ));
    temp = squeeze(mean(betas.topoplot.(fnames_topo{i, 1}) , 3)); % mean across participants
    to_plot(mask_nonsignificant) = temp(mask_nonsignificant)
    heads_cols = 1  ;
    heads_rows = ceil(size(temp,2)/heads_cols);
    figure('Position', [0 0 ss(3) ss(4)], "Visible", "off"); hold on;
    t = tiledlayout(heads_cols, heads_rows, 'TileSpacing','normal');
    
    t.Padding = "normal"
    title(t,[ beta ' values - ' fnames_topo{i, 1}]);
    t.Title.FontSize = 30;
    t.Title.FontWeight = 'bold';
    
    
    for n=1:length(settings.timesx)
        nexttile;
        topoplot(to_plot(:, n), chanlocs(1:64));
        title([num2str(settings.timesx(n)) '  ms' ]);
        
    end
    for n=1:length(t.Children)
        t.Children(n).FontSize = 18;
        t.Children(n).TitleFontWeight = 'normal';
        t.Children(n).CLim = [settings.limits.down settings.limits.up]
    end
    
    %t.Children(8).Visible = 'off'
    cbar;
    ylim([settings.limits.down settings.limits.up]);
    t.Parent.Children(1).YLabel.String = [beta ' coefficient'];
    t.Parent.Children(1).YLabel.FontSize = 18;
    t.Parent.Children(1).YAxisLocation = 'right';
    t.Parent.Children(1).YLabel.VerticalAlignment = 'top';
    
    
    t.Parent.Children(1).FontSize = 20;
    t.Parent.Children(1).FontWeight = 'normal';
    t.Parent.Children(1).Position = [0.93 0.29 0.01 0.45];
    saveas(t,[savepath settings.prefix 'topo_betas' fnames_topo{i, 1} '.png']);
    saveas(t,[savepath settings.prefix 'topo_betas' fnames_topo{i, 1} '.fig']);
    close all
    clear t mask_nonsignificant to_plot
    
end


clear t heads* to_plot temp ss m n h_ax h_ax_c cb
