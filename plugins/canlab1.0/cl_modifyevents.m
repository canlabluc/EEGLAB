% Modify the events structure in a .set file, using cl_evtparser().
% 
% Usage:
%
%   >> cl_modifyevents(importpath_set, importpath_evt, exportpath_set, segments);
%
% Inputs:
% importpath_set: String, specifies path to directory from which to import
%                         set files.
%
% importpath_evt: String, specifies path to directory from which to import
%                         evt files.
%
% exportpath_set: String, specifies path to directory for exporting resulting
%                         set files.
%
% segments: MATLAB cell, OPTIONAL, contains the names of the segments that
%           we want to extract. If we're importing 'C' or 'O' segments,
%           for example, they'd be present in the .evt file as 'C1' and
%           'C2' and 'O1' and 'O2', respectively, we'd pass the following
%           cell: {'C', 'O'}.

function cl_modifyevents(importpath_set, importpath_evt, exportpath_set, segments)

files_set = dir(strcat(importpath_set, '/*.set'));
for i = 1:numel(files_set)
    id = files_set(i).name(1:end-4);
    EEG = pop_loadset(files_set(i).name, importpath_set);
    if exist('segments', 'var')
        EEG.event = cl_evtparser(strcat(importpath_evt, id, '.evt'), segments);
    else
        EEG.event = cl_evtparser(strcat(importpath_evt, id, '.evt'));
    end
    pop_saveset(EEG, 'filename', id, 'filepath', exportpath_set, 'savemode', 'onefile');
end