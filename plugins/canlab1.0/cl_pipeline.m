function cl_pipeline(importpath, 'resample', rsFreq, ')

if (~exist('importpath', 'var'))
    importpath = uigetdir('~', 'Select folder to import .cnt files from');
    if importpath == 0
        error('Error: Please specify the folder that contains the .cnt files.');
    end
    fprintf('Import path: %s\n', importpath);
end

mkdir(strcat(importpath, '/', 'raw-set');
mkdir(strcat(importpath, '/', 'excl-set');
mkdir(strcat(importpath, '/', 'exclfilt-set');
mkdir(strcat(importpath, '/', 'exclfiltCAR', lowerFreq, '-', higherFreq, '-set');
mkdir(strcat(importpath, '/', 'exclfiltCAR', lowerFreq, '-', higherFreq, '-NBT', '-mat');
mkdir(strcat(importpath, '/', 'results');

cl_importcnt(strcat(importpath, '/', 'raw-cnt', 'raw-set');
cl_excludechannels(strcat(importpath, '/raw-set'), strcat(importpath, '/excl-set'));
cl_rereferencechannels(strcat(importpath, 
