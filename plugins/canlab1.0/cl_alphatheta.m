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
    
    % --- Derive frequency bands for C3 and O1 using IAF and TF --- %
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

    % Run spectopo to acquire power spectrum, and calculate absoltue power
    [C3avgPSD, C3avgFreq] = spectopo(subj{i}.avgC3Signal', 0, 512, 'plot', 'off');
    [O1avgPSD, O1avgFreq] = spectopo(subj{i}.avgO1Signal', 0, 512, 'plot', 'off');
    % --- C3 Power --- %
    subj{i}.C3deltaPower      = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.C3deltaFloor  & C3avgFreq <= subj{i}.C3deltaCeiling)/10));
    subj{i}.C3thetaPower      = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.C3thetaFloor  & C3avgFreq <= subj{i}.C3thetaCeiling)/10));
    subj{i}.C3alphaPower      = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.C3alphaFloor  & C3avgFreq <= subj{i}.C3alphaCeiling)/10));
    subj{i}.C3alpha1Power     = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.C3alpha1Floor & C3avgFreq <= subj{i}.C3alphaCeiling)/10));
    subj{i}.C3alpha2Power     = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.C3alpha2Floor & C3avgFreq <= subj{i}.C3alpha2Ceiling)/10));
    subj{i}.C3alpha3Power     = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.C3alpha3Floor & C3avgFreq <= subj{i}.C3alpha3Ceiling)/10));
    subj{i}.C3fixedbetaPower  = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.C3betaFloor   & C3avgFreq <= subj{i}.C3betaCeiling)/10));
    subj{i}.C3fixedgammaPower = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.C3gammaFloor  & C3avgFreq <= subj{i}.C3gammaCeiling)/10));
    % --- O1 Power --- %
    subj{i}.O1deltaPower      = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.O1deltaFloor  & O1avgFreq <= subj{i}.O1deltaCeiling)/10));
    subj{i}.O1thetaPower      = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.O1thetaFloor  & O1avgFreq <= subj{i}.O1thetaCeiling)/10));
    subj{i}.O1alphaPower      = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.O1alphaFloor  & O1avgFreq <= subj{i}.O1alphaCeiling)/10));
    subj{i}.O1alpha1Power     = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.O1alpha1Floor & O1avgFreq <= subj{i}.O1alphaCeiling)/10));
    subj{i}.O1alpha2Power     = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.O1alpha2Floor & O1avgFreq <= subj{i}.O1alpha2Ceiling)/10));
    subj{i}.O1alpha3Power     = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.O1alpha3Floor & O1avgFreq <= subj{i}.O1alpha3Ceiling)/10));
    subj{i}.O1fixedbetaPower  = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.O1betaFloor   & O1avgFreq <= subj{i}.O1betaCeiling)/10));
    subj{i}.O1fixedgammaPower = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.O1gammaFloor  & O1avgFreq <= subj{i}.O1gammaCeiling)/10));
    % --- Power using fixed frequency bands --- %
    subj{i}.O1deltaPower_fixed      = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.deltaFloor_fixed  & O1avgFreq <= subj{i}.deltaCeiling_fixed)/10));
    subj{i}.O1thetaPower_fixed      = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.thetaFloor_fixed  & O1avgFreq <= subj{i}.thetaCeiling_fixed)/10));
    subj{i}.O1alphaPower_fixed      = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.alphaFloor_fixed  & O1avgFreq <= subj{i}.alphaCeiling_fixed)/10));
    subj{i}.O1alpha1Power_fixed     = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.alpha1Floor_fixed & O1avgFreq <= subj{i}.alphaCeiling_fixed)/10));
    subj{i}.O1alpha2Power_fixed     = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.alpha2Floor_fixed & O1avgFreq <= subj{i}.alpha2Ceiling_fixed)/10));
    subj{i}.O1alpha3Power_fixed     = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.alpha3Floor_fixed & O1avgFreq <= subj{i}.alpha3Ceiling_fixed)/10));
    subj{i}.O1fixedbetaPower_fixed  = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.betaFloor_fixed  & O1avgFreq <= subj{i}.betaCeiling_fixed)/10));
    subj{i}.O1fixedgammaPower_fixed = nanmean(10.^(O1avgPSD(O1avgFreq >= subj{i}.gammaFloor_fixed  & O1avgFreq <= subj{i}.gammaCeiling_fixed)/10));
    subj{i}.C3deltaPower_fixed      = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.deltaFloor_fixed  & C3avgFreq <= subj{i}.deltaCeiling_fixed)/10));
    subj{i}.C3thetaPower_fixed      = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.thetaFloor_fixed  & C3avgFreq <= subj{i}.thetaCeiling_fixed)/10));
    subj{i}.C3alphaPower_fixed      = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.alphaFloor_fixed  & C3avgFreq <= subj{i}.alphaCeiling_fixed)/10));
    subj{i}.C3alpha1Power_fixed     = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.alpha1Floor_fixed & C3avgFreq <= subj{i}.alphaCeiling_fixed)/10));
    subj{i}.C3alpha2Power_fixed     = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.alpha2Floor_fixed & C3avgFreq <= subj{i}.alpha2Ceiling_fixed)/10));
    subj{i}.C3alpha3Power_fixed     = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.alpha3Floor_fixed & C3avgFreq <= subj{i}.alpha3Ceiling_fixed)/10));
    subj{i}.C3fixedbetaPower_fixed  = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.betaFloor_fixed  & C3avgFreq <= subj{i}.betaCeiling_fixed)/10));
    subj{i}.C3fixedgammaPower_fixed = nanmean(10.^(C3avgPSD(C3avgFreq >= subj{i}.gammaFloor_fixed  & C3avgFreq <= subj{i}.gammaCeiling_fixed)/10));
    
    % Calculate ratios
    subj{i}.C3AlphaThetaRatio = subj{i}.C3alphaPower / subj{i}.C3thetaPower; 
    subj{i}.O1AlphaThetaRatio = subj{i}.O1alphaPower / subj{i}.O1thetaPower;
    subj{i}.C3AlphaThetaRatio_fixed = subj{i}.C3alphaPower_fixed / subj{i}.C3alphaPower_fixed;
    subj{i}.O1AlphaThetaRatio_fixed = subj{i}.O1alphaPower_fixed / subj{i}.O1alphaPower_fixed;

    subj{i}.C3UpperLowAlphaRatio = subj{i}.C3alpha3Power / subj{i}.C3alpha3Power;
    subj{i}.O1UpperLowAlphaRatio = subj{i}.O1alpha3Power / subj{i}.O1alpha3Power;
end