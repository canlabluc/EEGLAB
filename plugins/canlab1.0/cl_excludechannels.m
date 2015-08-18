% Exclude channels from EEG datasets
%
% Usage:
%   >>> cl_excludechannels(); % GUI option
%   >>> cl_excludechannels(importpath, exportpath, montage);
%
% Inputs:
% importpath: A string which specifies the directory containing the EEG datasets
% with channels that are to be excluded from further analysis
% 
% exportpath: A string which specifies the directory containing the .set files
% that are to be saved for further analysis
% 
% montage: A string specifying the montage we want to end up with
%   Options:
%       - 'stdClinicalCh': Exclude all channels except those that make up the
%                          Standard Clinical Montage, composed of 19 channels
%       - 'extClinicalCh': Exclude only the following channels: electrodes that
%                          monitor eye activity, mastoid (reference electodes),
%                          and electrodes that fall further down the head than
%                          what the standard clinical montage uses. We thus get
%                          a montage similar to the standard clinical one -- the
%                          difference being that this one is denser.

function cl_excludechannels(importpath, exportpath, montage)
% ----------------------- %
% Add new montages below: %
% ----------------------- %
% Electrodes to remove, for Standard Clinical Electrodes Montage
stdClinicalCh = [66 65 64 63 61 59 57 54 53 52 51 50 49 48 47 45 44 43 42 41 39 38 37 35 34 32 30 28 25 24 23 22 21 20 19 18 17 14 13 12 11 9 5 4 3];
% Electrodes to remove, for Extended Clinical Electrodes Montage
extClinicalCh = [9 19 20 28 32 39 47 48 57 63 64 65 66];

if (~exist('importpath', 'var'))
    importpath = uigetdir('~', 'Select folder to import .set files from');
    if importpath == 0
        error('Error: Please specify the folder that contains the .set files.');
    end
    fprintf('Import path: %s\n', importpath);
end
if (~exist('exportpath', 'var'))
    exportpath   = uigetdir('~', 'Select folder to export .set files to');
    if exportpath == 0
        error('Error: Please specify the folder to export the .set files to.');
    end
    fprintf('Export path: %s\n', exportpath);
end

files = dir(fullfile(strcat(importpath, '/*.set')));
% Prompt user to select channels to remove from the dataset
%   TODO: Create GUI that allows user to easily select bad channels
%disp('Select the channels that you would like to exclude: ');
%disp(EEG.chaninfo.filecontent);
for id = 1:numel(files)
    EEG = pop_loadset(files(id).name, importpath);
    % Now we remove selected data channels from all of the datasets.
    EEG = pop_select(EEG, 'nochannel', extClinicalCh);
    pop_saveset(EEG, 'filename', files(id).name(1:end-4), 'filepath',...
        exportpath, 'savemode', 'onefile');
end
