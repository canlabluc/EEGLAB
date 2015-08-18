% This script changes the sampling frequency for a batch of .set files

importpath = uigetdir('~', 'Select directory to import from');
exportpath = uigetdir('~', 'Select directory to export to');
if importpath == 0
    error('Error: Please specify an import path');
end
if exportpath == 0
    error('Error: Please specify an export path');
end
files = dir(fullfile(strcat(importpath, '/*.set')));
freq = input('Enter new sampling rate: ');
for id = 1:numel(files)
    % Import set files into EEG object
    EEG = pop_loadset(files(id).name, importpath);
    % Change sampling frequency
    [EEG] = pop_resample(EEG, freq);
    % Save to export folder
    pop_saveset(EEG, 'filename', files(id).name(1:end-4), 'filepath',...
        exportpath, 'savemode', 'onefile');
end