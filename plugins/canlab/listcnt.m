% This script utilizes the pop_loadcnt() function to import all of the cnt
% files in the current working directory using a blockread setting of 1.
% All .cnt files are added to the ALLEEG struct array. 

importpath = uigetdir('C:\Users\canlab\Documents\MATLAB\', 'Select folder to import from');
savepath   = uigetdir('C:\Users\canlab\Documents\MATLAB\', 'Select folder to export to');
filelist = dir(fullfile(strcat(importpath, '/*.cnt')));
for i = 1:numel(filelist)
    EEG = pop_loadcnt(strcat(importpath, '/', filelist(i).name), 'blockread', 1);
    EEG.setname = filelist(i).name(1:9);
    %EEG.comments = pop_comments( {'Original file: ', strcat(pwd, '/', filelist(i).name) } );
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
    EEG = pop_saveset( EEG, 'filename', filelist(i).name(1:9), 'filepath', savepath, 'savemode', 'onefile' );
end
eeglab redraw