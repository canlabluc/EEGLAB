% This script applies a bandpass filter to .set files located in a
% directory, specified by the user. The filtered datasets are then output
% into another directory.

importpath = uigetdir('~', 'Select folder to input from');
exportpath = uigetdir('~', 'Select folder to export to');

if importpath == 0
    error('Error: Please select the importing directory');
end
files = dir(fullfile(strcat(importpath, '/*.set')));
for id = 1:numel(files)
    EEG = pop_loadset(files(id).name, importpath);
    % Apply filtering: 0.5 - 45 Hz
    [EEG] = pop_eegfiltnew(EEG, .5);
    [EEG] = pop_eegfiltnew(EEG, [], 45);
    name = strcat(files(id).name(1:end-4), 'filt');
    pop_saveset(EEG, 'filename', name, 'filepath',...
        exportpath, 'savemode', 'onefile');
end  
