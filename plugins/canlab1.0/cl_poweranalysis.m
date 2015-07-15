% This script utilizes nbt_doPeakFit and EEGLAB's spectopo() function to calculate the mean
% power ratio for power bands derived from calculating the TF and IAF. 

importpath = uigetdir('C:\Users\canlab\Documents\MATLAB\', 'Select folder to import from');
if importpath == 0
    error('Error: Please specify the folder that contains the .set files.');
end
fprintf('Import path: %s\n', importpath);
exportpath   = uigetdir('C:\Users\canlab\Documents\MATLAB\', 'Select folder to export results to');
if exportpath == 0
    error('Error: Please specify the folder to export results files to.');
end

files = dir(fullfile(strcat(importpath, '/*S.mat')));
subj{size(files, 1)} = [];
for i = 1:numel(files)
    [Signal, SignalInfo, path] = nbt_load_file(strcat(importpath, '/', files(i).name));
    disp('Signal loaded, beginning analysis');
    subj{i}.Subj_ID = files(i).name;
    subj{i}.peakFit = nbt_doPeakFit(Signal, SignalInfo);
    % Find mean IAF, TF, and find needed indexes
    disp('Peak Fit complete, calculating indexes');
    subj{i}.meanIAF = mean(subj{i}.peakFit.IAF);
    subj{i}.meanTF  = mean(subj{i}.peakFit.TF);
    subj{i}.Theta_floor  = subj{i}.meanTF - 2;
    subj{i}.Alpha2_floor = (subj{i}.meanIAF + subj{i}.meanTF) / 2;
    subj{i}.Alpha3_roof  = subj{i}.meanIAF + 2;
    % Partition the PSD vector according to calculated indexes, and compute 
    % power ratios.
    sampRate = 512;
    disp('Computing PSD');
    [power, freq] = spectopo(mean(Signal'), 0, sampRate);
    subj{i}.mean_thetaPower = mean(power(freq >= subj{i}.Theta_floor & freq <= subj{i}.meanTF));
    subj{i}.mean_alpha1Power = mean(power(freq >= subj{i}.meanTF & freq <= subj{i}.Alpha2_floor));
    subj{i}.mean_alpha2Power = mean(power(freq >= subj{i}.Alpha2_floor & freq <= subj{i}.meanIAF));
    subj{i}.mean_alpha3Power = mean(power(freq >= subj{i}.meanIAF & freq <= subj{i}.Alpha3_roof));
    
    subj{i}.ratio_mean_alpha32 = subj{i}.mean_alpha3Power / subj{i}.mean_alpha2Power;
    save(strcat('subj', SignalInfo.subjectID, date, '.mat'), 'subj{i}');
end
save('complete_struct.mat', 'subj');

