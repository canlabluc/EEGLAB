% This script utilizes nbt_doPeakFit and EEGLAB's spectopo() function to calculate
% absolute power across both calculated power bands and fixed ones. Note
% that since spectopo() returns the Power Spectrum Density in
% 10*log10(uV^2), we need to apply a few transformations to acquire uV^2,
% or absolute power. 

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
cd ~/nbt
installNBT;
files = dir(fullfile(strcat(importpath, '/*S.mat')));
subj{size(files, 1)} = [];
C3trodes = [11 15 17 20];
O1trodes = [25 26 27];
for i = 1:numel(files)
    [Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(i).name));
    subj{i}.SubjectID = files(i).name;
    % Preallocate memory for IAFs / TFs, as well as the IAFs / TFs for the C3 O1
    % electrodes, which we'll be using for the Alpha/Theta ratio.
    subj{i}.IAFs   = zeros(1, size(Signal,2));
    subj{i}.TFs    = zeros(1, size(Signal,2));
    subj{i}.O1IAFs = zeros(1, size(O1trodes,2));
    subj{i}.O1TFs  = zeros(1, size(O1trodes,2));
    subj{i}.C3IAFs = zeros(1, size(C3trodes,2));
    subj{i}.C3TFs  = zeros(1, size(C3trodes,2));
    for j = 1:size(Signal,2)
        % Calculate IAF, TF for each channel, and then find the average for
        % the IAF and TF, excluding the NaN values. Check: Does computing
        % IAF, TF for each channel produce the same value as taking the
        % grand average and computing the IAF / TF?
        tempPeakObj  = nbt_doPeakFit(Signal(:,j), SignalInfo);
        subj{i}.IAFs(j) = tempPeakObj.IAF;
        subj{i}.TFs(j)  = tempPeakObj.TF;
        if any(C3trodes == j)
            subj{i}.O1IAFs(j) = tempPeakObj.IAF;
            subj{i}.O1TFs(j)  = tempPeakObj.TF;
        elseif any(O1trodes == j);
            subj{i}.C3IAFs(j) = tempPeakObj.IAF;
            subj{i}.C3TFs(j)  = tempPeakObj.TF;
        end
    end    
    subj{i}.meanIAF   = nanmean(subj{i}.IAFs);
    subj{i}.meanTF    = nanmean(subj{i}.TFs);
    % Take the grand average for the subject, then find PSD of grand average
    [avgPSD, avgFreq] = spectopo(nanmean(Signal'), 0, 512, 'plot', 'off');
    subj{i}.avgPSD  = avgPSD;
    subj{i}.avgFreq = avgFreq;
    
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
    subj{i}.fixedGamma_ceiling  = 45; % Gamma ceiling is 45 Hz for fixed and IAF-based bands
    
    % ---- FREQUENCY BANDS DERIVED FROM IAF & TF ---- %
    subj{i}.peakFit = nbt_doPeakFit(Signal, SignalInfo);
    subj{i}.meanIAF = nanmean(subj{i}.peakFit.IAF);
    subj{i}.meanTF  = nanmean(subj{i}.peakFit.TF);
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
    
    % Calculate absolute power (amplitude^2) across fixed (traditional) frequency bands
    subj{i}.mean_fdeltaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedDelta_floor  & avgFreq <= subj{i}.fixedDelta_ceiling)/10));
    subj{i}.mean_fthetaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedTheta_floor  & avgFreq <= subj{i}.fixedTheta_ceiling)/10));
    subj{i}.mean_falphaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedAlpha_floor  & avgFreq <= subj{i}.fixedAlpha_ceiling)/10));
    subj{i}.mean_fbetaPower   = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedBeta_floor   & avgFreq <= subj{i}.fixedBeta_ceiling)/10));
    subj{i}.mean_fgammaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedGamma_floor  & avgFreq <= subj{i}.fixedGamma_ceiling)/10));
    subj{i}.mean_falpha1Power = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedAlpha1_floor & avgFreq <= subj{i}.fixedAlpha1_ceiling)/10));
    subj{i}.mean_falpha2Power = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedAlpha2_floor & avgFreq <= subj{i}.fixedAlpha2_ceiling)/10));
    subj{i}.mean_falpha3Power = nanmean(10.^(avgPSD(avgFreq >= subj{i}.fixedAlpha3_floor & avgFreq <= subj{i}.fixedAlpha3_ceiling)/10));

    % Compute absolute power across derived bands
    subj{i}.mean_DeltaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.Delta_floor  & avgFreq <= subj{i}.Delta_ceiling)/10));
    subj{i}.mean_thetaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.Theta_floor  & avgFreq <= subj{i}.Theta_ceiling)/10));
    subj{i}.mean_alphaPower  = nanmean(10.^(avgPSD(avgFreq >= subj{i}.Alpha_floor  & avgFreq <= subj{i}.Alpha_ceiling)/10));
    subj{i}.mean_alpha1Power = nanmean(10.^(avgPSD(avgFreq >= subj{i}.meanTF       & avgFreq <= subj{i}.Alpha2_floor)/10));
    subj{i}.mean_alpha2Power = nanmean(10.^(avgPSD(avgFreq >= subj{i}.Alpha2_floor & avgFreq <= subj{i}.meanIAF)/10));
    subj{i}.mean_alpha3Power = nanmean(10.^(avgPSD(avgFreq >= subj{i}.meanIAF      & avgFreq <= subj{i}.Alpha3_ceiling)/10));
    
    % Compute ratios using both fixed and calculated bands
    subj{i}.ratio_meanAlpha32Fixed    = subj{i}.mean_falpha3Power / subj{i}.mean_falpha2Power;
    subj{i}.ratio_meanAlphaThetaFixed = subj{i}.mean_falphaPower / subj{i}.mean_fthetaPower;
    subj{i}.ratio_meanAlpha32    = subj{i}.mean_alpha3Power / subj{i}.mean_alpha2Power;
    subj{i}.ratio_meanAlphaTheta = subj{i}.mean_alphaPower / subj{i}.mean_thetaPower;
    
    % ---- ALPHA THETA RATIO CALCULATION ---- %
    % 1. Take grand average for both C3 and O1, average the IAF of each
    % channel that makes up C3, O1. 
    % 2. Calculate frequency bands for C3, O1
    % 3. Compute AlphaTheta ratio for both C3 and O1
    avgC3Signal = mean(Signal(:,C3trodes(1)),2);
    for k = 2:numel(C3trodes)
        avgC3Signal = (mean(Signal(:,C3trodes(k)),2) + avgC3Signal) / 2;
    end
    avgO1Signal = mean(Signal(:,O1trodes(1)),2);
    for l = 2:numel(O1trodes)
        avgO1Signal = (mean(Signal(:,O1trodes(l)),2) + avgO1Signal) / 2;
    end 
    C3PeakFit = nbt_doPeakFit(avgC3Signal, SignalInfo);
    O1PeakFit = nbt_doPeakFit(avgO1Signal, SignalInfo);
    % Calculate frequency bands
    subj{i}.O1meanIAF = nanmean(subj{i}.O1IAFs);
    subj{i}.O1meanTF  = nanmean(subj{i}.O1TFs);
    subj{i}.C3meanIAF = nanmean(subj{i}.C3IAFs);
    subj{i}.C3meanTF  = nanmean(subj{i}.C3TFs);
    % Todo: Place C3, O1 information into separate structure inside of subj?
    % --- C3 --- %
    if subj{i}.C3meanTF - 4 < 1 
        subj{i}.C3Delta_floor = 1;
    else
        subj{i}.C3Delta_floor = subj{i}.C3meanTF - 4;
    end
    if subj{i}.C3meanTF - 2 < 1
        subj{i}.C3Delta_ceiling = 4;
        subj{i}.C3Theta_floor   = 4;
    else
        subj{i}.C3Delta_ceiling = subj{i}.C3meanTF - 2;
        subj{i}.C3Theta_floor   = subj{i}.C3meanTF - 2;
    end
    subj{i}.C3Theta_ceiling  = subj{i}.C3meanTF;
    subj{i}.C3Alpha_floor    = subj{i}.C3meanTF;
    subj{i}.C3Alpha1_floor   = subj{i}.C3meanTF;
    subj{i}.C3Alpha1_ceiling = (subj{i}.C3meanIAF + subj{i}.C3meanTF) / 2;
    subj{i}.C3Alpha2_floor   = (subj{i}.C3meanIAF + subj{i}.C3meanTF) / 2;
    subj{i}.C3Alpha2_ceiling = subj{i}.C3meanIAF;
    subj{i}.C3Alpha3_floor   = subj{i}.C3meanIAF;
    subj{i}.C3Alpha3_ceiling = subj{i}.C3meanIAF + 2;
    subj{i}.C3Alpha_ceiling  = subj{i}.C3meanIAF + 2;
    % --- O1 -- %
    if subj{i}.O1meanTF - 4 < 1 
        subj{i}.O1Delta_floor = 1;
    else
        subj{i}.O1Delta_floor = subj{i}.O1meanTF - 4;
    end
    if subj{i}.O1meanTF - 2 < 1
        subj{i}.O1Delta_ceiling = 4;
        subj{i}.O1Theta_floor   = 4;
    else
        subj{i}.O1Delta_ceiling = subj{i}.O1meanTF - 2;
        subj{i}.O1Theta_floor   = subj{i}.O1meanTF - 2;
    end
    subj{i}.O1Theta_ceiling  = subj{i}.O1meanTF;
    subj{i}.O1Alpha_floor    = subj{i}.O1meanTF;
    subj{i}.O1Alpha1_floor   = subj{i}.O1meanTF;
    subj{i}.O1Alpha1_ceiling = (subj{i}.O1meanIAF + subj{i}.O1meanTF) / 2;
    subj{i}.O1Alpha2_floor   = (subj{i}.O1meanIAF + subj{i}.O1meanTF) / 2;
    subj{i}.O1Alpha2_ceiling = subj{i}.O1meanIAF;
    subj{i}.O1Alpha3_floor   = subj{i}.O1meanIAF;
    subj{i}.O1Alpha3_ceiling = subj{i}.O1meanIAF + 2;
    subj{i}.O1Alpha_ceiling  = subj{i}.O1meanIAF + 2;
    
    [avgPSDC3, avgFreqC3] = spectopo(avgC3Signal', 0, 512, 'plot','off');
    [avgPSDO1, avgFreqO1] = spectopo(avgO1Signal', 0, 512, 'plot','off');
    
    subj{i}.C3_DeltaPower  = nanmean(10.^(avgPSDC3(avgFreqC3 >= subj{i}.C3Delta_floor  & avgFreqC3 <= subj{i}.C3Delta_ceiling)/10));
    subj{i}.C3_thetaPower  = nanmean(10.^(avgPSDC3(avgFreqC3 >= subj{i}.C3Theta_floor  & avgFreqC3 <= subj{i}.C3Theta_ceiling)/10));
    subj{i}.C3_alphaPower  = nanmean(10.^(avgPSDC3(avgFreqC3 >= subj{i}.C3Alpha_floor  & avgFreqC3 <= subj{i}.C3Alpha_ceiling)/10));
    subj{i}.C3_alpha1Power = nanmean(10.^(avgPSDC3(avgFreqC3 >= subj{i}.C3meanTF       & avgFreqC3 <= subj{i}.C3Alpha2_floor)/10));
    subj{i}.C3_alpha2Power = nanmean(10.^(avgPSDC3(avgFreqC3 >= subj{i}.C3Alpha2_floor & avgFreqC3 <= subj{i}.C3meanIAF)/10));
    subj{i}.C3_alpha3Power = nanmean(10.^(avgPSDC3(avgFreqC3 >= subj{i}.C3meanIAF      & avgFreqC3 <= subj{i}.C3Alpha3_ceiling)/10));
    
    subj{i}.O1_DeltaPower  = nanmean(10.^(avgPSDO1(avgFreqO1 >= subj{i}.O1Delta_floor  & avgFreqO1 <= subj{i}.O1Delta_ceiling)/10));
    subj{i}.O1_thetaPower  = nanmean(10.^(avgPSDO1(avgFreqO1 >= subj{i}.O1Theta_floor  & avgFreqO1 <= subj{i}.O1Theta_ceiling)/10));
    subj{i}.O1_alphaPower  = nanmean(10.^(avgPSDO1(avgFreqO1 >= subj{i}.O1Alpha_floor  & avgFreqO1 <= subj{i}.O1Alpha_ceiling)/10));
    subj{i}.O1_alpha1Power = nanmean(10.^(avgPSDO1(avgFreqO1 >= subj{i}.O1meanTF       & avgFreqO1 <= subj{i}.O1Alpha2_floor)/10));
    subj{i}.O1_alpha2Power = nanmean(10.^(avgPSDO1(avgFreqO1 >= subj{i}.O1Alpha2_floor & avgFreqO1 <= subj{i}.O1meanIAF)/10));
    subj{i}.O1_alpha3Power = nanmean(10.^(avgPSDO1(avgFreqO1 >= subj{i}.O1meanIAF      & avgFreqO1 <= subj{i}.O1Alpha3_ceiling)/10));
end
structFile = strcat(exportpath, '/', date, '-results', '.mat');
save(structFile, 'subj');

