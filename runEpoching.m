function runEpoching( paradigm, root,  epochLim)

% close all
% clear all
%  paradigm = 6; % 1 - threshold; 2 - cue; 3 - mask; 4 - faces; 5 - scenes; 6 - Kinga
% 
% 
% addpath('C:\Users\user\Desktop\eeglab2022.0')
% addpath('C:\Program Files\MATLAB\R2019b\toolbox\signal\signal\')
% addpath('C:\Program Files\MATLAB\R2019b\toolbox\stats\stats\')
% 
% 
% 
% if  paradigm == 1
%     root = 'D:\Drive\1 - Threshold\';
% elseif  paradigm == 2
%     root = 'D:\Drive\2 - Cue\';
% elseif  paradigm == 3
%     root = 'D:\Drive\3 - Mask\';
% elseif  paradigm == 4
%     root = 'D:\Drive\4 - Faces\';
% elseif  paradigm == 5
%     root = 'D:\Drive\5 - Scenes\';
% elseif  paradigm == 6
%     root='D:\Drive\6 - Kinga\';
% end

pathLoadData = [root '\Preprocessed_new_pipeline\']
mkdir([root, '\Epoching_EpochRejection'])
pathSaveData=[root '\Epoching_EpochRejection\'];
mkdir([pathSaveData, '\additional_info'])
eeglab nogui
list=dir([pathLoadData '\*.set'  ])
participants = length(list)


for s=[1:participants]
    %try
        
        clear idx
        file=list(s).name;
        EEG = pop_loadset('filename',file,'filepath',pathLoadData);
        
        
        
        
        
        
        if  paradigm == 1
            %EEG = events_threshold(EEG);
            EEG = pop_epoch( EEG, {'120', '121', '126', '127', '130', '131', '136', '137', '140', '141', '146', '147', '150', '151', '156', '157'},  epochLim, 'epochinfo', 'yes');
        elseif  paradigm == 2
            EEG = events_cue(EEG);
            EEG = pop_epoch( EEG, {'61', '62', '63', '64'},  epochLim, 'epochinfo', 'yes');
        elseif  paradigm == 3
            %EEG = events_mask(EEG);
            EEG = pop_epoch( EEG, {'101', '100', '106', '107'},  epochLim, 'epochinfo', 'yes');
        elseif  paradigm == 4
            %EEG = events_faces(EEG);
            EEG = pop_epoch( EEG, {'103', '104'},  epochLim, 'epochinfo', 'yes');
            
        elseif  paradigm == 5
            EEG = pop_epoch( EEG, {'20', '21', '120', '121', '40', '41', '140', '141', '80', '81', '180', '181', '30', '31', '130', '131', '50', '51', '150', '151', '90', '91', '190', '191'},  epochLim, 'epochinfo', 'yes');
            
        elseif  paradigm == 6
            addpath('C:\Users\user\Documents\GitHub\NewPreprocessing\helpers');
            [EEG, events_result] = events_Kinga(EEG);
            EEG = pop_epoch( EEG, { '55', '44', '33' },  epochLim, 'epochinfo', 'yes'); 
            %EEG = pop_selectevent( EEG, 'type',[55 44 33] ,'deleteevents','on','deleteepochs','on','invertepochs','off'); 
        end
        
            
        
        if paradigm == 2 
            EEG2 = pop_select(EEG, 'channel', {'HEOG', 'HEOG2'}) 
            EEG2 = pop_select(EEG2, 'time', [0 0.5]) % timewindow between cue onset and stimulus 
            epochs_vals = epoch_properties(EEG2, 1:2)
            %addpath('C:\Program Files\MATLAB\R2019b\toolbox\stats\stats\')
            zscored_epoch_vals = zscore(epochs_vals)
            to_reject_heog = find(sum( abs(zscored_epoch_vals)>2 ,2)) % 
            
            reject_idx_heog = zeros(size(EEG.data, 3), 1)
            reject_idx_heog(to_reject_heog) = 1
            EEG = pop_rejepoch( EEG, reject_idx_heog ,0);
            save([pathSaveData '\additional_info\removed_trials_heog_' file '.mat'], 'to_reject_heog')
            clear EEG2
        end
        
            %epochs_vals = epoch_properties(EEG, 1:size(EEG.data, 1))           % to run this line, you need to have FASTER plugin
            epochs_vals = epoch_properties(EEG, 1:64)           % to run this line, you need to have FASTER plugin
            addpath('C:\Program Files\MATLAB\R2019b\toolbox\stats\stats\')
            zscored_epoch_vals = zscore(epochs_vals)
            to_reject = find(sum( abs(zscored_epoch_vals)>2 ,2))
            
            reject_idx = zeros(size(EEG.data, 3), 1)
            reject_idx(to_reject) = 1
            EEG = pop_rejepoch( EEG, reject_idx ,0);
            
            
            
            EEG = pop_saveset( EEG, 'filename', file ,'filepath', pathSaveData);
            save([pathSaveData '\additional_info\removed_trials' file '.mat'], 'to_reject')
            
            
            fileID = fopen([root '\log_epoching.txt'],'a');
            fprintf(fileID, 'success \n\n');
            fprintf(fileID,'%s %s \n',list(s).name, '\n');
            fclose(fileID);

%     catch
%         warning('Something went wrong.');
%         fileID = fopen([root '\log_epoching.txt'],'a');
%         fprintf(fileID, 'Error in \n');
%         fprintf(fileID,'%s %s \n',list(s).name, '\n\n\n\n');
%         fclose(fileID);
%     end
end

end