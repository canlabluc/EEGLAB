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

files = dir(fullfile(strcat(importpath, '/*S.mat')));
% Preallocation of memory
[Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(1).name));
subj(size(files,1)) = struct();
subj(:) = struct('SubjectID', 'SXXX',...
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
                 'misc', struct('C3Added', 1, 'O1Added', 1,...
                                'rejectedIAFs', [],...
                                'rejectedTFs', [],...
                                'inspectedIAFs', zeros(1, size(Signal,2)),...
                                'inspectedTFs', zeros(1, size(Signal,2)),...
                                'samplingFreq', SignalInfo.original_sample_frequency,...
                                'measure', NaN),...
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
    for j = 1:numel(C3trodes)
        subj(i).C3(j) = struct('Signal', zeros(10240, 1), 'IAF', 0.0, 'TF', 0.0);
    end
    for k = 1:numel(O1trodes)
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
                subj(i).C3(subj(i).C3Added).Signal = Signal(:,j);
                if isnan(C3PeakFit.IAF) || C3PeakFit.IAF < 7 || C3PeakFit.IAF > 13
                    subj(i).misc.measure = 'IAF';
                    subj(i).misc.analysisType = 'C3_alphatheta';
                    subj = cl_correctBadFits(subj, C3PeakFit, Signal, i, j, rejectBadFits, guiFit);
                else
                    subj(i).C3(subj(i).C3Added).IAF = C3PeakFit.IAF;
                    subj(i).C3Added = subj(i).C3Added + 1;
                end
                if isnan(C3PeakFit.TF) || C3PeakFit.TF < 4 || C3PeakFit.TF > 7
                    subj(i).misc.measure = 'TF';
                    subj(i).misc.analysisType = 'C3_alphatheta';
                    subj = cl_correctBadFits(subj, C3PeakFit, Signal, i, j, rejectBadFits, guiFit);
                else
                    subj(i).C3(subj(i).C3Added).TF  = C3PeakFit.TF;
                    subj(i).C3Added = subj(i).C3Added + 1;
                end
            elseif any(O1trodes == j)
                O1PeakFit = nbt_doPeakFit(Signal(:,j), SignalInfo);
                subj(i).O1(subj(i).O1Added).Signal = Signal(:,j);
                if isnan(O1PeakFit.IAF) || O1PeakFit.IAF < 7 || O1PeakFit.IAF > 13
                    subj(i).misc.measure = 'IAF';
                    subj(i).misc.analysisType = 'O1_alphatheta';
                    subj = cl_correctBadFits(subj, O1PeakFit, Signal, i, j, rejectBadFits, guiFit);
                else
                    subj(i).O1(subj(i).O1Added).IAF = O1PeakFit.IAF;
                    subj(i).O1Added = subj(i).O1Added + 1;
                end
                if isnan(O1PeakFit.TF) || O1PeakFit.TF < 4 || O1PeakFit.TF > 7
                    subj(i).misc.measure = 'TF';
                    subj(i).misc.analysisType = 'O1_alphatheta';
                    subj = cl_correctBadFits(subj, O1PeakFit, Signal, i, j, rejectBadFits, guiFit);
                else
                    subj(i).O1(subj(i).O1Added).TF  = O1PeakFit.TF;
                    subj(i).O1Added = subj(i).O1Added + 1;
                end                
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
    subj(i).C3meanTF  = mean(subj(i).C3(:).TF);
    subj(i).C3meanIAF = mean(subj(i).C3(:).IAF);
    subj(i).O1meanTF  = mean(subj(i).O1(:).TF);
    subj(i).O1meanIAF = mean(subj(i).O1(:).IAF);

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