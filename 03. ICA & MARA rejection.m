close all
clear all

addpath('C:\Users\user\Desktop\eeglab2022.0')
addpath('C:\Program Files\MATLAB\R2019b\toolbox\signal\signal\')
addpath('C:\Program Files\MATLAB\R2019b\toolbox\stats\stats\')
root='D:\Drive\2 - Cue\';
pathLoadData = [root '\Rejected_trials\']
mkdir([root, '\ICA'])
pathSaveData=[root '\ICA\'];
mkdir([pathSaveData, '\additional_info'])
eeglab nogui
list=dir([path '\*.set'  ])
participants = length(list)


for s=[2:participants]
    try
        
        file=list(s).name;
        EEG = pop_loadset('filename',file,'filepath',path);
       
        
        EEG = pop_runica(EEG, 'icatype', 'runica', 'extended',1,'interrupt','on');
        [artcomps, info] = MARA(EEG);
        EEG.reject.MARAinfo = [info]
        EEG = pop_subcomp( EEG, artcomps, 0);
        
        EEG = pop_saveset( EEG, 'filename', file ,'filepath', pathSaveData);
        save([pathSaveData '\additional_info\MARA_components' file '.mat'], 'artcomps')
        save([pathSaveData '\additional_info\MARA_info' file '.mat'], 'info')
             
        
        fileID = fopen([root '\log.txt'],'a');
        fprintf(fileID, 'success in ICA\n\n');
        fprintf(fileID,'%s %s \n',list(s).name, '\n');
        fclose(fileID);
    catch
        warning('Something went wrong.');
        fileID = fopen([root '\log.txt'],'a');
        fprintf(fileID, 'Error in pipeline\n');
        fprintf(fileID,'%s %s \n',list(s).name, '\n');
        fclose(fileID);
    end
end