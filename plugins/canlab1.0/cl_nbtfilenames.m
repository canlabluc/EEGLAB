% Change EEGLAB .set datasets from CANLab to NBT naming system. Note that these
% end up being .mat files, since this is how NBt deals with data.
% 
% Usage:
%   >>> cl_nbtfilenames(); % GUI option
%   >>> cl_nbtfilenames(importpath, exportpath);
% 
% Inputs:
% importpath: A string which specifies the directory containing the .cnt files
%             that are to be imported
% 
% exportpath: A string which specifies the directory containing the .set files
%             that are to be saved for further analysis
%
% This script converts a folder full of EEGLAB .set files into the naming
% system that NBT uses:
%   <ProjectID>.<SubjectID>.<Date of recording>.<Condition>.mat
%   e.g., NBT.S0099.20090212.EOR2.mat

function cl_nbtfilenames(importpath, exportpath)

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

cd ~/nbt;
installNBT;
files = dir(fullfile(strcat(importpath, '/*.set')));
for id = 1:numel(files)
    study   = files(id).name(1:3);
    session = files(id).name(4:6);
    subject = files(id).name(7:9);
    copyfile(strcat(importpath, '/', files(id).name), strcat(exportpath, ...
        sprintf('/%s%s.%s.yyyymmdd.RS.set', study, session, subject)));
end
nbt_import_files(strcat(exportpath, '/'), strcat(exportpath, '/'));
cd exportpath;
delete *.set;