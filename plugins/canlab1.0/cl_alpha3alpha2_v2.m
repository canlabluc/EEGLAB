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
%       b. Calculate power across individualized and traditional frequency
%          bands for that channel. 
%       c. Calculate fixed and individualized alpha3/alpha2 and alpha/theta 
%          power ratios for that channel.
% 2. The overall mean power for each band is the average power for that band
%    across all channels. 

function subj = cl_alpha3alpha2(importpath, exportpath, method, rejectBadFits, guiFit)

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
if (~exist('method', 'var'))
    method = 'default';
end
if (~exist('rejectBadFits', 'var'))
    rejectBadFits = false;
end
if (~exist('guiFit', 'var'))
    guiFit = false;
end

files = dir(fullfile(strcat(importpath, '/*S.mat')));
% Preallocation of memory
subj(size(files, 1)) = struct();
[Signal, SignalInfo] = nbt_load_file(strcat(importpath, '/', files(1).name));
subj(:) = struct('SubjectID', 'SXXX',...
                 'IAF', 0.0,... % These are found by first finding the IAF and
                 'TF', 0.0,...  % TF of every channel, and then averaging them
                 'ratio_Alpha32', 0.0,...
                 'ratio_Alpha32Fixed', 0.0,...
                 'ratio_AlphaTheta', 0.0,...
                 'ratio_AlphaThetaFixed', 0.0,...
                 'IAFs', zeros(1, size(Signal,2)),...
                 'TFs',  zeros(1, size(Signal,2)),...
                 'avgSignal', zeros(1, size(Signal,1)),...
                 'avgPSD', zeros(1, 513),...
                 'avgFreqs', zeros(513, 1),...
                 'rejectedIAFs', [],...
                 'rejectedTFs',  [],...
                 'inspectedIAFs', zeros(1, size(Signal,2)),...
                 'inspectedTFs',  zeros(1, size(Signal,2)),...
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
    [Signal, SignalInfo] = nbt_load_file(strcat(importpath, '/', files(i).name));
    subj(i).SubjectID = files(i).name;
    for j = 1:size(Signal, 2)
        fprintf('---- SUBJECT %s: CHANNEL %d -----\n', subj(i).SubjectID(9:11), j);
        % Here, we calculate the IAF, TF for each channel, derive individualized
        % frequency bands for each channel, and calculate power across both
        % traditional and individualized frequency bands.
        channelPeakObj = nbt_doPeakFit(Signal(:,j), SignalInfo);
        if channelPeakObj.IAF < 7 || channelPeakObj.IAF > 13
            subj = cl_correctBadFits(subj, 'IAF', channelPeakObj, Signal, SignalInfo, i, j);
        else
            subj(i).IAFs(j) = channelPeakObj.IAF;
        end
        if channelPeakObj.TF < 4 || channelPeakObj.TF > 7
            subj = cl_correctBadFits(subj, 'TF', channelPeakObj, Signal, SignalInfo, i, j);
        else
            subj(i).TFs(j) = channelPeakObj.TF;
        end
        fprintf('IAF: %d\n', subj(i).IAFs(j));
        fprintf('TF:  %d\n', subj(i).TFs(j));

        % ----------------------------------------------------- %
        % Use IAF and TF to find individualized frequency bands %
        % ----------------------------------------------------- %
        
        subj(i).deltaFloor(j)    = subj(i).TFs(j) - 4;
        subj(i).deltaCeiling(j)  = subj(i).TFs(j) - 2;
        subj(i).thetaFloor(j)    = subj(i).TFs(j) - 2;
        subj(i).thetaCeiling(j)  = subj(i).TFs(j);
        subj(i).alphaFloor(j)    = subj(i).TFs(j);
        subj(i).alpha1Floor(j)   = subj(i).TFs(j);
        subj(i).alpha1Ceiling(j) = (subj(i).IAFs(j) + subj(i).TFs(j)) / 2;
        subj(i).alpha2Floor(j)   = (subj(i).IAFs(j) + subj(i).TFs(j)) / 2;
        subj(i).alpha2Ceiling(j) = subj(i).IAFs(j);
        subj(i).alpha3Floor(j)   = subj(i).IAFs(j);
        subj(i).alpha3Ceiling(j) = subj(i).IAFs(j) + 2;
        subj(i).alphaCeiling(j)  = subj(i).IAFs(j) + 2;
        if subj(i).deltaFloor(j) < 0.5
            subj(i).deltaFloor(j) = 0.5;
        end

        % --------------- %
        % Calculate Power %
        % --------------- %
        
        [PSD, Freqs] = spectopo(Signal(:,j), 0, 512, 'plot', 'off');
        subj(i).PSD(j) = PSD;

        % Compute absolute power (amplitude^2) across fixed (traditional) frequency bands
        subj(i).deltaPower_fixed(j)  = calculatePower(PSD, Freqs, subj(i).deltaFloor_fixed(j),  subj(i).deltaCeiling_fixed(j));
        subj(i).thetaPower_fixed(j)  = calculatePower(PSD, Freqs, subj(i).thetaFloor_fixed(j),  subj(i).thetaCeiling_fixed(j));
        subj(i).alphaPower_fixed(j)  = calculatePower(PSD, Freqs, subj(i).alphaFloor_fixed(j),  subj(i).alphaCeiling_fixed(j));
        subj(i).alpha1Power_fixed(j) = calculatePower(PSD, Freqs, subj(i).betaFloor_fixed(j),   subj(i).betaCeiling_fixed(j));
        subj(i).alpha2Power_fixed(j) = calculatePower(PSD, Freqs, subj(i).gammaFloor_fixed(j),  subj(i).gammaCeiling_fixed(j));
        subj(i).alpha3Power_fixed(j) = calculatePower(PSD, Freqs, subj(i).alpha1Floor_fixed(j), subj(i).alpha1Ceiling_fixed(j));
        subj(i).betaPower_fixed(j)   = calculatePower(PSD, Freqs, subj(i).alpha2Floor_fixed(j), subj(i).alpha2Ceiling_fixed(j));
        subj(i).gammaPower_fixed(j)  = calculatePower(PSD, Freqs, subj(i).alpha3Floor_fixed(j), subj(i).alpha3Ceiling_fixed(j));

        % Compute absolute power across individualized bands
        subj(i).deltaPower(j)  = calculatePower(PSD, Freqs, subj(i).deltaFloor(j),  subj(i).deltaCeiling(j));
        subj(i).thetaPower(j)  = calculatePower(PSD, Freqs, subj(i).thetaFloor(j),  subj(i).thetaCeiling(j));
        subj(i).alphaPower(j)  = calculatePower(PSD, Freqs, subj(i).alphaFloor(j),  subj(i).alphaCeiling(j));
        subj(i).alpha1Power(j) = calculatePower(PSD, Freqs, subj(i).TFs(j),         subj(i).alpha2Floor(j));
        subj(i).alpha2Power(j) = calculatePower(PSD, Freqs, subj(i).alpha2Floor(j), subj(i).IAFs(j));
        subj(i).alpha3Power(j) = calculatePower(PSD, Freqs, subj(i).IAFs(j),        subj(i).alpha3Ceiling(j));
        
        % Compute ratios using both fixed and calculated bands
        subj(i).chRatioAlpha32(j)    = subj(i).alpha3Power(j) / subj(i).alpha2Power(j);
        subj(i).chRatioAlphaTheta(j) = subj(i).alphaPower(j) / subj(i).thetaPower(j);
        subj(i).chRatioAlpha32Fixed(j)    = subj(i).alpha3Power_fixed(j) / subj(i).alpha2Power_fixed(j);
        subj(i).chRatioAlphaThetaFixed(j) = subj(i).alphaPower_fixed(j) / subj(i).thetaPower_fixed(j);
    end

    subj(i).meanPSD = mean(subj(i).PSD);

    subj(i).mean_deltaPower_fixed  = mean(subj(i).deltaPower_fixed);
    subj(i).mean_thetaPower_fixed  = mean(subj(i).thetaPower_fixed);
    subj(i).mean_alphaPower_fixed  = mean(subj(i).alphaPower_fixed);
    subj(i).mean_alpha1Power_fixed = mean(subj(i).alpha1Power_fixed);
    subj(i).mean_alpha2Power_fixed = mean(subj(i).alpha2Power_fixed);
    subj(i).mean_alpha3Power_fixed = mean(subj(i).alpha3Power_fixed);
    subj(i).mean_betaPower_fixed   = mean(subj(i).betaPower_fixed);
    subj(i).mean_gammaPower_fixed  = mean(subj(i).gammaPower_fixed);

    subj(i).mean_deltaPower  = mean(subj(i).deltaPower);
    subj(i).mean_thetaPower  = mean(subj(i).thetaPower);
    subj(i).mean_alphaPower  = mean(subj(i).alphaPower);
    subj(i).mean_alpha1Power = mean(subj(i).alpha1Power);
    subj(i).mean_alpha2Power = mean(subj(i).alpha2Power);
    subj(i).mean_alpha3Power = mean(subj(i).alpha3Power);

    subj(i).ratio_Alpha32 = mean(subj(i).chRatioAlpha32);
    subj(i).ratio_Alpha32Fixed = mean(subj(i).chRatioAlpha32Fixed);
    subj(i).ratio_AlphaTheta = mean(subj(i).chRatioAlphaTheta);
    subj(i).ratio_AlphaThetaFixed = mean(subj(i).chRatioAlphaThetaFixed);

    subj(i).ratio_Alpha32_v2 = subj(i).mean_alpha3Power / subj(i).mean_alpha2Power;
    subj(i).ratio_Alpha32Fixed_v2 = subj(i).mean_alpha3Power_fixed / subj(i).mean_alpha2Power_fixed;
    subj(i).ratio_AlphaTheta_v2 = subj(i).mean_alphaPower / subj(i).mean_thetaPower;
    subj(i).ratio_AlphaThetaFixed_v2 = subj(i).mean_alphaPower_fixed / subj(i).mean_thetaPower_fixed;
end
toc;
structFile = strcat(exportpath, '/', date, '-results', '.mat');
save(structFile, 'subj');
cl_processalpha3alpha2(subj, exportpath);
