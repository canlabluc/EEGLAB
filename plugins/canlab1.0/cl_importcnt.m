% Converts .cnt files to EEGLAB-usable .set files
%
% Usage:
%   >>> cl_importcnt(); % Brings up menu which allows user specify directories
%   >>> cl_importcnt(importpath, exportpath);
%
% Inputs:
% importpath: A string which specifies the directory containing the .cnt files
%             that are to be imported
% 
% exportpath: A string which specifies the directory containing the .set files
%             that are to be saved for further analysis
% 
% Notes: 
% cl_importcnt utilizes EEGLAB's pop_loadcnt() function to import files
% from a directory specified by the user. Each dataset is added to the ALLEEG 
% object, and saved as a .set file to another directory also specified by the
% user.
%
% Default parameters passed to pop_loadcnt():
%   'blockread', 1 

function cl_importcnt(importpath, exportpath)

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
cdh;
cd EEGLAB;
eeglab;
global ALLEEG;
filelist = dir(fullfile(strcat(importpath, '/*.cnt')));
for i = 1:numel(filelist)
    EEG = pop_loadcnt(strcat(importpath, '/', filelist(i).name), 'blockread', 1);
    EEG.setname = filelist(i).name(1:9);
    %EEG.comments = pop_comments( {'Original file: ', strcat(pwd, '/', filelist(i).name) } );
    [ALLEEG, EEG, CURRENTSET] = eeg_store(ALLEEG, EEG);
    EEG = pop_saveset( EEG, 'filename', filelist(i).name(1:9), 'filepath', exportpath, 'savemode', 'onefile' );
end
eeglab redraw
