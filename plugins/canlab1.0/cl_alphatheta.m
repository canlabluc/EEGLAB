% ---- Alpha / Theta Ratio for C3, O1 ---- %
% This script calculates the alpha/theta and alpha3/alpha2 ratios and derived 
% frequency bands for the C3, O1 area electrodes. 

C3trodes = [11 15 17 20];
O1trodes = [25 26 27];

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
subj{size(files,1)} = [];
approach = 1;
for i = 1:numel(files)
    [Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(i).name));
    subj{i}.SubjectID = files(i).name(9:11);
    subj{i}.C3{1}.Signal = zeros(1,size(Signal,1));
    subj{i}.O1{1}.Signal = zeros(1,size(Signal,1));
    C3Added = 1;
    O1Added = 1;
    for j = 1:size(Signal, 2)
        if any(C3trodes == j)
            C3PeakFit = nbt_doPeakFit(Signal(:,j), SignalInfo);
            subj{i}.C3{C3Added}.Signal = Signal(:,j);
            subj{i}.C3{C3Added}.IAF = C3PeakFit.IAF;
            subj{i}.C3{C3Added}.TF  = C3PeakFit.TF;
            C3Added = C3Added + 1;
        elseif any(O1trodes == j)
            O1PeakFit = nbt_doPeakFit(Signal(:,j), SignalInfo);
            subj{i}.O1{O1Added}.Signal = Signal(:,j);
            subj{i}.O1{O1Added}.IAF = O1PeakFit.IAF;
            subj{i}.O1{O1Added}.TF  = O1PeakFit.TF;
            O1Added = O1Added + 1;
        end
    end
    subj{i}.avgC3Signal = subj{i}.C3{1}.Signal;
    subj{i}.avgO1Signal = subj{i}.O1{1}.Signal;
    for k = 2:numel(subj{i}.C3)
        subj{i}.avgC3Signal = (subj{i}.avgC3Signal + subj{i}.C3{k}.Signal) / 2;        
    end
    for k = 2:numel(subj{i}.O1)
        subj{i}.avgO1Signal = (subj{i}.avgO1Signal + subj{i}.O1{k}.Signal) / 2;     
    end
    
    % ------------------------------------------------------------------ %
    % Find IAF, TF, and use these to find individualized frequency bands %
    % ------------------------------------------------------------------ %

    C3PeakFit = nbt_doPeakFit(subj{i}.avgC3Signal, SignalInfo);
    O1PeakFit = nbt_doPeakFit(subj{i}.avgO1Signal, SignalInfo);
    % Make sure that IAFs and TFs for both expected values -- if nbt_doPeakFit
    % failed to properly fit peaks, it returns NaN or values < 1
    if isnan(C3PeakFit.IAF)
        subj{i}.C3IAF = 9;
        C3PeakFit.IAF = 9;
    else
        subj{i}.C3IAF = C3PeakFit.IAF;
    end
    if isnan(C3PeakFit.TF) || C3PeakFit.TF < 1
        subj{i}.C3TF = 4.5;
        C3PeakFit.TF = 4.5;
    else
        subj{i}.C3TF = C3PeakFit.TF;
    end
    if isnan(O1PeakFit.IAF)
        subj{i}.O1IAF = 9;
        O1PeakFit.IAF = 9;
    else
        subj{i}.O1IAF = O1PeakFit.IAF;
    end
    if isnan(O1PeakFit.TF) || O1PeakFit.TF < 1
        subj{i}.O1TF = 4.5;
        O1PeakFit.TF = 4.5;
    else
        subj{i}.O1TF = O1PeakFit.TF;
    end
    if C3PeakFit.TF - 4 < .25
        subj{i}.C3deltaFloor = .5;
    else
        subj{i}.C3deltaFloor = C3PeakFit.TF - 4;
    end
    if C3PeakFit.TF - 2 < subj{i}.C3deltaFloor
        subj{i}.C3thetaFloor = subj{i}.C3deltaFloor + 1.5;
        subj{i}.C3deltaCeiling = subj{i}.C3deltaFloor + 1.5;
    else
        subj{i}.C3thetaFloor = C3PeakFit.TF - 2;
        subj{i}.C3deltaCeiling = C3PeakFit.TF - 2;
    end
    subj{i}.C3thetaCeiling  = C3PeakFit.TF;
    subj{i}.C3alphaFloor    = C3PeakFit.TF;
    subj{i}.C3alpha1Floor   = C3PeakFit.TF;
    subj{i}.C3alpha1Ceiling = (C3PeakFit.TF + C3PeakFit.IAF) / 2;
    subj{i}.C3alpha2Floor   = (C3PeakFit.TF + C3PeakFit.IAF) / 2;
    subj{i}.C3alpha2Ceiling = C3PeakFit.IAF;
    subj{i}.C3alpha3Floor   = C3PeakFit.IAF;
    subj{i}.C3alpha3Ceiling = C3PeakFit.IAF + 2;
    subj{i}.C3alphaCeiling  = C3PeakFit.IAF + 2;
    subj{i}.C3betaFloor     = C3PeakFit.IAF + 2;
    subj{i}.C3betaCeiling   = 30;
    subj{i}.C3gammaFloor    = 30;
    subj{i}.C3gammaCeiling  = 45;

    if O1PeakFit.TF - 4 < .25
        subj{i}.O1deltaFloor = .5;
    else
        subj{i}.O1deltaFloor = O1PeakFit.TF - 4;
    end
    if O1PeakFit.TF - 2 < subj{i}.O1deltaFloor
        subj{i}.O1thetaFloor = subj{i}.O1deltaFloor + 1.5;
        subj{i}.O1deltaCeiling = subj{i}.O1deltaFloor + 1.5;
    else
        subj{i}.O1thetaFloor = O1PeakFit.TF - 2;
        subj{i}.O1deltaCeiling = O1PeakFit.TF - 2;
    end
    subj{i}.O1thetaCeiling  = O1PeakFit.TF;
    subj{i}.O1alphaFloor    = O1PeakFit.TF;
    subj{i}.O1alpha1Floor   = O1PeakFit.TF;
    subj{i}.O1alpha1Ceiling = (O1PeakFit.TF + O1PeakFit.IAF) / 2;
    subj{i}.O1alpha2Floor   = (O1PeakFit.TF + O1PeakFit.IAF) / 2;
    subj{i}.O1alpha2Ceiling = O1PeakFit.IAF;
    subj{i}.O1alpha3Floor   = O1PeakFit.IAF;
    subj{i}.O1alpha3Ceiling = O1PeakFit.IAF + 2;
    subj{i}.O1alphaCeiling  = O1PeakFit.IAF + 2;
    subj{i}.O1betaFloor     = O1PeakFit.IAF + 2;
    subj{i}.O1betaCeiling   = 30;
    subj{i}.O1gammaFloor    = 30;
    subj{i}.O1gammaCeiling  = 45;
    
    subj{i}.deltaFloor_fixed    = 1;     
    subj{i}.deltaCeiling_fixed  = 4;     
    subj{i}.thetaFloor_fixed    = 4; 
    subj{i}.thetaCeiling_fixed  = 8; 
    subj{i}.alphaFloor_fixed    = 8; 
    subj{i}.alpha1Floor_fixed   = 8; 
    subj{i}.alpha1Ceiling_fixed = 9.25; 
    subj{i}.alpha2Floor_fixed   = 9.25; 
    subj{i}.alpha2Ceiling_fixed = 10.5; 
    subj{i}.alpha3Floor_fixed   = 10.5; 
    subj{i}.alpha3Ceiling_fixed = 13; 
    subj{i}.alphaCeiling_fixed  = 13;     
    subj{i}.betaFloor_fixed     = 13;
    subj{i}.betaCeiling_fixed   = 30;
    subj{i}.gammaFloor_fixed    = 30;
    subj{i}.gammaCeiling_fixed  = 45;

    % --------------- %
    % Calculate Power %
    % --------------- %

    % Run spectopo to acquire power spectrum, and calculate absolute power
    [C3avgPSD, C3avgFreq] = spectopo(subj{i}.avgC3Signal', 0, 512, 'plot', 'off');
    [O1avgPSD, O1avgFreq] = spectopo(subj{i}.avgO1Signal', 0, 512, 'plot', 'off');

    % --- C3 Power --- %
    subj{i}.C3deltaPower      = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3deltaFloor,  subj{i}.C3deltaCeiling);
    subj{i}.C3thetaPower      = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3thetaFloor,  subj{i}.C3thetaCeiling);
    subj{i}.C3alphaPower      = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3alphaFloor,  subj{i}.C3alphaCeiling);
    subj{i}.C3alpha1Power     = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3alpha1Floor, subj{i}.C3alpha1Ceiling);
    subj{i}.C3alpha2Power     = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3alpha2Floor, subj{i}.C3alpha2Ceiling);
    subj{i}.C3alpha3Power     = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3alpha3Floor, subj{i}.C3alpha3Ceiling);
    subj{i}.C3fixedbetaPower  = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3betaFloor,   subj{i}.C3betaCeiling);
    subj{i}.C3fixedgammaPower = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3gammaFloor,  subj{i}.C3gammaCeiling);
    
    % --- O1 Power --- %
    subj{i}.O1deltaPower      = calculatePower(O1avgPSD, O1avgFreq, subj{i}.O1deltaFloor,  subj{i}.O1deltaCeiling);
    subj{i}.O1thetaPower      = calculatePower(O1avgPSD, O1avgFreq, subj{i}.O1thetaFloor,  subj{i}.O1thetaCeiling);
    subj{i}.O1alphaPower      = calculatePower(O1avgPSD, O1avgFreq, subj{i}.O1alphaFloor,  subj{i}.O1alphaCeiling);
    subj{i}.O1alpha1Power     = calculatePower(O1avgPSD, O1avgFreq, subj{i}.O1alpha1Floor, subj{i}.O1alpha1Ceiling);
    subj{i}.O1alpha2Power     = calculatePower(O1avgPSD, O1avgFreq, subj{i}.O1alpha2Floor, subj{i}.O1alpha2Ceiling);
    subj{i}.O1alpha3Power     = calculatePower(O1avgPSD, O1avgFreq, subj{i}.O1alpha3Floor, subj{i}.O1alpha3Ceiling);
    subj{i}.O1fixedbetaPower  = calculatePower(O1avgPSD, O1avgFreq, subj{i}.O1betaFloor,   subj{i}.O1betaCeiling);
    subj{i}.O1fixedgammaPower = calculatePower(O1avgPSD, O1avgFreq, subj{i}.O1gammaFloor,  subj{i}.O1gammaCeiling);
    
    % --- Power using fixed frequency bands --- %
    subj{i}.O1deltaPower_fixed      = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3deltaFloor,  subj{i}.C3deltaCeiling);
    subj{i}.O1thetaPower_fixed      = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3thetaFloor,  subj{i}.C3thetaCeiling);
    subj{i}.O1alphaPower_fixed      = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3alphaFloor,  subj{i}.C3alphaCeiling);
    subj{i}.O1alpha1Power_fixed     = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3alpha1Floor, subj{i}.C3alpha1Ceiling);
    subj{i}.O1alpha2Power_fixed     = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3alpha2Floor, subj{i}.C3alpha2Ceiling);
    subj{i}.O1alpha3Power_fixed     = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3alpha3Floor, subj{i}.C3alpha3Ceiling);
    subj{i}.O1fixedbetaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3betaFloor,   subj{i}.C3betaCeiling);
    subj{i}.O1fixedgammaPower_fixed = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3gammaFloor,  subj{i}.C3gammaCeiling);
    subj{i}.C3deltaPower_fixed      = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3deltaFloor,  subj{i}.C3deltaCeiling);
    subj{i}.C3thetaPower_fixed      = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3thetaFloor,  subj{i}.C3thetaCeiling);
    subj{i}.C3alphaPower_fixed      = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3alphaFloor,  subj{i}.C3alphaCeiling);
    subj{i}.C3alpha1Power_fixed     = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3alpha1Floor, subj{i}.C3alpha1Ceiling);
    subj{i}.C3alpha2Power_fixed     = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3alpha2Floor, subj{i}.C3alpha2Ceiling);
    subj{i}.C3alpha3Power_fixed     = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3alpha3Floor, subj{i}.C3alpha3Ceiling);
    subj{i}.C3fixedbetaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3betaFloor,   subj{i}.C3betaCeiling);
    subj{i}.C3fixedgammaPower_fixed = calculatePower(C3avgPSD, C3avgFreq, subj{i}.C3gammaFloor,  subj{i}.C3gammaCeiling);
    
    % Calculate ratios
    subj{i}.C3AlphaThetaRatio = subj{i}.C3alphaPower / subj{i}.C3thetaPower; 
    subj{i}.O1AlphaThetaRatio = subj{i}.O1alphaPower / subj{i}.O1thetaPower;
    subj{i}.C3AlphaThetaRatio_fixed = subj{i}.C3alphaPower_fixed / subj{i}.C3alphaPower_fixed;
    subj{i}.O1AlphaThetaRatio_fixed = subj{i}.O1alphaPower_fixed / subj{i}.O1alphaPower_fixed;

    subj{i}.C3UpperLowAlphaRatio = subj{i}.C3alpha3Power / subj{i}.C3alpha3Power;
    subj{i}.O1UpperLowAlphaRatio = subj{i}.O1alpha3Power / subj{i}.O1alpha3Power;
end

% Calculates absolute power between specified frequencies in the power spectrum
% Spectopo returns the power spectrum density in units of 10*log10(uV^2 / Hz),
% which is why the following transformation is necessary.[1][2]
% http://sccn.ucsd.edu/pipermail/eeglablist/2015/009249.html
% http://sccn.ucsd.edu/pipermail/eeglablist/2015/009245.html
function absPower = calculatePower(PSD, Spectra, lowerFrequency, higherFrequency)
absPower = nanmean(10.^(PSD(Spectra >= lowerFrequency & Spectra <= higherFrequency)/10));
