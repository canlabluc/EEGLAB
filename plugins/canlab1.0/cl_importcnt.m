% Converts .cnt files to EEGLAB-usable .set files
%
% Usage:
%   >> cl_importcnt(); % Brings up menu which allows user specify directories
%   >> cl_importcnt(importpath, exportpath);
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

filelist = dir(fullfile(strcat(importpath, '/*.cnt')));

% Fixes channel names
chan(1).name  = 'A01';
chan(2).name  = 'A02';
chan(3).name  = 'A03';
chan(4).name  = 'A04';
chan(5).name  = 'A05';
chan(6).name  = 'A06';
chan(7).name  = 'A07';
chan(8).name  = 'A08';
chan(9).name  = 'A09';
chan(10).name = 'A10';
chan(11).name = 'A11';
chan(12).name = 'A12';
chan(13).name = 'A13';
chan(14).name = 'A14';
chan(15).name = 'A15';
chan(16).name = 'A16';
chan(17).name = 'A17';
chan(18).name = 'A18';
chan(19).name = 'A19';
chan(20).name = 'A20';
chan(21).name = 'A21';
chan(22).name = 'A22';
chan(23).name = 'A23';
chan(24).name = 'A24';
chan(25).name = 'A25';
chan(26).name = 'A26';
chan(27).name = 'A27';
chan(28).name = 'A28';
chan(29).name = 'A29';
chan(30).name = 'A30';
chan(31).name = 'A31';
chan(32).name = 'A32';
chan(33).name = 'B01';
chan(34).name = 'B02';
chan(35).name = 'B03';
chan(36).name = 'B04';
chan(37).name = 'B05';
chan(38).name = 'B06';
chan(39).name = 'B07';
chan(40).name = 'B08';
chan(41).name = 'B09';
chan(42).name = 'B10';
chan(43).name = 'B11';
chan(44).name = 'B12';
chan(45).name = 'B13';
chan(46).name = 'B14';
chan(47).name = 'B15';
chan(48).name = 'B16';
chan(49).name = 'B17';
chan(50).name = 'B18';
chan(51).name = 'B19';
chan(52).name = 'B20';
chan(53).name = 'B21';
chan(54).name = 'B22';
chan(55).name = 'B23';
chan(56).name = 'B24';
chan(57).name = 'B25';
chan(58).name = 'B26';
chan(59).name = 'B27';
chan(60).name = 'B28';
chan(61).name = 'B29';
chan(62).name = 'B30';
chan(63).name = 'B31';
chan(64).name = 'B32';
chan(65).name = 'EXG1';
chan(66).name = 'EXG2';

for i = 1:numel(filelist)
    disp(filelist(i).name);
    EEG = pop_loadcnt(strcat(importpath, '/', filelist(i).name), 'blockread', 1);
    EEG.setname = filelist(i).name(1:end-4);
    if numel(EEG.chanlocs) > 66
        EEG = pop_select(EEG, 'nochannel', [67 : numel(EEG.chanlocs)]);
    end
    for j = 1:size(EEG.data, 1)
        EEG.chanlocs(j).labels = chan(j).name;
        EEG.chanlocs(j).urchan = j;
    end
    EEG = pop_saveset( EEG, 'filename', filelist(i).name(1:end-4), 'filepath', exportpath, 'savemode', 'onefile' );
end
end
