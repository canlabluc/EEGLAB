% Script to generate topoplots for slope data from RS and GNG protocols.

EEG = pop_loadset('/Volumes/T3/_psd-slope/data/rs/20s/topographic-corr/120127101_has_chanlocs.set')
chans_consistent = {'A01','A02','A03','A04','A05','A06','A07','A08','A09','A10','A11','A12','A13','A14','A15','A16','A17','A18','A19','A20','A21','A22','A23','A24','A25','A26','A27','A28','A29','A30','A31','A32','B01','B02','B03','B04','B05','B06','B07','B08','B09','B10','B11','B12','B13','B14','B15','B16','B17','B18','B19','B20','B21','B22','B23','B24','B25','B26','B27','B28','B29','B30','B31','B32','EXG1','EXG2'};
for i = 1:numel(chans_consistent)
    EEG.chanlocs(i).labels = chans_consistent{i};
end

% GoNoGo Topoplots
chans_gng = {'A01','A02','A03','A04','A05','A06','A07','A08','A10','A11','A12','A13','A14','A15','A16','A17','A18','A21','A22','A23','A24','A25','A26','A27','A29','A30','A31','B01','B02','B03','B04','B05','B06','B08','B09','B10','B11','B12','B13','B14','B17','B18','B19','B20','B21','B22','B23','B24','B26','B27','B28','B29','B30'};
zscores_gng = [0.0912,-0.1428,-0.1286,-0.1283,0.0989,0.1612,0.2735,-0.0057,-0.0092,0.2834,0.2362,0.3273,0.2453,0.2397,0.357,0.4355,0.4819,0.4068,0.3542,0.4758,0.4845,0.5922,0.5267,0.5703,0.6634,0.6682,0.7339,0.0593,0.1005,0.2986,0.2328,0.3345,0.2363,0.2499,0.1871,0.4014,0.3905,0.2117,0.3025,0.04,0.6491,0.5433,0.5747,0.3424,0.5342,0.5093,0.7493,0.6636,0.6671,0.927,0.5325,0.8105,0.8464];
bad_idx = [];
for i = 1:numel(EEG.chanlocs)
    curr = EEG.chanlocs(i).labels;
    found = false;
    for j = 1:numel(chans_gng)
        if strcmp(chans_gng{j}, curr)
            found = true;
        end
    end
    if found == false
        bad_idx(end+1) = i;
    end
end
bad_idx = fliplr(bad_idx);
EEG.chanlocs(bad_idx) = [];

figure;
title('GNG Z-Score Differences');
topoplot(zscores_gng, EEG.chanlocs, 'maplimits', [-1, 1]*max(abs(zscores_gng)), 'shading', 'interp', 'style', 'map');
cbar('vert', 0, [-1, 1]*max(abs(zscores_gng)));


% RS Topoplots
chans_rs = {'A01','A02','A03','A04','A05','A06','A07','A08','A09','A10','A11','A12','A13','A14','A15','A16','A17','A18','A19','A20','A21','A22','A23','A24','A25','A26','A27','A28','A29','A30','A31','A32','B01','B02','B03','B04','B05','B06','B07','B08','B09','B10','B11','B12','B13','B14','B15','B16','B17','B18','B19','B20','B21','B22','B23','B24','B25','B26','B27','B28','B29','B30','B31'};
zscores_rs = [-0.18021,-0.25518,0.09629,-0.20115,0.13879,0.01667,0.02798,0.20417,0.09071,0.45118,0.22709,-0.11012,-0.18585,-0.07434,-0.05629,-0.36011,0.09563,0.24046,0.04369,0.45333,0.46966,-0.0726,-0.20492,-0.11611,-0.34222,0.25503,0.32159,0.70206,0.38847,-0.20056,0.33057,0.63309,0.0638,0.20906,-0.00503,-0.04483,0.05798,0.1668,0.20894,0.38361,0.50754,0.12025,-0.0729,-0.07537,0.02472,0.24727,0.46229,0.16802,0.42225,-0.12441,-0.09882,-0.3046,-0.36497,-0.24484,0.14573,0.34927,0.5088,0.43304,0.1021,-0.46149,-0.06892,0.51297,0.46415];

EEG = pop_loadset('/Volumes/T3/_psd-slope/data/rs/20s/topographic-corr/120127101_has_chanlocs.set')
chans_consistent = {'A01','A02','A03','A04','A05','A06','A07','A08','A09','A10','A11','A12','A13','A14','A15','A16','A17','A18','A19','A20','A21','A22','A23','A24','A25','A26','A27','A28','A29','A30','A31','A32','B01','B02','B03','B04','B05','B06','B07','B08','B09','B10','B11','B12','B13','B14','B15','B16','B17','B18','B19','B20','B21','B22','B23','B24','B25','B26','B27','B28','B29','B30','B31','B32','EXG1','EXG2'};
for i = 1:numel(chans_consistent)
    EEG.chanlocs(i).labels = chans_consistent{i};
end
EEG.chanlocs(end) = []; % EXG2
EEG.chanlocs(end) = []; % EXG1
EEG.chanlocs(end) = []; % B32

figure;
title('RS Z-Score Differences');
topoplot(zscores_rs, EEG.chanlocs, 'maplimits', [-1, 1]*max(abs(zscores_rs)), 'shading', 'interp', 'style', 'map');
cbar('vert', 0, [-1, 1]*max(abs(zscores_rs)));




