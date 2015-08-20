% This script allows the user to select channels to average, exclude, or
% include in a number of datasets prior to running analysis. 

importpath = uigetdir('~', 'Select directory to import from');
exportpath = uigetdir('~', 'Select directory to export to');
if importpath == 0
    error('Error: Please specify an import path');
end
files = dir(fullfile(strcat(importpath, '/*.set')));
% Prompt user to select channels to remove from the dataset
%   TODO: Create GUI that allows user to easily select bad channels
%disp('Select the channels that you would like to exclude: ');
%disp(EEG.chaninfo.filecontent);
% Electrodes to remove, for Standard Clinical Electrodes Montage
stdClinicalCh = [66 65 64 63 61 59 57 54 53 52 51 50 49 48 47 45 44 43 42 41 39 38 37 35 34 32 30 28 25 24 23 22 21 20 19 18 17 14 13 12 11 9 5 4 3];
% Electrodes to remove, for Extended Clinical Electrodes Montage
extClinicalCh = [9 19 20 28 32 39 47 48 57 63 64 65 66];
for id = 1:numel(files)
    EEG = pop_loadset(files(id).name, importpath);
    % Now we remove selected data channels from all of the datasets.
    EEG = pop_select(EEG, 'nochannel', stdClinicalCh);
    pop_saveset(EEG, 'filename', files(id).name(1:end-4), 'filepath',...
        exportpath, 'savemode', 'onefile');
end
