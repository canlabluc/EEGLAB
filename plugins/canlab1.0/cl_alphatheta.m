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

function subj = cl_alphatheta(importpath, exportpath, method, rejectBadFits, guiFit)

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
    exportpath = uigetdir('~', 'Select folder to export .set files to');
    if exportpath == 0
        error('Error: Please specify the folder to export the .set files to.');
    end
end
    fprintf('Export path: %s\n', exportpath);
if (~exist('method', 'var'))
    method = 'default';
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
fprintf(fileID, 'method:     %s\n', method)
fprintf(fileID, 'rejectBadFits: %s\n', rejectBadFits)
fprintf(fileID, 'guiFit:     %s\n', guiFit)
fclose(fileID)

% Create list of files and allocate necessary memory for the analysis
files = dir(fullfile(strcat(importpath, '/*S.mat')));
[Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(1).name));
subj = cl_allocateSubj('cl_alphatheta', size(files,1), size(Signal,2), SignalInfo.original_sample_frequency);

for i = 1:numel(files)
    [Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(i).name));
    subj(i).SubjectID = files(i).name(9:11);
    
    % --------------------------------------------- %
    % Calculate IAF, TF, and power for each channel %
    % --------------------------------------------- %
        
    for j = 1:numel(C3trodes)
        C3PeakFit = nbt_doPeakFit(Signal(:,C3trodes(j)), SignalInfo);
        subj(i).C3(j).Signal = Signal(:,C3trodes(j));
        if isnan(C3PeakFit.IAF) || C3PeakFit.IAF < 7 || C3PeakFit.IAF > 13
            subj(i).misc.measure = 'IAF';
            subj(i).misc.analysisType = 'C3_alphatheta';
            subj = cl_correctBadFits(subj, C3PeakFit, Signal, i, j, rejectBadFits, guiFit);
        else
            subj(i).C3(j).TF = C3PeakFit.TF;
        end
        if isnan(C3PeakFit.TF) || C3PeakFit.TF < 4 || C3PeakFit.TF > 7
            subj(i).misc.measure = 'TF';
            subj(i).misc.analysisType = 'C3_alphatheta';
            subj(i).C3(j).TF = C3PeakFit.TF;
        else
            subj(i).O1(j).TF = C3PeakFit.TF;
        end
        % Now calculate power for this electrode across all bands
        subj(i).C3(j).deltaFloor    = subj(i).C3(j).TF - 4;
        subj(i).C3(j).deltaCeiling  = subj(i).C3(j).TF - 2;
        subj(i).C3(j).thetaFloor    = subj(i).C3(j).TF - 2;
        subj(i).C3(j).thetaCeiling  = subj(i).C3(j).TF;
        subj(i).C3(j).alphaFloor    = subj(i).C3(j).TF;
        subj(i).C3(j).alpha1Floor   = subj(i).C3(j).TF;
        subj(i).C3(j).alpha1Ceiling = (subj(i).C3(j).TF + subj(i).C3(j).IAF) / 2;
        subj(i).C3(j).alpha2Floor   = subj(i).C3(j).alpha1Ceiling;
        subj(i).C3(j).alpha2Ceiling = subj(i).C3(j).IAF;
        subj(i).C3(j).alpha3Floor   = subj(i).C3(j).IAF;
        subj(i).C3(j).alpha3Ceiling = subj(i).C3(j).IAF + 2;
        subj(i).C3(j).alphaCeiling  = subj(i).C3(j).IAF + 2;
        if subj(i).C3(j).deltaFloor < 0.5
            subj(i).C3(j).deltaFloor = 0.5;
        end

        [PSD, Freqs] = spectopo(Signal(:,j)', 0, 512, 'plot', 'off');
        subj(i).C3(j).deltaPower = calculatePower(PSD, Freqs, subj(i).C3(j).deltaFloor, subj(i).C3(j).deltaCeiling);
        subj(i).C3(j).thetaPower = calculatePower(PSD, Freqs, subj(i).C3(j).thetaFloor, subj(i).C3(j).thetaCeiling);
        subj(i).C3(j).alphaPower = calculatePower(PSD, Freqs, subj(i).C3(j).alphaFloor, subj(i).C3(j).alphaCeiling);
        subj(i).C3(j).alpha1Power = calculatePower(PSD, Freqs, subj(i).C3(j).alpha1Floor, subj(i).C3(j).alpha1Ceiling);
        subj(i).C3(j).alpha2Power = calculatePower(PSD, Freqs, subj(i).C3(j).alpha2Floor, subj(i).C3(j).alpha2Ceiling);
        subj(i).C3(j).alpha3Power = calculatePower(PSD, Freqs, subj(i).C3(j).alpha3Floor, subj(i).C3(j).alpha3Ceiling);

        subj(i).C3(j).deltaPower_fixed = calculatePower(PSD, Freqs, subj(i).deltaFloor_fixed, subj(i).deltaCeiling_fixed);
        subj(i).C3(j).thetaPower_fixed = calculatePower(PSD, Freqs, subj(i).thetaFloor_fixed, subj(i).thetaCeiling_fixed);
        subj(i).C3(j).alphaPower_fixed = calculatePower(PSD, Freqs, subj(i).alphaFloor_fixed, subj(i).alphaCeiling_fixed);
        subj(i).C3(j).alpha1Power_fixed = calculatePower(PSD, Freqs, subj(i).alpha1Floor_fixed, subj(i).alpha1Ceiling_fixed);
        subj(i).C3(j).alpha2Power_fixed = calculatePower(PSD, Freqs, subj(i).alpha2Floor_fixed, subj(i).alpha2Ceiling_fixed);
        subj(i).C3(j).alpha3Power_fixed = calculatePower(PSD, Freqs, subj(i).alpha3Floor_fixed, subj(i).alpha3Ceiling_fixed);

        subj(i).C3(j).C3AlphaThetaRatio = subj(i).C3(j).alphaPower / subj(i).C3(j).thetaPower;
        subj(i).C3(j).C3AlphaThetaRatio_fixed = subj(i).C3(j).alphaPower_fixed / subj(i).C3(j).thetaPower_fixed;
        subj(i).C3(j).C3UpperLowAlphaRatio = subj(i).C3(j).alpha3Power / subj(i).C3(j).alpha3Power;
    end
    for j = 1:numel(O1trodes)
        O1PeakFit = nbt_doPeakFit(Signal(:,O1trodes(j)), SignalInfo);
        subj(i).O1(j).Signal = Signal(:,O1trodes(j));
        if isnan(O1PeakFit.IAF) || O1PeakFit.IAF < 7 || O1PeakFit.IAF > 13
            subj(i).misc.measure = 'IAF';
            subj(i).misc.analysisType = 'O1_alphatheta';
            subj = cl_correctBadFits(subj, O1PeakFit, Signal, i, j, rejectBadFits, guiFit);
        else
            subj(i).O1(j).TF = O1PeakFit.TF;
        end
        if isnan(O1PeakFit.TF) || O1PeakFit.TF < 4 || O1PeakFit.TF > 7
            subj(i).misc.measure = 'TF';
            subj(i).misc.analysisType = 'O1_alphatheta';
            subj(i).O1(j).TF = O1PeakFit.TF;
        else
            subj(i).O1(j).TF = O1PeakFit.TF;
        end
        % Now calculate power for this electrode across all bands
        subj(i).O1(j).deltaFloor    = subj(i).O1(j).TF - 4;
        subj(i).O1(j).deltaCeiling  = subj(i).O1(j).TF - 2;
        subj(i).O1(j).thetaFloor    = subj(i).O1(j).TF - 2;
        subj(i).O1(j).thetaCeiling  = subj(i).O1(j).TF;
        subj(i).O1(j).alphaFloor    = subj(i).O1(j).TF;
        subj(i).O1(j).alpha1Floor   = subj(i).O1(j).TF;
        subj(i).O1(j).alpha1Ceiling = (subj(i).O1(j).TF + subj(i).O1(j).IAF) / 2;
        subj(i).O1(j).alpha2Floor   = subj(i).O1(j).alpha1Ceiling;
        subj(i).O1(j).alpha2Ceiling = subj(i).O1(j).IAF;
        subj(i).O1(j).alpha3Floor   = subj(i).O1(j).IAF;
        subj(i).O1(j).alpha3Ceiling = subj(i).O1(j).IAF + 2;
        subj(i).O1(j).alphaCeiling  = subj(i).O1(j).IAF + 2;
        if subj(i).O1(j).deltaFloor < 0.5
            subj(i).O1(j).deltaFloor = 0.5;
        end

        [PSD, Freqs] = spectopo(Signal(:,j)', 0, 512, 'plot', 'off');
        subj(i).O1(j).deltaPower  = calculatePower(PSD, Freqs, subj(i).O1(j).deltaFloor, subj(i).O1(j).deltaCeiling);
        subj(i).O1(j).thetaPower  = calculatePower(PSD, Freqs, subj(i).O1(j).thetaFloor, subj(i).O1(j).thetaCeiling);
        subj(i).O1(j).alphaPower  = calculatePower(PSD, Freqs, subj(i).O1(j).alphaFloor, subj(i).O1(j).alphaCeiling);
        subj(i).O1(j).alpha1Power = calculatePower(PSD, Freqs, subj(i).O1(j).alpha1Floor, subj(i).O1(j).alpha1Ceiling);
        subj(i).O1(j).alpha2Power = calculatePower(PSD, Freqs, subj(i).O1(j).alpha2Floor, subj(i).O1(j).alpha2Ceiling);
        subj(i).O1(j).alpha3Power = calculatePower(PSD, Freqs, subj(i).O1(j).alpha3Floor, subj(i).O1(j).alpha3Ceiling);

        subj(i).O1(j).deltaPower_fixed  = calculatePower(PSD, Freqs, subj(i).deltaFloor_fixed, subj(i).deltaCeiling_fixed);
        subj(i).O1(j).thetaPower_fixed  = calculatePower(PSD, Freqs, subj(i).thetaFloor_fixed, subj(i).thetaCeiling_fixed);
        subj(i).O1(j).alphaPower_fixed  = calculatePower(PSD, Freqs, subj(i).alphaFloor_fixed, subj(i).alphaCeiling_fixed);
        subj(i).O1(j).alpha1Power_fixed = calculatePower(PSD, Freqs, subj(i).alpha1Floor_fixed, subj(i).alpha1Ceiling_fixed);
        subj(i).O1(j).alpha2Power_fixed = calculatePower(PSD, Freqs, subj(i).alpha2Floor_fixed, subj(i).alpha2Ceiling_fixed);
        subj(i).O1(j).alpha3Power_fixed = calculatePower(PSD, Freqs, subj(i).alpha3Floor_fixed, subj(i).alpha3Ceiling_fixed);

        subj(i).O1(j).O1AlphaThetaRatio = subj(i).O1(j).alphaPower / subj(i).O1(j).thetaPower;
        subj(i).O1(j).O1AlphaThetaRatio_fixed = subj(i).O1(j).alphaPower_fixed / subj(i).O1(j).thetaPower_fixed;
        subj(i).O1(j).O1UpperLowAlphaRatio = subj(i).O1(j).alpha3Power / subj(i).O1(j).alpha3Power;
    end

    % -------------------------------------------------------------- %
    % Average power calculations to get power across frequency bands %
    % -------------------------------------------------------------- %
    
    subj(i).C3meanTF  = nanmean(subj(i).C3.TF);
    subj(i).C3meanIAF = nanmean(subj(i).C3.IAF);
    subj(i).O1meanTF  = nanmean(subj(i).O1(:).TF);
    subj(i).O1meanIAF = nanmean(subj(i).O1(:).IAF);

    subj(i).C3deltaPower  = nanmean(subj(i).C3(:).deltaPower);
    subj(i).C3thetaPower  = nanmean(subj(i).C3(:).thetaPower);
    subj(i).C3alphaPower  = nanmean(subj(i).C3(:).alphaPower);
    subj(i).C3alpha1Power = nanmean(subj(i).C3(:).alpha1Power);
    subj(i).C3alpha2Power = nanmean(subj(i).C3(:).alpha2Power);
    subj(i).C3alpha3Power = nanmean(subj(i).C3(:).alpha3Power);

    subj(i).O1deltaPower  = nanmean(subj(i).O1(:).deltaPower);
    subj(i).O1thetaPower  = nanmean(subj(i).O1(:).thetaPower);
    subj(i).O1alphaPower  = nanmean(subj(i).O1(:).alphaPower);
    subj(i).O1alpha1Power = nanmean(subj(i).O1(:).alpha1Power);
    subj(i).O1alpha2Power = nanmean(subj(i).O1(:).alpha2Power);
    subj(i).O1alpha3Power = nanmean(subj(i).O1(:).alpha3Power);

    subj(i).C3deltaPower_fixed  = nanmean(subj(i).C3(:).deltaPower_fixed);
    subj(i).C3thetaPower_fixed  = nanmean(subj(i).C3(:).thetaPower_fixed);
    subj(i).C3alphaPower_fixed  = nanmean(subj(i).C3(:).alphaPower_fixed);
    subj(i).C3alpha1Power_fixed = nanmean(subj(i).C3(:).alpha1Power_fixed);
    subj(i).C3alpha2Power_fixed = nanmean(subj(i).C3(:).alpha2Power_fixed);
    subj(i).C3alpha3Power_fixed = nanmean(subj(i).C3(:).alpha3Power_fixed);

    subj(i).O1deltaPower_fixed  = nanmean(subj(i).O1(:).deltaPower_fixed);
    subj(i).O1thetaPower_fixed  = nanmean(subj(i).O1(:).thetaPower_fixed);
    subj(i).O1alphaPower_fixed  = nanmean(subj(i).O1(:).alphaPower_fixed);
    subj(i).O1alpha1Power_fixed = nanmean(subj(i).O1(:).alpha1Power_fixed);
    subj(i).O1alpha2Power_fixed = nanmean(subj(i).O1(:).alpha2Power_fixed);
    subj(i).O1alpha3Power_fixed = nanmean(subj(i).O1(:).alpha3Power_fixed);

    % ---------------------- %
    % Calculate power ratios %
    % ---------------------- %
    
    subj(i).C3AlphaThetaRatio = subj(i).C3alphaPower / subj(i).C3thetaPower;
    subj(i).O1AlphaThetaRatio = subj(i).O1alphaPower / subj(i).O1thetaPower;
    subj(i).C3AlphaThetaRatio_fixed = subj(i).C3alphaPower_fixed / subj(i).C3alphaPower_fixed;
    subj(i).O1AlphaThetaRatio_fixed = subj(i).O1alphaPower_fixed / subj(i).O1alphaPower_fixed;
    subj(i).C3UpperLowAlphaRatio = subj(i).C3alpha3Power / subj(i).C3alpha3Power;
    subj(i).O1UpperLowAlphaRatio = subj(i).O1alpha3Power / subj(i).O1alpha3Power;

    subj(i).avgC3AlphaThetaRatio = nanmean(subj(i).C3(:).C3AlphaThetaRatio);
    subj(i).avgO1AlphaThetaRatio = nanmean(subj(i).O1(:).O1AlphaThetaRatio);
    subj(i).avgC3AlphaThetaRatio_fixed = nanmean(subj(i).C3(:).C3AlphaThetaRatio_fixed);
    subj(i).avgO1AlphaThetaRatio_fixed = nanmean(subj(i).O1(:).O1AlphaThetaRatio_fixed);
    subj(i).avgC3UpperLowAlphaRatio = nanmean(subj(i).C3(:).C3UpperLowAlphaRatio);
    subj(i).avgO1UpperLowAlphaRatio = nanmean(subj(i).O1(:).O1UpperLowAlphaRatio);
end
toc;
structFile = strcat(exportpath, '/', date, '-cl_alphatheta.mat');
save(structFile, 'subj');
cl_processalphatheta(subj), exportpath);
end
