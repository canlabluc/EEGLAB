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

% ---------------- %
% Begin processing %
% ---------------- %
tic;
for i = 1:numel(files)
    [Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(i).name));
    subj(i).SubjectID = files(i).name(9:11);
    % default
    %   
    %   For each C3 electrode, computes the IAF/TF
    %   For each O1 electrode, computes the IAF/TF
    %   Takes grand average of C3 electrodes
    %   Takes grand average of O1 electrodes
    %   Using the average C3 IAF / average C3 TF, compute individualized power using
    %   the PSD of the C3 grand average
    %   Using the average O1 IAF / average O1 TF, compute individualized power using
    %   the PSD of the O1 grand average
    %      
    if strcmp(method, 'default')
        for j = 1:size(Signal, 2)
            if any(C3trodes == j)
                C3PeakFit = nbt_doPeakFit(Signal(:,j), SignalInfo);
                subj(i).C3(subj(i).misc.C3Added).Signal = Signal(:,j);
                if isnan(C3PeakFit.IAF) || C3PeakFit.IAF < 7 || C3PeakFit.IAF > 13
                    subj(i).misc.measure = 'IAF';
                    subj(i).misc.analysisType = 'C3_alphatheta';
                    subj = cl_correctBadFits(subj, C3PeakFit, Signal, i, j, rejectBadFits, guiFit);
                else
                    subj(i).C3(subj(i).misc.C3Added).IAF = C3PeakFit.IAF;
                end
                if isnan(C3PeakFit.TF) || C3PeakFit.TF < 4 || C3PeakFit.TF > 7
                    subj(i).misc.measure = 'TF';
                    subj(i).misc.analysisType = 'C3_alphatheta';
                    subj = cl_correctBadFits(subj, C3PeakFit, Signal, i, j, rejectBadFits, guiFit);
                else
                    subj(i).C3(subj(i).misc.C3Added).TF  = C3PeakFit.TF;
                end
                subj(i).misc.C3Added = subj(i).misc.C3Added + 1;
            elseif any(O1trodes == j)
                O1PeakFit = nbt_doPeakFit(Signal(:,j), SignalInfo);
                subj(i).O1(subj(i).misc.O1Added).Signal = Signal(:,j);
                if isnan(O1PeakFit.IAF) || O1PeakFit.IAF < 7 || O1PeakFit.IAF > 13
                    subj(i).misc.measure = 'IAF';
                    subj(i).misc.analysisType = 'O1_alphatheta';
                    subj = cl_correctBadFits(subj, O1PeakFit, Signal, i, j, rejectBadFits, guiFit);
                else
                    subj(i).O1(subj(i).misc.O1Added).IAF = O1PeakFit.IAF;
                end
                if isnan(O1PeakFit.TF) || O1PeakFit.TF < 4 || O1PeakFit.TF > 7
                    subj(i).misc.measure = 'TF';
                    subj(i).misc.analysisType = 'O1_alphatheta';
                    subj = cl_correctBadFits(subj, O1PeakFit, Signal, i, j, rejectBadFits, guiFit);
                else
                    subj(i).O1(subj(i).misc.O1Added).TF  = O1PeakFit.TF;
                end
                subj(i).misc.O1Added = subj(i).misc.O1Added + 1;
            end
        end
    % avgPSD
    % 
    %   Compute the average C3 PSD, using all C3 electrodes
    %   Compute the average O1 PSD, using all O1 electrodes
    %   Use 15th order polynomial to calculate max and min for both PSDs
    %   The maximum in the 7 - 13 Hz range is the IAF
    %   The minimum in the 1 - 7 Hz range is the TF
    %   Calculate individualized power using these measurements
    %   
    elseif strcmp(method, 'avgPSD')
        for j = 1:size(Signal, 2)
            if any(C3trodes == j)
                disp('Hello world!');
            elseif any (O1trodes == j)
                disp('Hello world!');
            end
        end
    end
    % Find grand average of the aforementioned electrodes, and calculate overall
    % IAF and TF for this subject, in both the C3 and O1 electrodes
    subj(i).C3meanTF  = mean([subj(i).C3.TF]);
    subj(i).C3meanIAF = mean([subj(i).C3.IAF]);
    subj(i).O1meanTF  = mean([subj(i).O1(:).TF]);
    subj(i).O1meanIAF = mean([subj(i).O1(:).IAF]);

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
    subj(i).O1deltaPower_fixed  = calculatePower(O1avgPSD, O1avgFreq, subj(i).deltaFloor_fixed,  subj(i).deltaCeiling_fixed);
    subj(i).O1thetaPower_fixed  = calculatePower(O1avgPSD, O1avgFreq, subj(i).thetaFloor_fixed,  subj(i).thetaCeiling_fixed);
    subj(i).O1alphaPower_fixed  = calculatePower(O1avgPSD, O1avgFreq, subj(i).alphaFloor_fixed,  subj(i).alphaCeiling_fixed);
    subj(i).O1alpha1Power_fixed = calculatePower(O1avgPSD, O1avgFreq, subj(i).alpha1Floor_fixed, subj(i).alpha1Ceiling_fixed);
    subj(i).O1alpha2Power_fixed = calculatePower(O1avgPSD, O1avgFreq, subj(i).alpha2Floor_fixed, subj(i).alpha2Ceiling_fixed);
    subj(i).O1alpha3Power_fixed = calculatePower(O1avgPSD, O1avgFreq, subj(i).alpha3Floor_fixed, subj(i).alpha3Ceiling_fixed);
    subj(i).O1betaPower_fixed   = calculatePower(O1avgPSD, O1avgFreq, subj(i).betaFloor_fixed,   subj(i).betaCeiling_fixed);
    subj(i).O1gammaPower_fixed  = calculatePower(O1avgPSD, O1avgFreq, subj(i).gammaFloor_fixed,  subj(i).gammaCeiling_fixed);
    
    subj(i).C3deltaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj(i).deltaFloor_fixed,  subj(i).deltaCeiling_fixed);
    subj(i).C3thetaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj(i).thetaFloor_fixed,  subj(i).thetaCeiling_fixed);
    subj(i).C3alphaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj(i).alphaFloor_fixed,  subj(i).alphaCeiling_fixed);
    subj(i).C3alpha1Power_fixed = calculatePower(C3avgPSD, C3avgFreq, subj(i).alpha1Floor_fixed, subj(i).alpha1Ceiling_fixed);
    subj(i).C3alpha2Power_fixed = calculatePower(C3avgPSD, C3avgFreq, subj(i).alpha2Floor_fixed, subj(i).alpha2Ceiling_fixed);
    subj(i).C3alpha3Power_fixed = calculatePower(C3avgPSD, C3avgFreq, subj(i).alpha3Floor_fixed, subj(i).alpha3Ceiling_fixed);
    subj(i).C3betaPower_fixed   = calculatePower(C3avgPSD, C3avgFreq, subj(i).betaFloor_fixed,   subj(i).betaCeiling_fixed);
    subj(i).C3gammaPower_fixed  = calculatePower(C3avgPSD, C3avgFreq, subj(i).gammaFloor_fixed,  subj(i).gammaCeiling_fixed);
    
    % Calculate ratios
    subj(i).C3AlphaThetaRatio = subj(i).C3alphaPower / subj(i).C3thetaPower; 
    subj(i).O1AlphaThetaRatio = subj(i).O1alphaPower / subj(i).O1thetaPower;
    subj(i).C3AlphaThetaRatio_fixed = subj(i).C3alphaPower_fixed / subj(i).C3alphaPower_fixed;
    subj(i).O1AlphaThetaRatio_fixed = subj(i).O1alphaPower_fixed / subj(i).O1alphaPower_fixed;

    subj(i).C3UpperLowAlphaRatio = subj(i).C3alpha3Power / subj(i).C3alpha3Power;
    subj(i).O1UpperLowAlphaRatio = subj(i).O1alpha3Power / subj(i).O1alpha3Power;
end
toc;
cd ~/Dropbox/data;
structFile = strcat(date, '-results', '.mat');
save(structFile, 'subj');
cl_processalphatheta(subj);
