% Find directory in which .sets are sitting
importpath = '/home/sopu/Dropbox/clean_eyesc_20s'; 
filelist   = dir(fullfile(strcat(importpath, '/*.set')));

% Create a cell to be imported into std_editset
for i = 1:numel(filelist)
    file = filelist(i).name;
    x{i} = {'index', i, 'load', strcat(importpath, '/', file), 'subject', file(end-7:end-4), 'condition', '_'};
end

% Import into std_editset
[STUDY, ALLEEG] = std_editset( STUDY, [], 'commands', x );