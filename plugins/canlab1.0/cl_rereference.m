% Re-references EEG datasets to the common average
%
% Usage:
%   >>> cl_rereference();
%   >>> cl_rereference(importpath, exportpath, reference);
%
% Inputs:
% importpath: A string which specifies the directory containing the EEG datasets
% to be re-referenced
% 
% exportpath: A string which specifies the directory containing the .set files
% that are to be saved for further analysis
% 
% reference: Specifies reference channel or common average
%   Options:
%       - 'CAR': Re-references EEG data to common average

function cl_rereference(importpath, exportpath, reference)

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
    % Compute and re-reference EEG dataset to grand average
    if reference == 'CAR'
        EEG = pop_reref(EEG, []);
    end        
    % Save file to specified directory
    name = files(id).name(1:end-4);
    pop_saveset(EEG, 'filename', name, 'filepath',...
        exportpath, 'savemode', 'onefile');
end  
