% This script utilizes nbt_doPeakFit and EEGLAB's spectopo() function to calculate
% absolute power across both calculated power bands and fixed ones. Note
% that since spectopo() returns the Power Spectrum Density in units of
% 10*log10(uV^2), we need to apply a few transformations to acquire uV^2,
% or absolute power. 

importpath = uigetdir('~', 'Select folder to import from (contains .mat files)');
if importpath == 0
    error('Error: Please specify the folder that contains the .mat files.');
end
fprintf('Import path: %s\n', importpath);
exportpath = uigetdir('~', 'Select folder to export resulting struct to');
if exportpath == 0
    error('Error: Please specify the folder to export results files to.');
end
fprintf('Export path: %s\n', exportpath);
cd ~/nbt
installNBT;
files = dir(fullfile(strcat(importpath, '/*S.mat')));
subj{size(files, 1)} = [];
for i = 1:numel(files)
    [Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(i).name));
    subj{i}.SubjectID = files(i).name;
    % Preallocate memory for IAFs / TFs
    subj{i}.IAFs   = zeros(1, size(Signal,2));
    subj{i}.TFs    = zeros(1, size(Signal,2));
    subj{i}.rejectedIAFs = 0;
    subj{i}.rejectedTFs  = 0;
    for j = 1:size(Signal,2)
        % Calculate IAF, TF for each channel, and then find the average for
        % the IAF and TF, excluding the NaN values and incredibly low ones
        tempPeakObj = nbt_doPeakFit(Signal(:,j), SignalInfo);
        if isnan(tempPeakObj.IAF) || tempPeakObj.IAF < 1
            subj{i}.rejectedIAFs = subj{i}.rejectedIAFs + 1;
        else
            subj{i}.IAFs(j) = tempPeakObj.IAF;
        end
        if isnan(tempPeakObj.TF) || tempPeakObj.TF < 2
            subj{i}.rejectedTFs = subj{i}.rejectedTFs + 1;
        else
            subj{i}.TFs(j) = tempPeakObj.TF;
        end
    end
    % Calculate overall IAF and TF for this subject
    subj{i}.meanIAF = nanmean(subj{i}.IAFs);
    subj{i}.meanTF  = nanmean(subj{i}.TFs);
    % Take the grand average for the subject, then find PSD of grand average
    [avgPSD, avgFreq] = spectopo(nanmean(Signal'), 0, 512, 'plot', 'off');
    subj{i}.avgPSD  = avgPSD;
    subj{i}.avgFreq = avgFreq;
    
    % ---- FIXED FREQUENCY BANDS ---- %
    subj{i}.fixedDelta_floor    = 1;
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
    subj{i}.fixedGamma_ceiling  = 45; 
    % Gamma ceiling is 45 Hz for fixed and IAF-based bands
    
    % ---- FREQUENCY BANDS DERIVED FROM IAF & TF ---- %
    % Check to see that we don't get negative frequencies. If they do
    % occur, assign traditional values.
    if subj{i}.meanTF - 4 < 0
        subj{i}.Delta_floor = 1;
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
    %ubj{i}.Beta2_ceiling   = 
    %subj{i}.Gamma_floor    = 
    % -- Gamma ceiling already set
    
    % Calculate absolute power (amplitude^2) across fixed (traditional) frequency bands
    subj{i}.fixedDeltaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedDelta_floor  & avgFreq <= subj{i}.fixedDelta_ceiling)/10));
    subj{i}.fixedThetaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedTheta_floor  & avgFreq <= subj{i}.fixedTheta_ceiling)/10));
    subj{i}.fixedAlphaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedAlpha_floor  & avgFreq <= subj{i}.fixedAlpha_ceiling)/10));
    subj{i}.fixedBetaPower   = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedBeta_floor   & avgFreq <= subj{i}.fixedBeta_ceiling)/10));
    subj{i}.fixedGammaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedGamma_floor  & avgFreq <= subj{i}.fixedGamma_ceiling)/10));
    subj{i}.fixedAlpha1Power = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedAlpha1_floor & avgFreq <= subj{i}.fixedAlpha1_ceiling)/10));
    subj{i}.fixedAlpha2Power = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedAlpha2_floor & avgFreq <= subj{i}.fixedAlpha2_ceiling)/10));
    subj{i}.fixedAlpha3Power = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedAlpha3_floor & avgFreq <= subj{i}.fixedAlpha3_ceiling)/10));

    % Compute absolute power across derived bands
    subj{i}.DeltaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.Delta_floor  & avgFreq <= subj{i}.Delta_ceiling)/10));
    subj{i}.ThetaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.Theta_floor  & avgFreq <= subj{i}.Theta_ceiling)/10));
    subj{i}.AlphaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.Alpha_floor  & avgFreq <= subj{i}.Alpha_ceiling)/10));
    subj{i}.Alpha1Power = nanmean(10.^(avgPSD(avgFreq >= subj{i}.meanTF       & avgFreq <= subj{i}.Alpha2_floor)/10));
    subj{i}.Alpha2Power = nanmean(10.^(avgPSD(avgFreq >= subj{i}.Alpha2_floor & avgFreq <= subj{i}.meanIAF)/10));
    subj{i}.Alpha3Power = nanmean(10.^(avgPSD(avgFreq >= subj{i}.meanIAF      & avgFreq <= subj{i}.Alpha3_ceiling)/10));
    
    % Compute ratios using both fixed and calculated bands
    subj{i}.ratio_Alpha32Fixed    = subj{i}.fixedAlpha3Power / subj{i}.fixedAlpha2Power;
    subj{i}.ratio_AlphaThetaFixed = subj{i}.fixedAlphaPower / subj{i}.fixedThetaPower;
    subj{i}.ratio_Alpha32    = subj{i}.Alpha3Power / subj{i}.Alpha2Power;
    subj{i}.ratio_AlphaTheta = subj{i}.AlphaPower / subj{i}.ThetaPower;
end
structFile = strcat(exportpath, '/', date, '-results', '.mat');
save(structFile, 'subj');

