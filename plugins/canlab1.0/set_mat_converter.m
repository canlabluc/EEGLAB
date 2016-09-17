% Convert EEGLAB files to .mat for use in Python.
%
% Usage:
% 	>> set_mat_converter(importpath, exportpath)
%

function set_mat_converter(importpath, exportpath)

files = dir(fullfile(strcat(importpath, '/*.set')));
for id = 1:numel(files)
    EEG = pop_loadset(files(id).name, importpath);
    fields_to_remove = {'filepath', 'subject', 'group', 'condition', 'session', 'comments', 'trials', 'xmin', 'xmax', 'times', 'icaact', 'icawinv', 'icasphere', 'icaweights', 'icachansind', 'urchanlocs', 'eventdescription', 'epoch', 'epochdescription', 'reject', 'stats', 'specdata', 'specicaact', 'splinefile', 'icasplinefile', 'dipfit', 'history', 'saved', 'etc', 'datfile'};
    EEG = rmfield(EEG, fields_to_remove);
    name  = EEG.setname;
    srate = EEG.srate;
    data  = EEG.data;
    evts  = EEG.event;
    save(strcat(exportpath, '/', files(id).name(1:end-4), '.mat'), 'name', 'srate', 'data', 'evts'); 
end