% Applies a bandpass filter
%
% Usage:
%   >>> cl_bandpassfilter();
%   >>> cl_bandpassfilter(importpath, exportpath, lowerFreq, higherFreq);
%
% Inputs:
% importpath: A string which specifies the directory containing the EEG datasets
% to be re-referenced
% 
% exportpath: A string which specifies the directory containing the .set files
% that are to be saved for further analysis
% 
% lowerCutOff: High-pass frequency. Typically we set this to 0.5 Hz
%
% higherCutOff: Low-pass frequency. Typically we set this to 45 Hz

function cl_bandpassfilter(importpath, exportpath, lowerFreq, higherFreq)

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

% Create list of files in the directory
files = dir(fullfile(strcat(importpath, '/*.set')));
for id = 1:numel(files)
    EEG = pop_loadset(files(id).name, importpath);
    % Apply filtering: 0.5 - 45 Hz
    [EEG] = pop_eegfiltnew(EEG, lowerFreq);
    [EEG] = pop_eegfiltnew(EEG, [], higherFreq);
    % Save file to specified directory with "filt" suffix
    name = files(id).name(1:end-4);
    pop_saveset(EEG, 'filename', name, 'filepath',...
        exportpath, 'savemode', 'onefile');
end