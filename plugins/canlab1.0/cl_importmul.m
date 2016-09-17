% Imports mul files from BESA, utilizing corresponding .set files to
% first acquire subject information and build a starting EEG object.
%
% Usage:
%   >> cl_importmul(importpath_mul, importpath_cnt, exportpath)
%
% Inputs:
% importpath_mul: A string which specifies the directory containing the
%                 .mul files to be imported.
%
% importpath_set: A string which specifies the directory containing the
%                 corresponding .set files, which area already in EEGLAB
%                 structure format. To acquire these, we run 
%                 cl_importcnt().
%
% exportpath: A string which specifies the directory to which to save
%             the resulting .set file. 
%
function cl_importmul(importpath_mul, importpath_set, exportpath)

% 1. Construct a list of mul files, and a list of set files
files_set = dir(fullfile(strcat(importpath_set, '/*.set')));
for i = 1:numel(files_set)

    file = files_set(i).name(1:end-4);
    
    % First, import the .set file and corresponding .mul file
    EEG = pop_loadset(files_set(i).name, importpath_set);
    mul = readBESAmul(strcat(importpath_mul, '/', file, '.mul'));
    
    % Replace .set data with that from the .mul file
    EEG.data = mul.data';
    EEG.nbchan = size(EEG.data, 1);

    % Change channel labels to that from .mul
    EEG.chanlocs = EEG.chanlocs(1:EEG.nbchan);
    for j = 1:EEG.nbchan
        EEG.chanlocs(j).labels = mul.ChannelLabels{j};
    end

    pop_saveset(EEG, 'filename', file, 'filepath', exportpath, 'savemode', 'onefile');
end
end
