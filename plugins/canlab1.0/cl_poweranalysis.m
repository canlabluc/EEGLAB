% This script utilizes nbt_doPeakFit and EEGLAB's spectopo() function to calculate the mean
% power ratio for power bands derived from calculating the TF and IAF. 

importpath = uigetdir('C:\Users\canlab\Documents\MATLAB\', 'Select folder to import from');
if importpath == 0
    error('Error: Please specify the folder that contains the .set files.');
end
fprintf('Import path: %s\n', importpath);
exportpath = uigetdir('C:\Users\canlab\Documents\MATLAB\', 'Select folder to export results to');
if exportpath == 0
    error('Error: Please specify the folder to export results files to.');
end
% Change this to 0 in order to compute the IAF, TF, and calculate power
% from the resulting frequency bands.
fixedBands = 1;
files = dir(fullfile(strcat(importpath, '/*S.mat')));
subj{size(files, 1)} = [];

for i = 1:numel(files)
    [Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(i).name));
    [power, freq] = spectopo(mean(Signal'), 0, 512, 'plot', 'off');
    subj{i}.SubjectID = files(i).name;
    subj{i}.fixedBands = fixedBands;
    subj{i}.power = power;
    subj{i}.freq = freq;
    % Because we are using fixed frequency bands, fitting peaks is not
    % necessary, and we can simply define the indexes:
    subj{i}.fixedTheta_floor    = 4;
    subj{i}.fixedTheta_ceiling  = 8;
    subj{i}.fixedAlpha_floor    = 8;
    subj{i}.fixedAlpha1_floor   = 8;
    subj{i}.fixedAlpha1_ceiling = 9.25;
    subj{i}.fixedAlpha2_floor   = 9.25;
    subj{i}.fixedAlpha2_ceiling = 10.5;
    subj{i}.fixedAlpha3_floor   = 10.5;
    subj{i}.fixedAlpha3_ceiling = 13;
    subj{i}.fixedAlpha_ceiling  = 13;
    subj{i}.fixedBeta_floor     = 13;
    subj{i}.fixedBeta_ceiling   = 30;
        
    if fixedBands == 1
        analysis = 'fixed';
        % Calculate power across fixed (traditional) frequency bands
        subj{i}.mean_falphaPower  = mean(power(freq >= subj{i}.fixedAlpha_floor & freq <= subj{i}.fixedAlpha_ceiling));
        subj{i}.mean_fthetaPower  = mean(power(freq >= subj{i}.fixedTheta_floor & freq <= subj{i}.fixedTheta_ceiling));
        subj{i}.mean_falpha1Power = mean(power(freq >= subj{i}.fixedAlpha1_floor & freq <= subj{i}.fixedAlpha1_ceiling));
        subj{i}.mean_falpha2Power = mean(power(freq >= subj{i}.fixedAlpha2_floor & freq <= subj{i}.fixedAlpha2_ceiling));
        subj{i}.mean_falpha3Power = mean(power(freq >= subj{i}.fixedAlpha3_floor & freq <= subj{i}.fixedAlpha3_ceiling));
        % Compute ratios and store Power Spectrum
        subj{i}.ratio_meanAlpha32Fixed    = subj{i}.mean_falpha3Power / subj{i}.mean_falpha2Power;
        subj{i}.ratio_meanAlphaThetaFixed = subj{i}.mean_falphaPower / subj{i}.mean_fthetaPower;
    else
        analysis = 'IAF';
        % Calculate power based on bands derived from IAF and TF
        subj{i}.peakFit = nbt_doPeakFit(Signal, SignalInfo);
        % Find mean IAF, TF, and find needed indexes
        disp('Peak Fit complete, calculating indexes');    
        subj{i}.meanIAF = mean(subj{i}.peakFit.IAF);
        subj{i}.meanTF  = mean(subj{i}.peakFit.TF);
        subj{i}.Theta_floor    = subj{i}.meanTF - 2;
        subj{i}.Alpha2_floor   = (subj{i}.meanIAF + subj{i}.meanTF) / 2;
        subj{i}.Alpha3_ceiling = subj{i}.meanIAF + 2;
        % Compute power across derived bands
        subj{i}.mean_thetaPower = mean(power(freq >= subj{i}.Theta_floor & freq <= subj{i}.meanTF));
        subj{i}.mean_alphaPower = mean(power(freq >= subj{i}.TF & freq <= subj{i}.Alpha3_ceiling));
        subj{i}.mean_alpha1Power = mean(power(freq >= subj{i}.meanTF & freq <= subj{i}.Alpha2_floor));
        subj{i}.mean_alpha2Power = mean(power(freq >= subj{i}.Alpha2_floor & freq <= subj{i}.meanIAF));
        subj{i}.mean_alpha3Power = mean(power(freq >= subj{i}.meanIAF & freq <= subj{i}.Alpha3_ceiling));
        subj{i}.ratio_meanAlpha32 = subj{i}.mean_alpha3Power / subj{i}.mean_alpha2Power;
        subj{i}.ratio_meanAlphaTheta = subj{i}.mean_alphaPower / mean_thetaPower;
    end
end
name = strcat(date, '-results-', analysis, '.mat');
save(name, 'subj');

