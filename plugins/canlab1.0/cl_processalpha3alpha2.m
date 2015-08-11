% Outputs results of cl_alpha3alpha2 to CSV file
table{100,100} = [];
table{1,1}  = 'SubjectID';
table{1,2}  = 'meanTF';
table{1,3}  = 'meanIAF';
table{1,4}  = 'Alpha32Ratio';
table{1,5}  = 'Alpha32Ratio_fixed';
table{1,6}  = 'AlphaThetaRatio';
table{1,7}  = 'AlphaThetaRatio_fixed';
table{1,8}  = 'deltaPower';
table{1,9}  = 'thetaPower';
table{1,10} = 'alphaPower';
table{1,11} = 'alpha1Power';
table{1,12} = 'alpha2Power';
table{1,13} = 'alpha3Power';
table{1,14} = 'deltaPower_fixed';
table{1,15} = 'thetaPower_fixed';
table{1,16} = 'alphaPower_fixed';
table{1,17} = 'betaPower_fixed';
table{1,18} = 'gammaPower_fixed';
table{1,19} = 'alpha1Power_fixed';
table{1,20} = 'alpha2Power_fixed';
table{1,21} = 'alpha3Power_fixed';

for i = 1:(numel(subj)-1)
    table{i+1,1}  = subj{i}.SubjectID;
    table{i+1,2}  = subj{i}.meanTF;
    table{i+1,3}  = subj{i}.meanIAF;
    table{i+1,4}  = subj{i}.ratio_Alpha32;
    table{i+1,5}  = subj{i}.ratio_AlphaTheta;
    table{i+1,6}  = subj{i}.ratio_Alpha32Fixed;
    table{i+1,7}  = subj{i}.ratio_AlphaThetaFixed;
    table{i+1,8}  = subj{i}.deltaPower;
    table{i+1,9}  = subj{i}.thetaPower;
    table{i+1,10} = subj{i}.alphaPower;
    table{i+1,11} = subj{i}.alpha1Power;
    table{i+1,12} = subj{i}.alpha2Power;
    table{i+1,13} = subj{i}.alpha3Power;
    table{i+1,14} = subj{i}.deltaPower_fixed;
    table{i+1,15} = subj{i}.thetaPower_fixed;
    table{i+1,16} = subj{i}.alphaPower_fixed;
    table{i+1,17} = subj{i}.alpha1Power_fixed;
    table{i+1,18} = subj{i}.alpha2Power_fixed;
    table{i+1,19} = subj{i}.alpha3Power_fixed;
    table{i+1,20} = subj{i}.betaPower_fixed;
    table{i+1,21} = subj{i}.gammaPower_fixed;
end

index{100,100} = [];
index{1,1}  = 'Delta_Floor';
index{1,2}  = 'Theta_Floor';
index{1,3}  = 'Alpha_Floor';
index{1,4}  = 'Alpha1_Floor';
index{1,5}  = 'Alpha2_Floor';
index{1,6}  = 'Alpha3_Floor';
index{1,7}  = 'Beta_Floor';
index{1,8}  = 'Gamma_Floor';
index{1,9}  = 'fixedDelta_Floor';
index{1,10}  = 'fixedTheta_Floor';
index{1,11}  = 'fixedAlpha_Floor';
index{1,12} = 'fixedAlpha1_Floor';
index{1,13} = 'fixedAlpha2_Floor';
index{1,14} = 'fixedAlpha3_Floor';
index{1,15} = 'fixedBeta_Floor';
index{1,16} = 'fixedGamma_Floor';
index{1,17} = 'Gamma_Ceiling';

for i = 1:(numel(subj)-1)
    index{i+1,1}  = subj(i).deltaFloor;
    index{i+1,2}  = subj(i).thetaFloor;
    index{i+1,3}  = subj(i).alphaFloor;
    index{i+1,4}  = subj(i).alpha1Floor;
    index{i+1,5}  = subj(i).alpha2Floor;
    index{i+1,6}  = subj(i).alpha3Floor;
    index{i+1,7}  = 'NA';
    index{i+1,8}  = 'NA';
    index{i+1,9}  = subj(i).deltaFloor_fixed;
    index{i+1,10} = subj(i).thetaFloor_fixed;
    index{i+1,11} = subj(i).alphaFloor_fixed;
    index{i+1,12} = subj(i).alpha1Floor_fixed;
    index{i+1,13} = subj(i).alpha2Floor_fixed;
    index{i+1,14} = subj(i).alpha3Floor_fixed;
    index{i+1,15} = subj(i).betaFloor_fixed;
    index{i+1,16} = subj(i).gammaFloor_fixed;
    index{i+1,17} = subj(i).gammaCeiling_fixed;
end

resultsCSV = strcat(date, '-results', '.csv');
indexesCSV = strcat(date, '-indexes', '.csv');
cell2csv(resultsCSV, table);
cell2csv(indexesCSV, index);