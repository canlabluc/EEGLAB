% This script applies a bandpass filter to .set files located in a
% directory specified by the user. The filtered datasets are then saved
% into another directory also specified by the user.

importpath = uigetdir('~', 'Select folder to import from');
exportpath = uigetdir('~', 'Select folder to export to');

if importpath == 0
    error('Error: Please select the importing directory');
end
% Create list of files in the directory
files = dir(fullfile(strcat(importpath, '/*.set')));
for id = 1:numel(files)
    EEG = pop_loadset(files(id).name, importpath);
    % Compute Average Reference and apply filtering: 0.5 - 45 Hz
    EEG = pop_reref(EEG, []);
    [EEG] = pop_eegfiltnew(EEG, 0.5);
    [EEG] = pop_eegfiltnew(EEG, [], 45);
    % Save file to specified directory with "filt" suffix
    name = strcat(files(id).name(1:end-4), 'filt');
    pop_saveset(EEG, 'filename', name, 'filepath',...
        exportpath, 'savemode', 'onefile');
end  
