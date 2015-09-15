function cl_processalpha3alpha2(subj, exportpath)

% Outputs results of cl_alpha3alpha2 to CSV file
table{100,100} = [];
table{1,1}  = 'SubjectID';
table{1,2}  = 'TF';
table{1,3}  = 'IAF';
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
table{1,22} = 'Delta_Floor';
table{1,23} = 'Theta_Floor';
table{1,24} = 'Alpha_Floor';
table{1,25} = 'Alpha1_Floor';
table{1,26} = 'Alpha2_Floor';
table{1,27} = 'Alpha3_Floor';
table{1,28} = 'Beta_Floor';
table{1,29} = 'Gamma_Floor';
table{1,30} = 'fixedDelta_Floor';
table{1,31} = 'fixedTheta_Floor';
table{1,32} = 'fixedAlpha_Floor';
table{1,33} = 'fixedAlpha1_Floor';
table{1,34} = 'fixedAlpha2_Floor';
table{1,35} = 'fixedAlpha3_Floor';
table{1,36} = 'fixedBeta_Floor';
table{1,37} = 'fixedGamma_Floor';
table{1,38} = 'Gamma_Ceiling';

for i = 1:numel(subj)
    table{i+1,1}  = subj(i).SubjectID;
    table{i+1,2}  = subj(i).TF;
    table{i+1,3}  = subj(i).IAF;
    table{i+1,4}  = subj(i).ratio_Alpha32;
    table{i+1,5}  = subj(i).ratio_AlphaTheta;
    table{i+1,6}  = subj(i).ratio_Alpha32Fixed;
    table{i+1,7}  = subj(i).ratio_AlphaThetaFixed;
    table{i+1,8}  = subj(i).deltaPower;
    table{i+1,9}  = subj(i).thetaPower;
    table{i+1,10} = subj(i).alphaPower;
    table{i+1,11} = subj(i).alpha1Power;
    table{i+1,12} = subj(i).alpha2Power;
    table{i+1,13} = subj(i).alpha3Power;
    table{i+1,14} = subj(i).deltaPower_fixed;
    table{i+1,15} = subj(i).thetaPower_fixed;
    table{i+1,16} = subj(i).alphaPower_fixed;
    table{i+1,17} = subj(i).alpha1Power_fixed;
    table{i+1,18} = subj(i).alpha2Power_fixed;
    table{i+1,19} = subj(i).alpha3Power_fixed;
    table{i+1,20} = subj(i).betaPower_fixed;
    table{i+1,21} = subj(i).gammaPower_fixed;
    table{i+1,22} = subj(i).deltaFloor;
    table{i+1,23} = subj(i).thetaFloor;
    table{i+1,24} = subj(i).alphaFloor;
    table{i+1,25} = subj(i).alpha1Floor;
    table{i+1,26} = subj(i).alpha2Floor;
    table{i+1,27} = subj(i).alpha3Floor;
    table{i+1,28} = 'NA';
    table{i+1,29} = 'NA';
    table{i+1,30} = subj(i).deltaFloor_fixed;
    table{i+1,31} = subj(i).thetaFloor_fixed;
    table{i+1,32} = subj(i).alphaFloor_fixed;
    table{i+1,33} = subj(i).alpha1Floor_fixed;
    table{i+1,34} = subj(i).alpha2Floor_fixed;
    table{i+1,35} = subj(i).alpha3Floor_fixed;
    table{i+1,36} = subj(i).betaFloor_fixed;
    table{i+1,37} = subj(i).gammaFloor_fixed;
    table{i+1,38} = subj(i).gammaCeiling_fixed;
end

resultsCSV = strcat(exportpath, '/', date, '-results', '.csv');
cell2csv(resultsCSV, table);
end
