% Modifies EEGLAB's EEG
%
% Usage: 
%	>>> cl_modifyevents(importpath_set, importpath_evt, exportpath, segments);
%   >>> cl_modifyevents('raw-set', 'raw-evt', '~/Desktop', {'Closed', 'Open'});
%
% Inputs:
% importpath_set: Import path for EEGLAB .set files.
% 
% importpath_evt: Import path for EMSE-exported .evt files.
%
% exportpath: Export folder for modified .set files.
%
% segments: A MATLAB cell that contains the names of the segments we want to
%           extract from the evt.

function cl_modifyevents(importpath_set, importpath_evt, exportpath, segments)

files_set = dir(strcat(importpath_set, '/*.set'));
files_evt = dir(strcat(importpath_evt, '/*.evt'));

for i = 1:numel(files_set)
    if strcmp(files_set(i).name(1:end-4), files_evt(i).name(1:end-4))

        EEG  = pop_loadset(files_set(i).name, importpath_set);
        EEG.event = cl_EMSEevtparser(strcat(importpath_evt, '/', files_evt(i).name), segments);
        name = files_set(i).name(1:end-4);
        pop_saveset(EEG, 'filename', name, 'filepath', exportpath, 'savemode', 'onefile');

    end
end
