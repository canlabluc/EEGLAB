% Computes specified channel clusters and adds them to the EEG object. Clusters
% are computed by averaging channels.
%
% Usage:
%   >> cl_clusters(importpath, exportpath, preset_cluster, cluster)
%   >> cl_clusters('../data/', 'clut-set', '10-20-dense')
% 
% Inputs:
% importpath: A string which specifies the directory containing the EEG datasets
% to be re-referenced
% 
% exportpath: A string which specifies the directory in which to save the EEG
% datasets which have had clusters added
%
% preset_cluster: A string which allows the user to specify one of the preset
% clusters. Current options: '10-20-dense', '10-20-sparse', or 'custom'
%
% cluster: A cell which contains a list of channels with which to construct a
% cluster. preset_cluster must be set to 'custom'

function cl_clusters(importpath, exportpath, preset_cluster, cluster)

% ------------------------------------------------- %
% Check user input for options regarding clustering %
% ------------------------------------------------- %
if strcmp(preset_cluster, '10-20-dense')

    cluster(1).name = 'frontal';
    cluster(1).electrodes = {'A01','A02','A03','A04','A05','A07','A08','B01',...
                             'B02','B03','B05','B06'};
    cluster(2).name = 'ltemporal';
    cluster(2).electrodes = {'A10','A11','A17','A18','A21','A22','A27'};
    cluster(3).name = 'central';
    cluster(3).electrodes = {'A06','A12','A13','A14','A15','A16','A23','A24',...
                             'A25','B04','B10','B11','B12','B19','B20','B21',...
                             'B22','B28'};
    cluster(4).name = 'rtemporal';
    cluster(4).electrodes = {'B08','B09','B13','B14','B17','B18','B24'};
    cluster(5).name = 'occipital';
    cluster(5).electrodes = {'A26','A29','A30','A31','B23','B26','B27','B29','B30'};

elseif strcmp(preset_cluster, '10-20-sparse')

    cluster(1).name = 'frontal';
    cluster(1).electrodes = {'A01','A02','A07','A08','B01'};
    cluster(2).name = 'ltemporal';
    cluster(2).electrodes = {'A10','A27'};
    cluster(3).name = 'central';
    cluster(3).electrodes = {'A06','A15','A16','B04','B28'};
    cluster(4).name = 'rtemporal';
    cluster(4).electrodes = {'B08','B14','B24'};
    cluster(5).name = 'occipital';
    cluster(5).electrodes = {'A26','A29','A31','B23','B26','B30'};

elseif strcmp(preset_cluster, 'custom')
    if ~exist('cluster', 'var')
        error('Custom clusters were not defined.');
    end
end

files = dir(fullfile(strcat(importpath, '/*.set')));
for i = 1:numel(files)

    EEG = pop_loadset(files(i).name, importpath);
    
    % Add clusters to the bottom of the EEG    
    for j = 1:numel(cluster)

        % Add empty channel to the bottom of EEG.data; update EEG structure info
        EEG.data(end+1, :) = 0;
        EEG.nbchan = size(EEG.data, 1);
        EEG.chanlocs(end+1).labels = cluster(j).name;
        % Calculate mean of this cluster's electrodes
        for ch = 1:numel(cluster(j).electrodes)
            ch_name = cluster(j).electrodes{ch};
            EEG.data(end, :) = EEG.data(end, :) + EEG.data(chindex(EEG.chanlocs, ch_name), :);
        end
        EEG.data(end, :) = EEG.data(end, :) / numel(cluster(j).electrodes);
    end

    % Save resulting EEG structure
    pop_saveset(EEG, 'filename', files(i).name(1:end-4), 'filepath', exportpath, 'savemode', 'onefile');
end
end
