% Outputs results of cl_alphatheta to CSV file
table{100,100} = [];
table{1,1}  = 'Subject-ID';
table{1,2}  = 'C3AlphaThetaRatio_fixed';
table{1,3}  = 'O1AlphaThetaRatio_fixed';
% Power
table{1,4} = 'C3DeltaPower_fixed';
table{1,5} = 'C3ThetaPower_fixed';
table{1,6} = 'C3AlphaPower_fixed';
table{1,7} = 'C3Alpha1Power_fixed';
table{1,8} = 'C3Alpha2Power_fixed';
table{1,9} = 'C3Alpha3Power_fixed';
table{1,10} = 'C3BetaPower_fixed'
table{1,11} = 'C3GammaPower_fixed';
table{1,12} = 'O1DeltaPower_fixed';
table{1,13} = 'O1ThetaPower_fixed';
table{1,14} = 'O1AlphaPower_fixed';
table{1,15} = 'O1Alpha1Power_fixed';
table{1,16} = 'O1Alpha2Power_fixed';
table{1,17} = 'O1Alpha3Power_fixed';
table{1,18} = 'O1BetaPower_fixed';
table{1,19} = 'O1GammaPower_fixed';
% Indexes
table{1,20} = 'deltaFloor_fixed';
table{1,21} = 'thetaFloor_fixed';
table{1,22} = 'alphaFloor_fixed';
table{1,23} = 'alpha1Floor_fixed';
table{1,24} = 'alpha2Floor_fixed';
table{1,25} = 'alpha3Floor_fixed';
table{1,26} = 'betaFloor_fixed';
table{1,27} = 'gammaFloor_fixed';

for i = 1:numel(subj)
	table{i+1,1}  = subj{i}.SubjectID;
	table{i+1,2}  = subj{i}.C3alphaPower_fixed / subj{i}.C3thetaPower_fixed;
	table{i+1,3}  = subj{i}.O1alphaPower_fixed / subj{i}.O1thetaPower_fixed;
	table{i+1,4}  = subj{i}.C3deltaPower_fixed;
	table{i+1,5}  = subj{i}.C3thetaPower_fixed;
	table{i+1,6}  = subj{i}.C3alphaPower_fixed;
	table{i+1,7}  = subj{i}.C3alpha1Power_fixed;
	table{i+1,8}  = subj{i}.C3alpha2Power_fixed;
	table{i+1,9}  = subj{i}.C3alpha3Power_fixed;
	table{i+1,10} = subj{i}.C3fixedbetaPower;
	table{i+1,11} = subj{i}.C3fixedgammaPower;
	table{i+1,12} = subj{i}.O1deltaPower_fixed;
	table{i+1,13} = subj{i}.O1thetaPower_fixed;
	table{i+1,14} = subj{i}.O1alphaPower_fixed;
	table{i+1,15} = subj{i}.O1alpha1Power_fixed;
	table{i+1,16} = subj{i}.O1alpha2Power_fixed;
	table{i+1,17} = subj{i}.O1alpha3Power_fixed;
	table{i+1,18} = subj{i}.O1fixedbetaPower;
	table{i+1,19} = subj{i}.O1fixedgammaPower;

	table{i+1,20} = subj{i}.deltaFloor_fixed;
	table{i+1,21} = subj{i}.thetaFloor_fixed;
	table{i+1,22} = subj{i}.alphaFloor_fixed;
	table{i+1,23} = subj{i}.alpha1Floor_fixed;
	table{i+1,24} = subj{i}.alpha2Floor_fixed;
	table{i+1,25} = subj{i}.alpha3Floor_fixed;
	table{i+1,26} = subj{i}.betaFloor_fixed;
	table{i+1,27} = subj{i}.gammaFloor_fixed;
end

resultsCSV = strcat(date, '-alphatheta', '.csv');
cell2csv(resultsCSV, table);
