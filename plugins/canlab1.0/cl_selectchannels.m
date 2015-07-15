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
chans = [1, 2];
for id = 1:numel(files)
    % Now we remove selected data channels from all of the datasets.
    % pop_select removes the channels from the actual data, whereas
    % pop_chanedit removes the channels from the EEG struct
    fprintf('Removing the following channels from %s:\n', files(id).name);
    disp(EEG.chaninfo.filecontent(chans, :));
    EEG = pop_select(EEG, 'nochannel', chans);
    EEG = pop_chanedit(EEG, 'delete', chans);
end
