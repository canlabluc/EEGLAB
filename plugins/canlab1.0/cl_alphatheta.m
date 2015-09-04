% Calculates the alpha/theta and alpha3/alpha2 ratios for the C3, O1 electrodes
% using both traditional and individualized frequency bands.
%
% Usage:
%   >>> subj = cl_alphatheta();     % GUI option
%   >>> subj = cl_alphatheta(importpath, exportpath, rejectBadFits = true,...
%                                                    guiFit        = false);
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
%       structure contains all of the results of the analysis
% 
% Algorithm:
% 

function subj = cl_alphatheta(importpath, exportpath, rejectBadFits, guiFit)

C3trodes = [11 15 17 20];
O1trodes = [25 26 27];

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
% Preallocation
subj(size(files,1)) = struct();
subj(:) = struct('SubjectID', 'SXXX',...
                 'C3', struct(),...
                 'O1', struct(),...
                 'avgC3Signal', zeros(1, 10240),...
                 'avgO1Signal', zeros(1, 10240),...
                 'C3IAF', 0.0,... % These will store the IAF and TF for the 
                 'C3TF', 0.0,...  % C3 and O1 electrodes, which we'll obtain
                 'O1IAF', 0.0,... % by grand average of electrodes in that
                 'O1TF', 0.0,...  % area
                 'C3_AlphaThetaRatio', 0.0,...
                 'O1_AlphaThetaRatio', 0.0,...
                 'C3_AlphaThetaRatio_fixed', 0.0,...
                 'O1_AlphaThetaRatio_fixed', 0.0,...
                 'C3deltaFloor', 0.0,...
                 'C3deltaCeiling', 0.0,...
                 'C3thetaFloor', 0.0,...
                 'C3thetaCeiling', 0.0,...
                 'C3alphaFloor', 0.0,...
                 'C3alpha1Floor', 0.0,...
                 'C3alpha1Ceiling', 0.0,...
                 'C3alpha2Floor', 0.0,...
                 'C3alpha2Ceiling', 0.0,...
                 'C3alpha3Floor', 0.0,...
                 'C3alpha3Ceiling', 0.0,...
                 'C3alphaCeiling', 0.0,...
                 'C3betaFloor', 0.0,...
                 'C3betaCeiling', 0.0,...
                 'C3gammaFloor', 0.0,...
                 'C3gammaCeiling', 0.0,...
                 'O1deltaFloor', 0.0,...
                 'O1deltaCeiling', 0.0,...
                 'O1thetaFloor', 0.0,...
                 'O1thetaCeiling', 0.0,...
                 'O1alphaFloor', 0.0,...
                 'O1alpha1Floor', 0.0,...
                 'O1alpha1Ceiling', 0.0,...
                 'O1alpha2Floor', 0.0,...
                 'O1alpha2Ceiling', 0.0,...
                 'O1alpha3Floor', 0.0,...
                 'O1alpha3Ceiling', 0.0,...
                 'O1alphaCeiling', 0.0,...
                 'O1betaFloor', 0.0,...
                 'O1betaCeiling', 0.0,...
                 'O1gammaFloor', 0.0,...
                 'O1gammaCeiling', 0.0,...
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
                 'C3deltaPower', 0.0,...
                 'C3thetaPower', 0.0,...
                 'C3alphaPower', 0.0,...
                 'C3alpha1Power', 0.0,...
                 'C3alpha2Power', 0.0,...
                 'C3alpha3Power', 0.0,...
                 'C3betaPower', 0.0,...
                 'C3gammaPower', 0.0,...
                 'O1deltaPower', 0.0,...
                 'O1thetaPower', 0.0,...
                 'O1alphaPower', 0.0,...
                 'O1alpha1Power', 0.0,...
                 'O1alpha2Power', 0.0,...
                 'O1alpha3Power', 0.0,...
                 'O1betaPower', 0.0,...
                 'O1gammaPower', 0.0,...
                 'O1deltaPower_fixed', 0.0,...
                 'O1thetaPower_fixed', 0.0,...
                 'O1alphaPower_fixed', 0.0,...
                 'O1alpha1Power_fixed', 0.0,...
                 'O1alpha2Power_fixed', 0.0,...
                 'O1alpha3Power_fixed', 0.0,...
                 'O1betaPower_fixed', 0.0,...
                 'O1gammaPower_fixed', 0.0,...
                 'C3deltaPower_fixed', 0.0,...
                 'C3thetaPower_fixed', 0.0,...
                 'C3alphaPower_fixed', 0.0,...
                 'C3alpha1Power_fixed', 0.0,...
                 'C3alpha2Power_fixed', 0.0,...
                 'C3alpha3Power_fixed', 0.0,...
                 'C3betaPower_fixed', 0.0,...
                 'C3gammaPower_fixed', 0.0);
for i = 1:numel(files)
    for j = 1:numel(C3)
        subj(i).C3(j) = struct('Signal', zeros(10240, 1), 'IAF', 0.0, 'TF', 0.0);
    end
    for k = 1:numel(O1)
        subj(i).O1(k) = struct('Signal', zeros(10240, 1), 'IAF', 0.0, 'TF', 0.0);
    end
end

% ---------------- %
% Begin processing %
% ---------------- %
tic;
for i = 1:numel(files)
    [Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(i).name));
    subj(i).SubjectID = files(i).name(9:11);
    % Store information such as signal, IAF, and TF for each electrode that
    % makes up either C3 or O1
    C3Added = 1;
    O1Added = 1;
    for j = 1:size(Signal, 2)
        if any(C3trodes == j)
            C3PeakFit = nbt_doPeakFit(Signal(:,j), SignalInfo);
            subj(i).C3(C3Added).Signal = Signal(:,j);
            if isnan(C3PeakFit.IAF) || C3PeakFit.IAF < 7 || C3PeakFit.IAF > 13
                fprintf('C3 -- ERROR: IAF calculated by NBT: %d\n', C3PeakFit.IAF);
                fprintf('Fitting polynomial in order to recalculate IAF...\n');
                [spectra, freqs] = spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16], 'plot', 'off');
                ws = warning('off', 'all');
                p = polyfit(freqs', spectra, 15);
                warning(ws);
                y1 = polyval(p, freqs');
                [dummy, ind] = max(y1(find(freqs > 7):find(freqs > 13, 1)));
                if freqs(ind) > 12.9 || freqs(ind) < 7
                    if guiFit == true
                        disp('IAF is too low or too high. Indicate IAF through GUI: ');
                        spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16]);
                        plot(freqs', y1);
                        [x, y] = ginput(1);
                        subj(i).IAFs(j) = x;
                        close(2);
                    else if rejectBadFits == true
                        disp('IAF is too low or too high. Rejecting polynomial fit-calculated IAF.');
                        subj(i).IAFs(j) = [];
                    else
                        disp('IAF is too low or too high. Choosing IAF = 9 Hz');
                        subj(i).IAFs(j) = 9;
                    end
                % Otherwise, the polynomial-fitted data gives us a reasonable IAF.
                % Choose this as the IAF.
                else
                    subj(i).IAFs(j) = freqs(x);
                end
            else
                subj(i).IAFs(j) = C3PeakFit.IAF;
            end
            if isnan(C3PeakFit.TF) || C3PeakFit.TF < x || C3PeakFit.TF > y
                fprintf('C3 --- ERROR: TF calculated by NBT: %d\n', C3PeakFit.TF);
                fprintf('Fitting polynomial in order to recalculate IAF...\n');
                [spectra, freqs] = spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16], 'plot', 'off');
                ws = warning('off', 'all');
                p = polyfit(freqs', spectra, 15);
                warning(ws);
                y1 = polyval(p, freqs');
                [dummy, ind] = max(y1(find(freqs > 7):find(freqs > 13, 1)));
                if freqs(ind) > 6.9 || freqs(ind) < 3
                    if guiFit == true
                        disp('TF is too low or too high. Confirm by clicking: ');
                        spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16]);
                        [x, y] = ginput(1);
                        subj(i).TFs(j) = x;
                        close(2);
                    else if rejectBadFits == true
                        disp('TF is too low or too high. Rejecting calculated TF.');
                        subj(i).TFs(j) = 4.5;
                    else
                        disp('TF is too low or too high. Choosing TF = 4.5 Hz');
                        subj(i).TFs(j) = 4.5;                       
                    end
                else
                    subj(i).TFs(j) = freqs(ind);
                end
            else
                subj(i).TFs(j) = C3PeakFit.TF;
            end
            subj(i).C3(C3Added).IAF = C3PeakFit.IAF;
            subj(i).C3(C3Added).TF  = C3PeakFit.TF;
            C3Added = C3Added + 1;
        else if any(O1trodes == j)
            O1PeakFit = nbt_doPeakFit(Signal(:,j), SignalInfo);
            subj(i).O1(O1Added).Signal = Signal(:,j);
            if isnan(O1PeakFit.IAF) || O1PeakFit.IAF < 7 || O1PeakFit.IAF > 13
                fprintf('O1 -- ERROR: IAF calculated by NBT: %d\n', O1PeakFit.IAF);
                fprintf('Fitting polynomial in order to recalculate IAF...\n');
                [spectra, freqs] = spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16], 'plot', 'off');
                ws = warning('off', 'all');
                p = polyfit(freqs', spectra, 15);
                warning(ws);
                y1 = polyval(p, freqs');
                [dummy, ind] = max(y1(find(freqs > 7):find(freqs > 13, 1)));
                if freqs(ind) > 12.9 || freqs(ind) < 7
                    if guiFit == true
                        disp('IAF is too low or too high. Indicate IAF through GUI: ');
                        spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16]);
                        plot(freqs', y1);
                        [x, y] = ginput(1);
                        subj(i).IAFs(j) = x;
                        close(2);
                    else if rejectBadFits == true
                        disp('IAF is too low or too high. Rejecting polynomial fit-calculated IAF.');
                        subj(i).IAFs(j) = [];
                    else
                        disp('IAF is too low or too high. Choosing IAF = 9 Hz');
                        subj(i).IAFs(j) = 9;
                    end
                % Otherwise, the polynomial-fitted data gives us a reasonable IAF.
                % Choose this as the IAF.
                else
                    subj(i).IAFs(j) = freqs(x);
                end
            else
                subj(i).IAFs(j) = O1PeakFit.IAF;
            end
            if isnan(O1PeakFit.TF) || O1PeakFit.TF < x || O1PeakFit.TF > y
                fprintf('O1 --- ERROR: TF calculated by NBT: %d\n', O1PeakFit.TF);
                fprintf('Fitting polynomial in order to recalculate IAF...\n');
                [spectra, freqs] = spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16], 'plot', 'off');
                ws = warning('off', 'all');
                p = polyfit(freqs', spectra, 15);
                warning(ws);
                y1 = polyval(p, freqs');
                [dummy, ind] = max(y1(find(freqs > 7):find(freqs > 13, 1)));
                if freqs(ind) > 6.9 || freqs(ind) < 3
                    if guiFit == true
                        disp('TF is too low or too high. Confirm by clicking: ');
                        spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16]);
                        [x, y] = ginput(1);
                        subj(i).TFs(j) = x;
                        close(2);
                    else if rejectBadFits == true
                        disp('TF is too low or too high. Rejecting calculated TF.');
                        subj(i).TFs(j) = 4.5;
                    else
                        disp('TF is too low or too high. Choosing TF = 4.5 Hz');
                        subj(i).TFs(j) = 4.5;                       
                    end
                else
                    subj(i).TFs(j) = freqs(ind);
                end
            else
                subj(i).TFs(j) = O1PeakFit.TF;
            end
            subj(i).O1(O1Added).IAF = O1PeakFit.IAF;
            subj(i).O1(O1Added).TF  = O1PeakFit.TF;
            O1Added = O1Added + 1;
        end
    end
    % Find grand average of the aforementioned electrodes, and calculate overall
    % IAF and TF for this subject, in both the C3 and O1 electrodes
    subj(i).C3meanTF  = nanmean(subj(i).C3(:).TFs);
    subj(i).C3meanIAF = nanmean(subj(i).C3(:).IAFs);
    subj(i).O1meanTF  = nanmean(subj(i).O1(:).TFs);
    subj(i).O1meanIAF = nanmean(subj(i).O1(:).IAFs);

    subj(i).avgC3Signal = subj(i).C3(1).Signal;
    subj(i).avgO1Signal = subj(i).O1(1).Signal;
    for k = 2:numel(subj(i).C3)
        subj(i).avgC3Signal = (subj(i).avgC3Signal + subj(i).C3(k).Signal) / 2;        
    end
    for k = 2:numel(subj(i).O1)
        subj(i).avgO1Signal = (subj(i).avgO1Signal + subj(i).O1(k).Signal) / 2;     
    end


    
    % ------------------------------------------------------------------ %
    % Find IAF, TF, and use these to find individualized frequency bands %
    % ------------------------------------------------------------------ %

    C3PeakFit = nbt_doPeakFit(subj(i).avgC3Signal, SignalInfo);
    O1PeakFit = nbt_doPeakFit(subj(i).avgO1Signal, SignalInfo);
    % Makes sure that IAFs and TFs for both expected values -- if nbt_doPeakFit
    % failed to properly fit peaks, it returns NaN or values < 1
    subj(i).C3deltaFloor    = subj(i).C3meanTF - 4;
    subj(i).C3deltaCeiling  = subj(i).C3meanTF - 2;
    subj(i).C3thetaFloor    = subj(i).C3meanTF - 2;
    subj(i).C3thetaCeiling  = subj(i).C3meanTF;
    subj(i).C3alphaFloor    = subj(i).C3meanTF;
    subj(i).C3alpha1Floor   = subj(i).C3meanTF;
    subj(i).C3alpha1Ceiling = (subj(i).C3meanIAF + subj(i).C3meanTF) / 2;
    subj(i).C3alpha2Floor   = (subj(i).C3meanIAF + subj(i).C3meanTF) / 2;
    subj(i).C3alpha2Ceiling = subj(i).C3meanIAF;
    subj(i).C3alpha3Floor   = subj(i).C3meanIAF;
    subj(i).C3alpha3Ceiling = subj(i).C3meanIAF + 2;
    subj(i).C3alphaCeiling  = subj(i).C3meanIAF + 2;
    % TODO: Find peaks and troughs, use to calculate these
    %subj(i).Beta1_floor   = 
    %subj(i).Beta1_ceiling = 
    %subj(i).Beta2_floor   = 
    %subj(i).Beta2_ceiling = 
    %subj(i).gammaFloor    = 
    % Gamma ceiling already set
    % In case TF is below 4.5, readjust deltaFloor so we don't get incorrect
    % power calculations 
    if subj(i).C3deltaFloor < 0.5
        subj(i).C3deltaFloor = 0.5;
    end


    subj(i).O1deltaFloor    = subj(i).O1meanTF - 4;
    subj(i).O1deltaCeiling  = subj(i).O1meanTF - 2;
    subj(i).O1thetaFloor    = subj(i).O1meanTF - 2;
    subj(i).O1thetaCeiling  = subj(i).O1meanTF;
    subj(i).O1alphaFloor    = subj(i).O1meanTF;
    subj(i).O1alpha1Floor   = subj(i).O1meanTF;
    subj(i).O1alpha1Ceiling = (subj(i).O1meanIAF + subj(i).O1meanTF) / 2;
    subj(i).O1alpha2Floor   = (subj(i).O1meanIAF + subj(i).O1meanTF) / 2;
    subj(i).O1alpha2Ceiling = subj(i).O1meanIAF;
    subj(i).O1alpha3Floor   = subj(i).O1meanIAF;
    subj(i).O1alpha3Ceiling = subj(i).O1meanIAF + 2;
    subj(i).O1alphaCeiling  = subj(i).O1meanIAF + 2;
    % TODO: Find peaks and troughs, use to calculate these
    %subj(i).Beta1_floor   = 
    %subj(i).Beta1_ceiling = 
    %subj(i).Beta2_floor   = 
    %subj(i).Beta2_ceiling = 
    %subj(i).gammaFloor    = 
    % Gamma ceiling already set
    % In case TF is below 4.5, readjust deltaFloor so we don't get incorrect
    % power calculations 
    if subj(i).O1deltaFloor < 0.5
        subj(i).O1deltaFloor = 0.5;
    end
    
    % --------------- %
    % Calculate Power %
    % --------------- %

    % Run spectopo to acquire power spectrum, and calculate absolute power
    [C3avgPSD, C3avgFreq] = spectopo(subj(i).avgC3Signal', 0, 512, 'plot', 'off');
    [O1avgPSD, O1avgFreq] = spectopo(subj(i).avgO1Signal', 0, 512, 'plot', 'off');

    % C3 Power
    subj(i).C3deltaPower  = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3deltaFloor,  subj(i).C3deltaCeiling);
    subj(i).C3thetaPower  = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3thetaFloor,  subj(i).C3thetaCeiling);
    subj(i).C3alphaPower  = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3alphaFloor,  subj(i).C3alphaCeiling);
    subj(i).C3alpha1Power = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3alpha1Floor, subj(i).C3alpha1Ceiling);
    subj(i).C3alpha2Power = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3alpha2Floor, subj(i).C3alpha2Ceiling);
    subj(i).C3alpha3Power = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3alpha3Floor, subj(i).C3alpha3Ceiling);
    subj(i).C3betaPower   = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3betaFloor,   subj(i).C3betaCeiling);
    subj(i).C3gammaPower  = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3gammaFloor,  subj(i).C3gammaCeiling);
    
    % O1 Power
    subj(i).O1deltaPower  = calculatePower(O1avgPSD, O1avgFreq, subj(i).O1deltaFloor,  subj(i).O1deltaCeiling);
    subj(i).O1thetaPower  = calculatePower(O1avgPSD, O1avgFreq, subj(i).O1thetaFloor,  subj(i).O1thetaCeiling);
    subj(i).O1alphaPower  = calculatePower(O1avgPSD, O1avgFreq, subj(i).O1alphaFloor,  subj(i).O1alphaCeiling);
    subj(i).O1alpha1Power = calculatePower(O1avgPSD, O1avgFreq, subj(i).O1alpha1Floor, subj(i).O1alpha1Ceiling);
    subj(i).O1alpha2Power = calculatePower(O1avgPSD, O1avgFreq, subj(i).O1alpha2Floor, subj(i).O1alpha2Ceiling);
    subj(i).O1alpha3Power = calculatePower(O1avgPSD, O1avgFreq, subj(i).O1alpha3Floor, subj(i).O1alpha3Ceiling);
    subj(i).O1betaPower   = calculatePower(O1avgPSD, O1avgFreq, subj(i).O1betaFloor,   subj(i).O1betaCeiling);
    subj(i).O1gammaPower  = calculatePower(O1avgPSD, O1avgFreq, subj(i).O1gammaFloor,  subj(i).O1gammaCeiling);
    
    % Power using fixed frequency bands
    subj(i).O1deltaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3deltaFloor,  subj(i).C3deltaCeiling);
    subj(i).O1thetaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3thetaFloor,  subj(i).C3thetaCeiling);
    subj(i).O1alphaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3alphaFloor,  subj(i).C3alphaCeiling);
    subj(i).O1alpha1Power_fixed = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3alpha1Floor, subj(i).C3alpha1Ceiling);
    subj(i).O1alpha2Power_fixed = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3alpha2Floor, subj(i).C3alpha2Ceiling);
    subj(i).O1alpha3Power_fixed = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3alpha3Floor, subj(i).C3alpha3Ceiling);
    subj(i).O1betaPower_fixed   = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3betaFloor,   subj(i).C3betaCeiling);
    subj(i).O1gammaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3gammaFloor,  subj(i).C3gammaCeiling);
    subj(i).C3deltaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3deltaFloor,  subj(i).C3deltaCeiling);
    subj(i).C3thetaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3thetaFloor,  subj(i).C3thetaCeiling);
    subj(i).C3alphaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3alphaFloor,  subj(i).C3alphaCeiling);
    subj(i).C3alpha1Power_fixed = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3alpha1Floor, subj(i).C3alpha1Ceiling);
    subj(i).C3alpha2Power_fixed = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3alpha2Floor, subj(i).C3alpha2Ceiling);
    subj(i).C3alpha3Power_fixed = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3alpha3Floor, subj(i).C3alpha3Ceiling);
    subj(i).C3betaPower_fixed   = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3betaFloor,   subj(i).C3betaCeiling);
    subj(i).C3gammaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj(i).C3gammaFloor,  subj(i).C3gammaCeiling);
    
    % Calculate ratios
    subj(i).C3AlphaThetaRatio = subj(i).C3alphaPower / subj(i).C3thetaPower; 
    subj(i).O1AlphaThetaRatio = subj(i).O1alphaPower / subj(i).O1thetaPower;
    subj(i).C3AlphaThetaRatio_fixed = subj(i).C3alphaPower_fixed / subj(i).C3alphaPower_fixed;
    subj(i).O1AlphaThetaRatio_fixed = subj(i).O1alphaPower_fixed / subj(i).O1alphaPower_fixed;

    subj(i).C3UpperLowAlphaRatio = subj(i).C3alpha3Power / subj(i).C3alpha3Power;
    subj(i).O1UpperLowAlphaRatio = subj(i).O1alpha3Power / subj(i).O1alpha3Power;
end
toc;
structFile = strcat(exportpath, '/', date, '-results', '.mat');
save(structFile, 'subj');
cl_processalphatheta;