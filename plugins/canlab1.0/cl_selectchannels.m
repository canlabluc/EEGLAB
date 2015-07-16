% This script allows the user to select channels to average, exclude, or
% include in a number of datasets prior to running analysis. 
% Clinical Electrodes:
% 
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
clinicalCh = [66 65 64 63 61 59 57 54 53 52 51 50 49 48 47 45 44 43 42 41 39 38 37 35 34 32 30 28 25 24 23 22 21 20 19 18 17 14 13 12 11 9 5 4 3];
for id = 1:numel(files)
    EEG = pop_loadset(files(id).name, importpath);
    % Now we remove selected data channels from all of the datasets.
    EEG = pop_select(EEG, 'nochannel', clinicalCh);
    pop_saveset(EEG, 'filename', files(id).name(1:end-4), 'filepath',...
        exportpath, 'savemode', 'onefile');
end
