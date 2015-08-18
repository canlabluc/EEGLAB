% Change EEGLAB .set datasets from CANLab to NBT naming system
% 
% Usage:
%   >>> cl_nbtfilenames(); % GUI
%   >>> cl_nbtfilenames(importpath, exportpath);
% 
% Inputs:
% importpath: A string which specifies the directory containing the .cnt files
% that are to be imported
% 
% exportpath: A string which specifies the directory containing the .set files
% that are to be saved for further analysis
%
% This script converts a folder full of EEGLAB .set files into the naming
% system that NBT uses:
%   <ProjectID>.<SubjectID>.<Date of recording>.<Condition>.mat
%   e.g., NBT.S0099.20090212.EOR2.mat
%
% Note that these end up being .mat files, as this is how NBT deals with data.

importpath = uigetdir('~', 'Select folder to import from');
exportpath = uigetdir('~', 'Select folder to export to');
exportpath2 = uigetdir('~', 'Select folder to export to');
if importpath == 0
    error('Error: Please select the importing directory');
end
files = dir(fullfile(strcat(importpath, '/*.set')));
for id = 1:numel(files)
    study   = files(id).name(1:3);
    session = files(id).name(4:6);
    subject = files(id).name(7:9);
    copyfile(strcat(importpath, '/', files(id).name), strcat(exportpath, ...
        sprintf('/%s%s.%s.yyyymmdd.RS.set', study, session, subject)));
end
% Add NBT to the path in order to make sure that we can use nbt_import_files
cd ~/nbt;
installNBT;
nbt_import_files(strcat(exportpath,'/'), strcat(exportpath2,'/'));
