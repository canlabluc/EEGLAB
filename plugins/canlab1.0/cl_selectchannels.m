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
clinicalCh = [3 4 5 9 11 12 13 14 17 18 19 20 21 22 23 24 25 28 30 32 34 35 37 38 39 41 42 43 44 45 47 48 49 50 51 52 53 54 57 59 61 63 64 65 66];
for id = 1:numel(files)
    EEG = pop_loadset(files(id).name, importpath);
    % Now we remove selected data channels from all of the datasets.
    % pop_select removes the channels from the actual data, whereas
    % pop_chanedit removes the channels from the EEG struct
    for ChId = 1:numel(clinicalCh)
        EEG.chanlocs(clinicalCh(ChId)) = [];
        EEG.data(clinicalCh(ChId)) = [];
    end
    pop_saveset(EEG, 'filename', files(id).name(1:end-4), 'filepath',...
        exportpath, 'savemode', 'onefile');
end
