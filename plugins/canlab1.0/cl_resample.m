% Changes sample frequency for a batch of .set files
%
% Usage:
%   >>> subj = cl_alphatheta();
%   >>> subj = cl_alphatheta(importpath, exportpath);
% 
% Inputs:
% importpath: A string which specifies the directory containing the .cnt files
%             that are to be imported
% 
% exportpath: A string which specifies the directory containing the .set files
%             that are to be saved for further analysis
% 
% Outputs:
% subj: An array of structures, one for each subject that is processed. The
%       structure contains all of the results of the analysis

function cl_resample(importpath, exportpath, sampleFreq)

if (~exist('importpath', 'var'))
    importpath = uigetdir('~', 'Select folder to import .cnt files from');
    if importpath == 0
        error('Error: Please specify the folder that contains the .cnt files.');
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
if (~exist('sampleFreq', 'var'))
    sampleFreq = input('Enter new sampling rate: ');
end

files = dir(fullfile(strcat(importpath, '/*.set')));
for id = 1:numel(files)
    % Import set files into EEG object
    EEG = pop_loadset(files(id).name, importpath);
    % Change sampling frequency
    [EEG] = pop_resample(EEG, freq);
    % Save to export folder
    pop_saveset(EEG, 'filename', files(id).name(1:end-4), 'filepath',...
        exportpath, 'savemode', 'onefile');
end