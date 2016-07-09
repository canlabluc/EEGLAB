% Converts .bdf files to EEGLAB-usable .set files
%
% Usage:
%   >>> cl_importbdf(importpath, exportpath);
%
% Inputs:
% importpath: A string which specifies the directory containing the .bdf files
%             that are to be imported
% 
% exportpath: A string which specifies the directory containing the .set files
%             that are to be saved for further analysis
% 
% Notes: 
% cl_importbdf utilizes EEGLAB's pop_biosig() function to import files from
% a directory specified by the user. Each dataset is added to the ALLEEG
% object, and saved as a .set file to another directory also specified by the
% user. 
%
% Default parameters passed to pop_loadcnt():
%   'blockread', 1 

function cl_importbdf(importpath, exportpath)

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

filelist = dir(fullfile(strcat(importpath, '/*.bdf')));
for i = 1:numel(filelist)
	EEG = pop_biosig(strcat(importpath, '/', filelist(i).name), 'ref', [20 48], 'refoptions', {'keepref', 'off'});
	EEG.setname = filelist(i).name(1:end-4);
    for j = 1:size(EEG.data, 1)
        EEG.chanlocs(j).urchan = j;
        EEG.data(j,:) = EEG.data(j,:) - EEG.data(j,1);
    end
	% [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
    EEG = pop_saveset( EEG, 'filename', filelist(i).name(1:end-4), 'filepath', exportpath, 'savemode', 'onefile');
end

eeglab redraw
end
