% Outputs results of cl_alpha3alpha2 to CSV file
table{100,100} = [];
table{1,1}  = 'Subject-ID';
table{1,2}  = 'meanTF';
table{1,3}  = 'meanIAF';
table{1,4}  = 'Alpha32Ratio';
table{1,5}  = 'Alpha32Ratio_fixed';
table{1,6}  = 'C3AlphaThetaRatio';
table{1,7}  = 'O1AlphaThetaRatio';
table{1,8}  = 'AlphaThetaRatio';
table{1,9}  = 'AlphaThetaRatio_fixed';
table{1,10} = 'deltaPower';
table{1,11} = 'thetaPower';
table{1,12} = 'alphaPower';
table{1,13} = 'alpha1Power';
table{1,14} = 'alpha2Power';
table{1,15} = 'alpha3Power';
table{1,16} = 'deltaPower_fixed';
table{1,17} = 'thetaPower_fixed';
table{1,18} = 'alphaPower_fixed';
table{1,19} = 'betaPower_fixed';
table{1,20} = 'gammaPower_fixed';
table{1,21} = 'alpha1Power_fixed';
table{1,22} = 'alpha2Power_fixed';
table{1,23} = 'alpha3Power_fixed';

for i = 1:numel(subj)
    table{i+1,1}  = subj{1,i}.SubjectID(9:11);
    table{i+1,2}  = subj{1,i}.meanTF;
    table{i+1,3}  = subj{1,i}.meanIAF;
    table{i+1,4}  = subj{1,i}.ratio_Alpha32;
    table{i+1,5}  = subj{1,i}.ratio_Alpha32Fixed;
    table{i+1,6}  = (subj{1,i}.C3_alphaPower / subj{1,i}.C3_thetaPower);
    table{i+1,7}  = (subj{1,i}.O1_alphaPower / subj{1,i}.O1_thetaPower);
    table{i+1,8}  = subj{1,i}.ratio_AlphaTheta;
    table{i+1,9}  = subj{1,i}.ratio_AlphaThetaFixed;
    % Powers for calculated frequency bands
    table{i+1,10} = subj{1,i}.DeltaPower;
    table{i+1,11} = subj{1,i}.thetaPower;
    table{i+1,12} = subj{1,i}.alphaPower;
    table{i+1,13} = subj{1,i}.alpha1Power;
    table{i+1,14} = subj{1,i}.alpha2Power;
    table{i+1,15} = subj{1,i}.alpha3Power;
    % Powers for fixed frequency bands
    table{i+1,16} = subj{1,i}.fdeltaPower;
    table{i+1,17} = subj{1,i}.fthetaPower;
    table{i+1,18} = subj{1,i}.falphaPower;
    table{i+1,19} = subj{1,i}.fbetaPower;
    table{i+1,20} = subj{1,i}.fgammaPower;
    table{i+1,21} = subj{1,i}.falpha1Power;
    table{i+1,22} = subj{1,i}.falpha2Power;
    table{i+1,23} = subj{1,i}.falpha3Power;
end
index{100,100} = [];
index{1,1}  = 'Delta_Floor';
index{1,2}  = 'Theta_Floor';
index{1,3}  = 'Alpha_Floor';
index{1,4}  = 'Alpha1_Floor';
index{1,5}  = 'Alpha2_Floor';
index{1,6}  = 'Alpha3_Floor';
% index{1,7}  = 'Beta_Floor';
% index{1,8}  = 'Gamma_Floor';
index{1,7}  = 'fixedDelta_Floor';
index{1,8}  = 'fixedTheta_Floor';
index{1,9}  = 'fixedAlpha_Floor';
index{1,10} = 'fixedBeta_Floor';
index{1,11} = 'fixedGamma_Floor';
index{1,12} = 'Gamma_Ceiling';
for i = 1:numel(subj)
    index{i+1,1} = subj{i}.Delta_floor;
    index{i+1,2} = subj{i}.Theta_floor;
    index{i+1,3} = subj{i}.Alpha_floor;
    index{i+1,4} = subj{i}.Alpha1_floor;
    index{i+1,5} = subj{i}.Alpha2_floor;
    index{i+1,6} = subj{i}.Alpha3_floor;
    %index{i+1,7} = subj{i}.Beta_floor;
    %index{i+1,8} = subj{i}.Gamma_floor;
    index{i+1,7} = subj{i}.fixedDelta_floor;
    index{i+1,8} = subj{i}.fixedTheta_floor;
    index{i+1,9} = subj{i}.fixedAlpha_floor;
    index{i+1,10} = subj{i}.fixedBeta_floor;
    index{i+1,11} = subj{i}.fixedGamma_floor;
    index{i+1,12} = subj{i}.fixedGamma_ceiling;
end
resultsCSV = strcat(date, '-results', '.csv');
indexesCSV = strcat(date, '-indexes', '.csv');
cell2csv(resultsCSV, table);
cell2csv(indexesCSV, index);