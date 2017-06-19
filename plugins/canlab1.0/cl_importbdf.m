% Converts .bdf files to EEGLAB-usable .set files
%
% Usage:
%   >> cl_importbdf(importpath, exportpath);
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

% Analogy task
chans = {'A01','A02','A03','A04','A05','A06','A07','A08','A09','A10','A11','A12','A13','A14','A15','A16','A17','A18','A19','A20','A21','A22','A23','A24','A25','A26','A27','A28','A29','A30','A31','A32','B01','B02','B03','B04','B05','B06','B07','B08','B09','B10','B11','B12','B13','B14','B15','B16','B17','B18','B19','B20','B21','B22','B23','B24','B25','B26','B27','B28','B29','B30','B31','B32'};

filelist = dir(fullfile(strcat(importpath, '/*.bdf')));
for i = 1:numel(filelist)
    EEG = pop_biosig(strcat(importpath, '/', filelist(i).name), 'ref', [20 48], 'refoptions', {'keepref', 'off'});
    EEG.setname = filelist(i).name(1:end-4);
    EEG = pop_select(EEG, 'nochannel', [65 : numel(EEG.chanlocs)]);
    for j = 1:size(EEG.data, 1)
        EEG.chanlocs(j).labels = chans{j};
        EEG.data(j,:) = EEG.data(j,:) - EEG.data(j,1);
    end
    EEG = pop_saveset( EEG, 'filename', filelist(i).name(1:end-4), 'filepath', exportpath, 'savemode', 'onefile');
end
end
