% This script utilizes the pop_loadcnt() function to import cnt files from
% a directory specified by the user. Each dataset is added to the ALLEEG
% object, and saved as a .set file to another directory also specified by
% the user.
% Default parameters passed to pop_loadcnt():
%   'blockread', 1
% All .cnt files are added to the ALLEEG struct array. 

importpath = uigetdir('C:\Users\canlab\Documents\MATLAB\', 'Select folder to import from');
if importpath == 0
    error('Error: Please specify the folder that contains the .cnt files.');
end
fprintf('Import path: %s\n', importpath);
exportpath   = uigetdir('C:\Users\canlab\Documents\MATLAB\', 'Select folder to export to');
if exportpath == 0
    error('Error: Please specify the folder to export the .set files to.');
end
fprintf('Export path: %s\n', exportpath);

filelist = dir(fullfile(strcat(importpath, '/*.cnt')));
for i = 1:numel(filelist)
    EEG = pop_loadcnt(strcat(importpath, '/', filelist(i).name), 'blockread', 1);
    EEG.setname = filelist(i).name(1:9);
    %EEG.comments = pop_comments( {'Original file: ', strcat(pwd, '/', filelist(i).name) } );
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
    EEG = pop_saveset( EEG, 'filename', filelist(i).name(1:9), 'filepath', exportpath, 'savemode', 'onefile' );
end
eeglab redraw