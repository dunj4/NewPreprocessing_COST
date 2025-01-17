settings.paradigm = 3;
settings.confirmatory = 1; % 0 - normal timefrequency decomposition [morlet, 3-8Hz for 6-40Hz, without baseline]; 1 - prooving that the frequencies are not smeared from the poststimulus period to prestimulus period [Balestrieri method]

addpath 'C:\Users\user\Desktop\eeglab-eeglab2021.0'
addpath 'C:\Program Files\MATLAB\R2019b\toolbox\stats\stats'
cd('C:\Program Files\MATLAB\R2019b\toolbox\stats\stats')
eeglab nogui
clear ALLCOM ALLEEG betas_all_participants CURRENTSET CURRENTSTUDY globalvars LASTCOM PLUGINLIST STUDY
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
pathLoadData= [root '\MARA\'];
list=dir([pathLoadData '*.set'  ]);
if settings.confirmatory == 0
    mkdir(root, 'tfdata');
    pathSaveData = [root '\tfdata\'];
elseif settings.confirmatory == 1
    mkdir(root, 'tfdata_confirmatory');
    pathSaveData = [root '\tfdata_confirmatory\'];
end

if settings.confirmatory == 0
    for s=[1:length(list)]
        file=list(s).name;
        EEG = pop_loadset('filename',file,'filepath',pathLoadData);
        clear ALLCOM ALLEEG betas_all_participants CURRENTSET CURRENTSTUDY globalvars LASTCOM PLUGINLIST STUDY
        clear tfdata
        tic
        for(i=1:64)
            [~, ~, ~, ~, ~, ~, ~, tfdata(:,:,:)] = newtimef(EEG.data(i,:,:), EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate, [3 8], 'freqs', [6 40], 'baseline', NaN);
            save([  pathSaveData '/tfdata_chan_' num2str(i) '_participant_' num2str(s)], 'tfdata', '-v7.3')  ;
            close all
        end
        toc
        display(['processing: ' num2str(s) ' out of ' num2str(length(list))]);
    end
    
elseif settings.confirmatory == 1
    
    for s=[1:length(list)]
        file=list(s).name;
        EEG = pop_loadset('filename',file,'filepath',pathLoadData);
        clear ALLCOM ALLEEG betas_all_participants CURRENTSET CURRENTSTUDY globalvars LASTCOM PLUGINLIST STUDY
        clear tfdata
        EEG = pop_select(EEG, 'channel', [1:64]);
        EEG2 = pop_select(EEG, 'time', [EEG.xmin 0])
        EEG_flipped = flip(EEG2.data, 2);
        
        
        EEG_combined= EEG;
        EEG_combined.data(:, 1:512, :) = EEG2.data;
        EEG_combined.data(:, 513:1024, :) = EEG_flipped;
        
        EEG = pop_select(EEG_combined, 'time', [EEG.xmin 0.500]);
        
        tic
       % [ersp,itc,powbase,times,freqs,erspboot,itcboot, tfdata(:,:,:)] = newtimef(EEG.data(i,:,:), EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate, [3 8], 'freqs', [6 40], 'baseline', NaN);
        for(i=1:64)
            [~, ~, ~, ~, ~, ~, ~, tfdata(:,:,:)] = newtimef(EEG.data(i,:,:), EEG.pnts, [EEG.xmin EEG.xmax]*1000, EEG.srate, [3 8], 'freqs', [6 40], 'baseline', NaN);
            save([  pathSaveData '/tfdata_chan_' num2str(i) '_participant_' num2str(s)], 'tfdata', '-v7.3')  ;
            close all
        end
        toc
        display(['processing: ' num2str(s) ' out of ' num2str(length(list))]);
    end
    
end