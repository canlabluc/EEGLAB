% This script utilizes nbt_doPeakFit and EEGLAB's spectopo() function to calculate the mean
% power ratio for power bands derived from calculating the TF and IAF. 

importpath = uigetdir('~', 'Select folder to import from (contains .mat files)');
if importpath == 0
    error('Error: Please specify the folder that contains the .set files.');
end
fprintf('Import path: %s\n', importpath);
exportpath = uigetdir('~', 'Select folder to export resulting struct to');
if exportpath == 0
    error('Error: Please specify the folder to export results files to.');
end
fprintf('Export path: %s\n', exportpath);

files = dir(fullfile(strcat(importpath, '/*S.mat')));
subj{size(files, 1)} = [];
for i = 1:numel(files)
    [Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(i).name));
    [spectra, freq] = spectopo(mean(Signal'), 0, 512, 'plot', 'off', 'freqrange', [0 45]);
    subj{i}.SubjectID = files(i).name;
    subj{i}.spectra = spectra; % Note that units are 10*log10(amp^2)
    subj{i}.freq = freq;
    
    % ---- FIXED FREQUENCY BANDS ---- %
    subj{i}.fixedDelta_floor    = 0;
    subj{i}.fixedDelta_ceiling  = 4;
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
    subj{i}.fixedGamma_floor    = 30;
    subj{i}.Gamma_ceiling       = 45; % Gamma ceiling is 45 Hz for fixed and IAF-based bands
    
    % Calculate absolute power (amplitude^2) across fixed (traditional) frequency bands
    subj{i}.mean_fdeltaPower  = mean(10.^(spectra(freq >= subj{i}.fixedDelta_floor & freq <= subj{i}.fixedDelta_ceiling)/10));
    subj{i}.mean_fthetaPower  = mean(10.^(spectra(freq >= subj{i}.fixedTheta_floor & freq <= subj{i}.fixedTheta_ceiling)/10));
    subj{i}.mean_falphaPower  = mean(10.^(spectra(freq >= subj{i}.fixedAlpha_floor & freq <= subj{i}.fixedAlpha_ceiling)/10));
    subj{i}.mean_fbetaPower   = mean(10.^(spectra(freq >= subj{i}.fixedBeta_floor & freq <= subj{i}.fixedBeta_ceiling)/10));
    subj{i}.mean_fgammaPower  = mean(10.^(spectra(freq >= subj{i}.fixedGamma_floor & freq <= subj{i}.Gamma_ceiling)/10));
    subj{i}.mean_falpha1Power = mean(10.^(spectra(freq >= subj{i}.fixedAlpha1_floor & freq <= subj{i}.fixedAlpha1_ceiling)/10));
    subj{i}.mean_falpha2Power = mean(10.^(spectra(freq >= subj{i}.fixedAlpha2_floor & freq <= subj{i}.fixedAlpha2_ceiling)/10));
    subj{i}.mean_falpha3Power = mean(10.^(spectra(freq >= subj{i}.fixedAlpha3_floor & freq <= subj{i}.fixedAlpha3_ceiling)/10));

    % ---- FREQUENCY BANDS DERIVED FROM IAF & TF ---- %
    subj{i}.peakFit = nbt_doPeakFit(Signal, SignalInfo);
    subj{i}.meanIAF = mean(subj{i}.peakFit.IAF);
    subj{i}.meanTF  = mean(subj{i}.peakFit.TF);
    % Check to see that we don't get negative frequencies. If they do
    % occur, assign traditional values.
    if subj{i}.meanTF - 4 < 0
        subj{i}.Delta_floor = 0;
    else
        subj{i}.Delta_floor = subj{i}.meanTF - 4;
    end
    if subj{i}.meanTF - 2 < 0
        subj{i}.Delta_ceiling = 4;
        subj{i}.Theta_floor   = 4;
    else
        subj{i}.Delta_ceiling = subj{i}.meanTF - 2;
        subj{i}.Theta_floor   = subj{i}.meanTF - 2;
    end
    subj{i}.Theta_ceiling  = subj{i}.meanTF;
    subj{i}.Alpha_floor    = subj{i}.meanTF;
    subj{i}.Alpha1_floor   = subj{i}.meanTF;
    subj{i}.Alpha1_ceiling = (subj{i}.meanIAF + subj{i}.meanTF) / 2;
    subj{i}.Alpha2_floor   = (subj{i}.meanIAF + subj{i}.meanTF) / 2;
    subj{i}.Alpha2_ceiling = subj{i}.meanIAF;
    subj{i}.Alpha3_floor   = subj{i}.meanIAF;
    subj{i}.Alpha3_ceiling = subj{i}.meanIAF + 2;
    subj{i}.Alpha_ceiling  = subj{i}.meanIAF + 2;
    % TODO: Find peaks and troughs, use to calculate these
    %subj{i}.Beta1_floor    = 
    %subj{i}.Beta1_ceiling  = 
    %subj{i}.Beta2_floor    = 
    %ubj{i}.Beta2_ceiling  = 
    %subj{i}.Gamma_floor    = 
    % -- Gamma ceiling already set
    
    % Compute power across derived bands
    subj{i}.mean_DeltaPower  = mean(10.^(spectra(freq >= subj{i}.Delta_floor & freq <= subj{i}.Delta_ceiling)/10));
    subj{i}.mean_thetaPower  = mean(10.^(spectra(freq >= subj{i}.Theta_floor & freq <= subj{i}.Theta_ceiling)/10));
    subj{i}.mean_alphaPower  = mean(10.^(spectra(freq >= subj{i}.Alpha_floor & freq <= subj{i}.Alpha_ceiling)/10));
    subj{i}.mean_alpha1Power = mean(10.^(spectra(freq >= subj{i}.meanTF & freq <= subj{i}.Alpha2_floor)/10));
    subj{i}.mean_alpha2Power = mean(10.^(spectra(freq >= subj{i}.Alpha2_floor & freq <= subj{i}.meanIAF)/10));
    subj{i}.mean_alpha3Power = mean(10.^(spectra(freq >= subj{i}.meanIAF & freq <= subj{i}.Alpha3_ceiling)/10));
    
    % Compute ratios using both fixed and calculated bands
    subj{i}.ratio_meanAlpha32Fixed    = subj{i}.mean_falpha3Power / subj{i}.mean_falpha2Power;
    subj{i}.ratio_meanAlphaThetaFixed = subj{i}.mean_falphaPower / subj{i}.mean_fthetaPower;
    subj{i}.ratio_meanAlpha32    = subj{i}.mean_alpha3Power / subj{i}.mean_alpha2Power;
    subj{i}.ratio_meanAlphaTheta = subj{i}.mean_alphaPower / subj{i}.mean_thetaPower;
end
structFile = strcat(exportpath, '/', date, '-results', '.mat');
save(structFile, 'subj');

