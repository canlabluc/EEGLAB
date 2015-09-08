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
% 2. Calculate the mean IAF and TF.
% 3. Take the power spectrum of the grand average of all the channels, and use
%    the mean TF and mean IAF to calculate power across individualized frequency
%    bands. Also, calculate power across traditional frequency bands.
% 4. Calculate the alpha3/alpha2 power ratio using both traditional and 
%    individualized frequency bands.

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
        error('Error: Please specify the folder to export the .set files to.');
    end
    fprintf('Export path: %s\n', exportpath);
end
if (~exist('rejectBadFits', 'var'))
    rejectBadFits = false;
end
if (~exist('guiFit', 'var'))
    guiFit = false;
end

cd ~/nbt
installNBT;
files = dir(fullfile(strcat(importpath, '/*S.mat')));
% Preallocation of memory
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
                 'rejectedIAFs', [],...
                 'rejectedTFs',  [],...
                 'visuallyInspectedIAFs', zeros(1, size(Signal,2)),...
                 'visuallyInspectedTFs',  zeros(1, size(Signal,2)),...
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
    [Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(i).name));
    subj(i).SubjectID = files(i).name;
    for j = 1:size(Signal,2)
        fprintf('---- SUBJECT %s: CHANNEL %d ----\n', subj(i).SubjectID(9:11), j);
        % Calculate IAF, TF for each channel, and then find the average for
        % the IAF and TF, excluding NaN values and those that fall completely
        % outside of expected range.
        channelPeakObj = nbt_doPeakFit(Signal(:,j), SignalInfo);
        if isnan(channelPeakObj.IAF) || channelPeakObj.IAF < 7 || channelPeakObj.IAF > 13
            fprintf('ERROR: IAF calculated by NBT: %d\n', channelPeakObj.IAF);
            fprintf('Fitting polynomial in order to recalculate IAF...\n');
            subj(i).visuallyInspectedIAFs(j) = j;
            [spectra, freqs] = spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16], 'plot', 'off');
            ws = warning('off', 'all');           
            p  = polyfit(freqs', spectra, 15);
            warning(ws);
            y1 = polyval(p, freqs');
            [dummy, ind] = max(y1(find(freqs > 7):find(freqs > 13, 1)));
            % If the polynomial-fitted data is still wrong, prompt the user to
            % either click to select the IAF, reject the fit and move on to the
            % TF calculation, or choose an IAF of 9 Hz
            if freqs(ind) > 12.9 || freqs(ind) < 7
                if guiFit == true
                    disp('IAF is too low or too high. Confirm by clicking: ');
                    spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16]);
                    [x, y] = ginput(1);
                    subj(i).IAFs(j) = x;
                    close(2);
                elseif rejectBadFits == true
                    disp('IAF is too low or too high. Rejecting calculated IAF.');
                    subj(i).rejectedIAFs = [subj(i).rejectedIAFs, j];
                else
                    disp('IAF is too low or too high. Choosing IAF = 9 Hz');
                    subj(i).IAfs(j) = 9;
                end
            else
                % Otherwise, the polynomial-fitted data gives us a reasonable IAF.
                % Choose this as the IAF.
                subj(i).IAFs(j) = freqs(x);
            end
        else
            subj(i).IAFs(j) = channelPeakObj.IAF;
        end
        if isnan(channelPeakObj.TF) || channelPeakObj.TF < 4 || channelPeakObj.TF > 7
            fprintf('ERROR: TF calculated by NBT: %d \n', channelPeakObj.TF);
            fprintf('Fitting polynomial in order to recalculate TF...\n');
            subj(i).visuallyInspectedTFs(j) = j;
            [spectra, freqs] = spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16], 'plot', 'off');
            % Since nbt didn't find a reasonable TF, fit a 15th order polynomial
            % to the PSD and find minima in the 0 - 7.5 Hz range. This will be 
            % the TF
            ws = warning('off', 'all');
            p  = polyfit(freqs', spectra, 15);
            warning(ws);
            y1 = polyval(p, freqs');
            [dummy, ind] = min(y1(1:find(freqs > 7.5, 1)));
            if freqs(ind) > 6.9 || freqs(ind) < 3
                if guiFit == true
                    disp('TF is too low or too high. Confirm by clicking: ');
                    spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16]);
                    [x, y] = ginput(1);
                    subj(i).TFs(j) = x;
                    close(2);
                elseif rejectBadFits == true
                    disp('TF is too low or too high. Rejecting calculated TF');
                    % subj(i).TFs(j) = []; BAD: Shrinks matrix
                    subj(i).rejectedTFs = [subj(i).rejectedTFs, j];
                else
                    disp('TF is too low or too high. Choosing TF = 4.5 Hz');
                    subj(i).TFs(j) = 4.5;
                end
            else
                subj(i).TFs(j) = freqs(ind);
            end
        else
            subj(i).TFs(j) = channelPeakObj.TF;
        end
        fprintf('IAF: %d\n', subj(i).IAFs(j));
        fprintf('TF:  %d\n', subj(i).TFs(j));
    end        
    % Calculate overall IAF and TF for this subject
    if rejectBadFits == true
        rejectIAFs = subj(i).IAFs == 0;
        rejectTFs  = subj(i).TFs == 0;
        subj(i).IAFs(rejectIAFs) = [];
        subj(i).TFs(rejectTFs) = [];
    end
    subj(i).meanIAF = mean(subj(i).IAFs);
    subj(i).meanTF  = mean(subj(i).TFs);
    % Take the grand average for the subject, then find PSD of grand average
    [avgPSD, avgFreq] = spectopo(mean(Signal'), 0, 512, 'plot', 'off');
    subj(i).Signal  = mean(Signal');
    subj(i).avgPSD  = avgPSD;
    subj(i).avgFreq = avgFreq;
    
    % ----------------------------------------------------- %
    % Use IAF and TF to find individualized frequency bands %
    % ----------------------------------------------------- %

    subj(i).deltaFloor    = subj(i).meanTF - 4;
    subj(i).deltaCeiling  = subj(i).meanTF - 2;
    subj(i).thetaFloor    = subj(i).meanTF - 2;
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
    % Gamma ceiling already set
    % In case TF is below 4.5, readjust deltaFloor so we don't get incorrect
    % power calculations 
    if subj(i).deltaFloor < 0.5
        subj(i).deltaFloor = 0.5;
    end

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
cl_processalpha3alpha2(subj, exportpath);
