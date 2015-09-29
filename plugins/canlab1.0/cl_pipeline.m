function subj = cl_pipeline(importpath)

grandAvg = true;
rsFreq = 512;
chExclusion = 'extClinicalCh';
lowerFreq  = 0.5;
higherFreq = 45;
reference = 'CAR';

if (~exist('importpath', 'var'))
    importpath = uigetdir('~', 'Select folder to import .cnt files from');
    if importpath == 0
        error('Error: Please specify the folder that contains the .cnt files.');
    end
    fprintf('Import path: %s\n', importpath);
end

%mkdir(strcat(importpath, '/', 'raw-set');
mkdir(strcat(importpath, '/', 'excl-set'));
mkdir(strcat(importpath, '/', 'exclfilt-set'));
mkdir(strcat(importpath, '/', 'exclfiltCAR-set'));
mkdir(strcat(importpath, '/', 'exclfiltCAR-NBT-mat'));
mkdir(strcat(importpath, '/', 'results'));

%cl_importcnt(strcat(importpath, '/', 'raw-cnt', 'raw-set');
cl_excludechannels(strcat(importpath, '/raw-set'), strcat(importpath, '/excl-set'), chExclusion);
cl_bandpassfilter(strcat(importpath, '/excl-set'), strcat(importpath, '/exclfilt-set'), lowerFreq, higherFreq);
cl_rereference(strcat(importpath, '/exclfilt-set'), strcat(importpath, '/exclfiltCAR-set'), 'CAR');
cl_nbtfilenames(strcat(importpath, '/exclfiltCAR-set'), strcat(importpath, '/exclfiltCAR-NBT-mat'));
subj = cl_alpha3alpha2(strcat(importpath, '/exclfiltCAR-NBT-mat'), importpath, grandAvg);
