% Calculates absolute power across both individualized frequency bands and
% fixed ones. Utilizes nbt_doPeakFit() and EEGLAB's spectopo() function.
%
% Usage:
%   >>> subj = cl_alpha3alpha2();
%   >>> subj = cl_alpha3alpha2(importpath, exportpath);
% 
% Inputs:
% importpath: A string which specifies the directory containing the .cnt files
%             that are to be imported
% 
% exportpath: A string which specifies the directory containing the .set files
%             that are to be saved for further analysis
% 
% Outputs:
% subj: An array of structures, one for each subject that is processed. The
%       structure contains all of the results of the analysis
% 
% Notes:
% Note that since spectopo() returns the Power Spectrum Density in units of
% 10*log10(uV^2), we need to apply a few transformations to acquire uV^2,
% or absolute power. 

function subj = cl_alpha3alpha2(importpath, exportpath)

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

cd ~/nbt
installNBT;
files = dir(fullfile(strcat(importpath, '/*S.mat')));
% Preallocation
subj(size(files, 1)) = struct();
[Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(1).name));
subj(:) = struct('SubjectID', 'SXXX',...
                 'meanIAF', 0.0,... % These are found by first finding the IAF and
                 'meanTF', 0.0,...  % TF of every channel, and then averaging them
                 'ratio_Alpha32', 0.0,...
                 'ratio_Alpha32Fixed', 0.0,...
                 'ratio_AlphaTheta', 0.0,...
                 'ratio_AlphaThetaFixed', 0.0,...
                 'IAFs', zeros(1, size(Signal,2)),...
                 'TFs',  zeros(1, size(Signal,2)),...
                 'Signal', zeros(1, size(Signal,1)),...
                 'rejectedIAFs', 0,...
                 'rejectedTFs', 0,...
                 'deltaFloor', 0.0,...
                 'deltaCeiling', 0.0,...
                 'thetaFloor', 0.0,...
                 'thetaCeiling', 0.0,...
                 'alphaFloor', 0.0,...
                 'alpha1Floor', 0.0,...
                 'alpha1Ceiling', 0.0,...
                 'alpha2Floor', 0.0,...
                 'alpha2Ceiling', 0.0,...
                 'alpha3Floor', 0.0,...
                 'alpha3Ceiling', 0.0,...
                 'betaFloor', 0.0,...
                 'betaCeiling', 0.0,...
                 'gammaFloor', 0.0,...
                 'gammaCeiling', 0.0,...
                 'deltaFloor_fixed',    0.5,...
                 'deltaCeiling_fixed',  4,...
                 'thetaFloor_fixed',    4,...
                 'thetaCeiling_fixed',  8,...
                 'alphaFloor_fixed',    8,...
                 'alpha1Floor_fixed',   8,...
                 'alpha1Ceiling_fixed', 9.25,...
                 'alpha2Floor_fixed',   9.25,...
                 'alpha2Ceiling_fixed', 10.5,...
                 'alpha3Floor_fixed',   10.5,...
                 'alpha3Ceiling_fixed', 13,...
                 'alphaCeiling_fixed',  13,...
                 'betaFloor_fixed',     13,...
                 'betaCeiling_fixed',   30,...
                 'gammaFloor_fixed',    30,...
                 'gammaCeiling_fixed',  45,...
                 'deltaPower', 0.0,...
                 'thetaPower', 0.0,...
                 'alphaPower', 0.0,...
                 'alpha1Power', 0.0,...
                 'alpha2Power', 0.0,...
                 'alpha3Power', 0.0,...
                 'betaPower', 0.0,...
                 'gammaPower', 0.0,...
                 'deltaPower_fixed', 0.0,...
                 'thetaPower_fixed', 0.0,...
                 'alphaPower_fixed', 0.0,...
                 'alpha1Power_fixed', 0.0,...
                 'alpha2Power_fixed', 0.0,...
                 'alpha3Power_fixed', 0.0,...
                 'betaPower_fixed', 0.0,...
                 'gammaPower_fixed', 0.0);

% ---------------- %
% Begin processing %
% ---------------- %
tic;
for i = 1:numel(files)
    disp('asdfasfdf');
    [Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(i).name));
    subj(i).SubjectID = files(i).name;
    for j = 1:size(Signal,2)
        % Calculate IAF, TF for each channel, and then find the average for
        % the IAF and TF, excluding the NaN values and incredibly low ones
        tempPeakObj = nbt_doPeakFit(Signal(:,j), SignalInfo);
        if isnan(tempPeakObj.IAF) || tempPeakObj.IAF < 1
            subj(i).rejectedIAFs = subj(i).rejectedIAFs + 1;
        else
            subj(i).IAFs(j) = tempPeakObj.IAF;
        end
        if isnan(tempPeakObj.TF) || tempPeakObj.TF < 2
            subj(i).rejectedTFs = subj(i).rejectedTFs + 1;
        else
            subj(i).TFs(j) = tempPeakObj.TF;
        end
    end
    % Calculate overall IAF and TF for this subject
    subj(i).meanIAF = nanmean(subj(i).IAFs);
    subj(i).meanTF  = nanmean(subj(i).TFs);
    % Take the grand average for the subject, then find PSD of grand average
    [avgPSD, avgFreq] = spectopo(nanmean(Signal'), 0, 512, 'plot', 'off');
    subj(i).Signal  = mean(Signal');
    subj(i).avgPSD  = avgPSD;
    subj(i).avgFreq = avgFreq;
    
    % ----------------------------------------------------- %
    % Use IAF and TF to find individualized frequency bands %
    % ----------------------------------------------------- %
    % Check to see that we don't get negative frequencies. If 
    % they do occur, assign traditional values.

    if subj(i).meanTF - 4 < 0
        subj(i).deltaFloor = 0.5;
    else
        subj(i).deltaFloor = subj(i).meanTF - 4;
    end
    if subj(i).meanTF - 2 < 0
        subj(i).deltaCeiling = 4;
        subj(i).thetaFloor   = 4;
    else
        subj(i).deltaCeiling = subj(i).meanTF - 2;
        subj(i).thetaFloor   = subj(i).meanTF - 2;
    end
    subj(i).thetaCeiling  = subj(i).meanTF;
    subj(i).alphaFloor    = subj(i).meanTF;
    subj(i).alpha1Floor   = subj(i).meanTF;
    subj(i).alpha1Ceiling = (subj(i).meanIAF + subj(i).meanTF) / 2;
    subj(i).alpha2Floor   = (subj(i).meanIAF + subj(i).meanTF) / 2;
    subj(i).alpha2Ceiling = subj(i).meanIAF;
    subj(i).alpha3Floor   = subj(i).meanIAF;
    subj(i).alpha3Ceiling = subj(i).meanIAF + 2;
    subj(i).alphaCeiling  = subj(i).meanIAF + 2;
    % TODO: Find peaks and troughs, use to calculate these
    %subj(i).Beta1_floor   = 
    %subj(i).Beta1_ceiling = 
    %subj(i).Beta2_floor   = 
    %subj(i).Beta2_ceiling = 
    %subj(i).gammaFloor    = 
    % -- Gamma ceiling already set

    % --------------- %
    % Calculate Power %
    % --------------- %

    % Compute absolute power (amplitude^2) across fixed (traditional) frequency bands
    subj(i).deltaPower_fixed  = calculatePower(avgPSD, avgFreq, subj(i).deltaFloor_fixed,  subj(i).deltaCeiling_fixed);
    subj(i).thetaPower_fixed  = calculatePower(avgPSD, avgFreq, subj(i).thetaFloor_fixed,  subj(i).thetaCeiling_fixed);
    subj(i).alphaPower_fixed  = calculatePower(avgPSD, avgFreq, subj(i).alphaFloor_fixed,  subj(i).alphaCeiling_fixed);
    subj(i).alpha1Power_fixed = calculatePower(avgPSD, avgFreq, subj(i).betaFloor_fixed,   subj(i).betaCeiling_fixed);
    subj(i).alpha2Power_fixed = calculatePower(avgPSD, avgFreq, subj(i).gammaFloor_fixed,  subj(i).gammaCeiling_fixed);
    subj(i).alpha3Power_fixed = calculatePower(avgPSD, avgFreq, subj(i).alpha1Floor_fixed, subj(i).alpha1Ceiling_fixed);
    subj(i).betaPower_fixed   = calculatePower(avgPSD, avgFreq, subj(i).alpha2Floor_fixed, subj(i).alpha2Ceiling_fixed);
    subj(i).gammaPower_fixed  = calculatePower(avgPSD, avgFreq, subj(i).alpha3Floor_fixed, subj(i).alpha3Ceiling_fixed);

    % Compute absolute power across individualized bands
    subj(i).deltaPower  = calculatePower(avgPSD, avgFreq, subj(i).deltaFloor,  subj(i).deltaCeiling);
    subj(i).thetaPower  = calculatePower(avgPSD, avgFreq, subj(i).thetaFloor,  subj(i).thetaCeiling);
    subj(i).alphaPower  = calculatePower(avgPSD, avgFreq, subj(i).alphaFloor,  subj(i).alphaCeiling);
    subj(i).alpha1Power = calculatePower(avgPSD, avgFreq, subj(i).meanTF,      subj(i).alpha2Floor);
    subj(i).alpha2Power = calculatePower(avgPSD, avgFreq, subj(i).alpha2Floor, subj(i).meanIAF);
    subj(i).alpha3Power = calculatePower(avgPSD, avgFreq, subj(i).meanIAF,     subj(i).alpha3Ceiling);
    
    % Compute ratios using both fixed and calculated bands
    subj(i).ratio_Alpha32    = subj(i).alpha3Power / subj(i).alpha2Power;
    subj(i).ratio_AlphaTheta = subj(i).alphaPower / subj(i).thetaPower;
    subj(i).ratio_Alpha32Fixed    = subj(i).alpha3Power_fixed / subj(i).alpha2Power_fixed;
    subj(i).ratio_AlphaThetaFixed = subj(i).alphaPower_fixed / subj(i).thetaPower_fixed;
end
toc;
structFile = strcat(exportpath, '/', date, '-results', '.mat');
save(structFile, 'subj');
cl_processalpha3alpha2;
