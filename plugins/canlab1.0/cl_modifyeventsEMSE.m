% Modifies EEGLAB's EEG struct's events to instead hold events specified by EMSE
% .evt's
%
% Usage: 
% >> cl_modifyeventsEMSE(importpath_set, importpath_evt, exportpath, segments);
% >> cl_modifyeventsEMSE('raw-set', 'raw-evt', '~/Desktop', {'Closed', 'Open'});
%
% Inputs:
% importpath_set: Import path for EEGLAB .set files.
% 
% importpath_evt: Import path for EMSE-exported .evt files.
%
% exportpath: Export folder for modified .set files.
%
% use_segs: Boolean specifying whether to only extract segments in the recording
%           marked off in the recording by strings passed in the next parameter.
%
% segments: A MATLAB cell that contains the names of the segments we want to
%           extract from the evt.

function cl_modifyeventsEMSE(importpath_set, importpath_evt, exportpath, use_segs, segments)

files_set = dir(strcat(importpath_set, '/*.set'));

for i = 1:numel(files_set)
    file = files_set(i).name(1:end-4);
    EEG = pop_loadset(files_set(i).name, importpath_set);
    EEG.event = cl_EMSEevtparser(strcat(importpath_evt, '/', file, '.evt'), use_segs, segments);
    name = files_set(i).name(1:end-4);
    pop_saveset(EEG, 'filename', name, 'filepath', exportpath, 'savemode', 'onefile');
end
