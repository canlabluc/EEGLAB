% Calculates absolute power across both individualized frequency bands and
% fixed ones. Utilizes nbt_doPeakFit() and EEGLAB's spectopo() function.
%
% Usage:
%   >>> subj = cl_alpha3alpha2();   % GUI option
%   >>> subj = cl_alpha3alpha2(importpath, exportpath);
%   >>> subj = cl_alpha3alpha2(importpath, exportpath, rejectBadFits = true,...
%                                                      guiFit        = false);
%
% Inputs:
% importpath: A string which specifies the directory containing the .cnt files
%             that are to be imported
%
% exportpath: A string which specifies the directory containing the .set files
%             that are to be saved for further analysis
%
% rejectBadFits: Boolean that defaults to false. In the case that the IAF or TF
%                derived from fitting the polynomial to the power spectrum fail
%                to be reasonable, setting this parameter to true will result
%                in the program ignoring that value from further analysis.
%
% guiFit: Boolean that defaults to false. Allows the user to select TF, IAF
%         values in the case that the polynomial fit fails to find reasonable
%         IAFs or TFs.
%
% Outputs:
% subj: An array of structures, one for each subject that is processed. The
%       structure contains all of the results of the analysis.
%
% Notes:
% Note that since spectopo() returns the Power Spectrum Density in units of
% 10*log10(uV^2), we need to apply a few transformations to acquire uV^2,
% or absolute power.
%
% Algorithm:
% For each subject:
% 1. Calculate the IAF and TF for each channel using nbt_doPeakFit from the NBT
%    toolbox.
%       a. If nbt_doPeakFit returns unreasonable values for any TF or IAF, fit
%          a 15th order polynomial to the power spectrum. The local minimum in
%          the 0 - 7 Hz range is chosen as the TF, and the local maximum in the
%          7 - 13 Hz range is chosen as the IAF.
%               i. If the IAF or TF still fails to be reasonable (e.g., the
%                  spectrum is very flat and results in TF values that are
%                  either 7 Gz or 0 Hz), we reject these values and move on.
%               ii. Alternatively, if guiFit is set to true, the user is
%                   allowed to visually select the TF or IAF.
% 2. Calculate power across individualized and traditional frequency
%          bands for that channel.
% 3. Calculate fixed and individualized alpha3/alpha2 and alpha/theta
%          power ratios for that channel.
% 4. The overall nanmean power for each band is the average power for that band
%    across all channels.

function subj = cl_alpha3alpha2(importpath, exportpath, rejectBadFits, guiFit)

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
        error('Error: Please specify the folder to export results to.');
    end
    fprintf('Export path: %s\n', exportpath);
end
if (~exist('rejectBadFits', 'var'))
    rejectBadFits = false;
end
if (~exist('guiFit', 'var'))
    guiFit = false;
end

% Write settings to text file
fileID = fopen(strcat(pwd, '/', date, '-cl_alpha3alpha2-parameters.txt'), 'w');
fprintf(fileID, 'importpath: %s\n', importpath)
fprintf(fileID, 'exportpath: %s\n', exportpath)
fprintf(fileID, 'rejectBadFits: %s\n', rejectBadFits)
fprintf(fileID, 'guiFit:     %s\n', guiFit)
fclose(fileID)

% Create list of files and allocate necessary memory for the analysis
files = dir(fullfile(strcat(importpath, '/*S.mat')));
[Signal, SignalInfo] = nbt_load_file(strcat(importpath, '/', files(1).name));
subj = cl_allocateSubj('cl_alpha3alpha2', size(files,1), size(Signal,2), SignalInfo.original_sample_frequency);

% ---------------- %
% Begin processing %
% ---------------- %
tic;
for i = 1:numel(files)
    [Signal, SignalInfo] = nbt_load_file(strcat(importpath, '/', files(i).name));
    subj(i).SubjectID = files(i).name;
    for j = 1:size(Signal, 2)
        fprintf('---- SUBJECT %s: CHANNEL %d -----\n', subj(i).SubjectID(9:11), j);
        % Here, we calculate the IAF, TF for each channel, derive individualized
        % frequency bands for each channel, and calculate power across both
        % traditional and individualized frequency bands.
        channelPeakObj = nbt_doPeakFit(Signal(:,j), SignalInfo);
        if isnan(channelPeakObj.IAF) || channelPeakObj.IAF < 7 || channelPeakObj.IAF > 13
            subj(i).misc.measure = 'IAF';
            subj(i).misc.analysisType = 'cl_alpha3alpha2';
            subj = cl_correctBadFits(subj, channelPeakObj, Signal, i, j, rejectBadFits, guiFit);
        else
            subj(i).IAFs(j) = channelPeakObj.IAF;
        end
        if isnan(channelPeakObj.TF) || channelPeakObj.TF < 4 || channelPeakObj.TF > 7
            subj(i).misc.measure = 'TF';
            subj(i).misc.analysisType = 'cl_alpha3alpha2';
            subj = cl_correctBadFits(subj, channelPeakObj, Signal, i, j, rejectBadFits, guiFit);
        else
            subj(i).TFs(j) = channelPeakObj.TF;
        end
        fprintf('IAF: %d\n', subj(i).IAFs(j));
        fprintf('TF:  %d\n', subj(i).TFs(j));

        % ----------------------------------------------------- %
        % Use IAF and TF to find individualized frequency bands %
        % ----------------------------------------------------- %

        subj(i).ch_deltaFloor(j)    = subj(i).TFs(j) - 4;
        subj(i).ch_deltaCeiling(j)  = subj(i).TFs(j) - 2;
        subj(i).ch_thetaFloor(j)    = subj(i).TFs(j) - 2;
        subj(i).ch_thetaCeiling(j)  = subj(i).TFs(j);
        subj(i).ch_alphaFloor(j)    = subj(i).TFs(j);
        subj(i).ch_alpha1Floor(j)   = subj(i).TFs(j);
        subj(i).ch_alpha1Ceiling(j) = (subj(i).IAFs(j) + subj(i).TFs(j)) / 2;
        subj(i).ch_alpha2Floor(j)   = (subj(i).IAFs(j) + subj(i).TFs(j)) / 2;
        subj(i).ch_alpha2Ceiling(j) = subj(i).IAFs(j);
        subj(i).ch_alpha3Floor(j)   = subj(i).IAFs(j);
        subj(i).ch_alpha3Ceiling(j) = subj(i).IAFs(j) + 2;
        subj(i).ch_alphaCeiling(j)  = subj(i).IAFs(j) + 2;
        if subj(i).ch_deltaFloor(j) < 0.5
            subj(i).ch_deltaFloor(j) = 0.5;
        end

        % --------------- %
        % Calculate Power %
        % --------------- %

        [PSD, Freqs] = spectopo(Signal(:,j)', 0, 512, 'plot', 'off');
        % subj(i).PSD(j) = PSD;

        % Compute absolute power (amplitude^2) across fixed (traditional) frequency bands
        subj(i).ch_deltaPower_fixed(j)  = calculatePower(PSD, Freqs, subj(i).deltaFloor_fixed,  subj(i).deltaCeiling_fixed);
        subj(i).ch_thetaPower_fixed(j)  = calculatePower(PSD, Freqs, subj(i).thetaFloor_fixed,  subj(i).thetaCeiling_fixed);
        subj(i).ch_alphaPower_fixed(j)  = calculatePower(PSD, Freqs, subj(i).alphaFloor_fixed,  subj(i).alphaCeiling_fixed);
        subj(i).ch_alpha1Power_fixed(j) = calculatePower(PSD, Freqs, subj(i).betaFloor_fixed,   subj(i).betaCeiling_fixed);
        subj(i).ch_alpha2Power_fixed(j) = calculatePower(PSD, Freqs, subj(i).gammaFloor_fixed,  subj(i).gammaCeiling_fixed);
        subj(i).ch_alpha3Power_fixed(j) = calculatePower(PSD, Freqs, subj(i).alpha1Floor_fixed, subj(i).alpha1Ceiling_fixed);
        subj(i).ch_betaPower_fixed(j)   = calculatePower(PSD, Freqs, subj(i).alpha2Floor_fixed, subj(i).alpha2Ceiling_fixed);
        subj(i).ch_gammaPower_fixed(j)  = calculatePower(PSD, Freqs, subj(i).alpha3Floor_fixed, subj(i).alpha3Ceiling_fixed);

        % Compute absolute power across individualized bands
        subj(i).ch_deltaPower(j)  = calculatePower(PSD, Freqs, subj(i).ch_deltaFloor(j),  subj(i).ch_deltaCeiling(j));
        subj(i).ch_thetaPower(j)  = calculatePower(PSD, Freqs, subj(i).ch_thetaFloor(j),  subj(i).ch_thetaCeiling(j));
        subj(i).ch_alphaPower(j)  = calculatePower(PSD, Freqs, subj(i).ch_alphaFloor(j),  subj(i).ch_alphaCeiling(j));
        subj(i).ch_alpha1Power(j) = calculatePower(PSD, Freqs, subj(i).TFs(j),            subj(i).ch_alpha2Floor(j));
        subj(i).ch_alpha2Power(j) = calculatePower(PSD, Freqs, subj(i).ch_alpha2Floor(j), subj(i).IAFs(j));
        subj(i).ch_alpha3Power(j) = calculatePower(PSD, Freqs, subj(i).IAFs(j),           subj(i).ch_alpha3Ceiling(j));

        % Compute ratios using both fixed and calculated bands
        subj(i).chRatioAlpha32(j)    = subj(i).ch_alpha3Power(j) / subj(i).ch_alpha2Power(j);
        subj(i).chRatioAlphaTheta(j) = subj(i).ch_alphaPower(j) / subj(i).ch_thetaPower(j);
        subj(i).chRatioAlpha32Fixed(j)    = subj(i).ch_alpha3Power_fixed(j) / subj(i).ch_alpha2Power_fixed(j);
        subj(i).chRatioAlphaThetaFixed(j) = subj(i).ch_alphaPower_fixed(j) / subj(i).ch_thetaPower_fixed(j);
    end

    % ------------------------------------- %
    % Calculate mean power for each subject %
    % ------------------------------------- %

    subj(i).TF  = nanmean(subj(i).TFs);
    subj(i).IAF = nanmean(subj(i).IAFs);

    subj(i).deltaFloor    = nanmean(subj(i).ch_deltaFloor);
    subj(i).deltaCeiling  = nanmean(subj(i).ch_deltaCeiling);
    subj(i).thetaFloor    = nanmean(subj(i).ch_thetaFloor);
    subj(i).thetaCeiling  = nanmean(subj(i).ch_thetaCeiling);
    subj(i).alphaFloor    = nanmean(subj(i).ch_alphaFloor);
    subj(i).alpha1Floor   = nanmean(subj(i).ch_alpha1Floor);
    subj(i).alpha1Ceiling = nanmean(subj(i).ch_alpha1Ceiling);
    subj(i).alpha2Floor   = nanmean(subj(i).ch_alpha2Floor);
    subj(i).alpha2Ceiling = nanmean(subj(i).ch_alpha2Ceiling);
    subj(i).alpha3Floor   = nanmean(subj(i).ch_alpha3Floor);
    subj(i).alpha3Ceiling = nanmean(subj(i).ch_alpha3Ceiling);
    subj(i).alphaCeiling  = nanmean(subj(i).ch_alphaCeiling);

    subj(i).deltaPower_fixed  = nanmean(subj(i).ch_deltaPower_fixed);
    subj(i).thetaPower_fixed  = nanmean(subj(i).ch_thetaPower_fixed);
    subj(i).alphaPower_fixed  = nanmean(subj(i).ch_alphaPower_fixed);
    subj(i).alpha1Power_fixed = nanmean(subj(i).ch_alpha1Power_fixed);
    subj(i).alpha2Power_fixed = nanmean(subj(i).ch_alpha2Power_fixed);
    subj(i).alpha3Power_fixed = nanmean(subj(i).ch_alpha3Power_fixed);
    subj(i).betaPower_fixed   = nanmean(subj(i).ch_betaPower_fixed);
    subj(i).gammaPower_fixed  = nanmean(subj(i).ch_gammaPower_fixed);

    subj(i).deltaPower  = nanmean(subj(i).ch_deltaPower);
    subj(i).thetaPower  = nanmean(subj(i).ch_thetaPower);
    subj(i).alphaPower  = nanmean(subj(i).ch_alphaPower);
    subj(i).alpha1Power = nanmean(subj(i).ch_alpha1Power);
    subj(i).alpha2Power = nanmean(subj(i).ch_alpha2Power);
    subj(i).alpha3Power = nanmean(subj(i).ch_alpha3Power);

    subj(i).ratio_Alpha32 = nanmean(subj(i).chRatioAlpha32);
    subj(i).ratio_Alpha32Fixed = nanmean(subj(i).chRatioAlpha32Fixed);
    subj(i).ratio_AlphaTheta = nanmean(subj(i).chRatioAlphaTheta);
    subj(i).ratio_AlphaThetaFixed = nanmean(subj(i).chRatioAlphaThetaFixed);

    subj(i).ratio_Alpha32_v2         = subj(i).alpha3Power / subj(i).alpha2Power;
    subj(i).ratio_Alpha32Fixed_v2    = subj(i).alpha3Power_fixed / subj(i).alpha2Power_fixed;
    subj(i).ratio_AlphaTheta_v2      = subj(i).alphaPower / subj(i).thetaPower;
    subj(i).ratio_AlphaThetaFixed_v2 = subj(i).alphaPower_fixed / subj(i).thetaPower_fixed;
end
toc;
structFile = strcat(exportpath, '/', date, '-results', '.mat');
save(structFile, 'subj');
cl_processalpha3alpha2(subj, exportpath);
