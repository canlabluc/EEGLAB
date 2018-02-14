% Modifies EEGLAB's EEG struct's events to instead hold events specified by EMSE
% .evt's
%
% Usage: 
%   >> cl_modifyevents(importpath_set, importpath_evt, exportpath, segments);
%   >> cl_modifyevents('raw-set', 'raw-evt', '~/Desktop', {'Closed', 'Open'});
%
% Inputs:
% importpath_set: Import path for EEGLAB .set files.
% 
% importpath_evt: Import path for BESA-exported .evt files.
%
% exportpath: Export folder for modified .set files.

function eeg_event = cl_modifyeventsBESA(importpath_set, importpath_evt, exportpath)

files_set = dir(strcat(importpath_set, '/*.set'));
files_evt = dir(strcat(importpath_evt, '/*.evt'));
for i = 1:numel(files_set)
    fprintf('set: %s\n', files_set(i).name);
    fprintf('evt: %s\n', files_evt(i).name);
    if strcmp(files_set(i).name(1:end-4), files_evt(i).name(1:end-4))
        subject = files_set(i).name(1:end-4);
        EEG = pop_loadset(files_set(i).name, importpath_set);
        EEG.event = cl_BESAevtparser(strcat(importpath_evt, subject, '.evt'));
        name = files_set(i).name(1:end-4);
        pop_saveset(EEG, 'filename', name, 'filepath', exportpath, 'savemode', 'onefile');
    else
        disp('ERROR!!!!');
        disp(files_set(i).name);
    end
end
end
