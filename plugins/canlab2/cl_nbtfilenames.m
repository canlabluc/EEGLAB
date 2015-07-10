% This script converts a folder full of EEGLAB .set files into the naming
% system that NBT uses:
%   <ProjectID>.<SubjectID>.<Date of recording>.<Condition>
%   NBT.S0099.20090212.EOR2.

importpath = uigetdir('/home/sopu', 'Select folder to import from');
exportpath = uigetdir('/home/sopu', 'Select foler to export to');
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
    