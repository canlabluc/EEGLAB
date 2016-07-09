% Handles both exclusion and clustering of EEG channels.
%
% Usage:
%   >>> cl_montage(importpath, exportpath, params);
%   >>> cl_montage('raw-set', 'excl-set', params);
%
% Inputs:
% importpath: A string which specifies the directory containing the EEG datasets
% with channels that are to be excluded / averaged to form clusters. 
% 
% exportpath: A string which specifies the directory containing the .set files
% that are to be saved for further analysis.
%
% params: A struct that contains the parameters necessary to run cl_montage().
%         params contains the following fields:
%   montage: string, either:
%       - 'stdClinicalCh': Exclude all channels except those that make up the
%                          Standard Clinical Montage, composed of 19 channels
%       - 'extClinicalCh': Exclude only the following channels: electrodes that
%                          monitor eye activity, mastoid (reference electodes),
%                          and electrodes that fall further down the head than
%                          what the standard clinical montage uses. We thus get
%                          a montage similar to the standard clinical one -- the
%                          difference being that this one is denser.
%   preset_cluster: string, either: 
%       - 'custom':        Allows user to specify custom clusters.
%       - '10-20-dense':   Constructs 5 clusters based on the 10-20 Intl. System:
%                          frontal, left temporal, right temporal, central, and 
%                          occipital areas.
%   cluster: struct array, with the fields:
%       - name:            String, name of cluster
%       - electrodes:      Cell, contains names of electrodes to be used for
%                          computed this cluster.
% 
% As an example, acquiring files with the extended clinical montage and with the
% 10-20 system frontal, left and right temporal, central and occipital clusters
% is done as such:
%
%   >>> params.preset_cluster = '10-20-dense';
%   >>> params.montage = 'extClinicalCh';
%   >>> cl_montage('raw-set', 'excl-set', params);
%

function cl_montage(importpath, exportpath, params)

% ------------------------------------------------- %
% Check user input for options regarding clustering %
% ------------------------------------------------- %
if strcmp(params.preset_cluster, '10-20-dense')
    params.cluster(1).name = 'frontal';
    params.cluster(1).electrodes = {'A01','A02','A03','A04','A05','A07','A08','B01',...
                                    'B02','B03','B05','B06'};
    params.cluster(2).name = 'ltemporal';
    params.cluster(2).electrodes = {'A10','A11','A17','A18','A21','A22','A27'};
    params.cluster(3).name = 'central';
    params.cluster(3).electrodes = {'A06','A12','A13','A14','A15','A16','A23','A24',...
                                    'A25','B04','B10','B11','B12','B19','B20','B21',...
                                    'B22','B28'};
    params.cluster(4).name = 'rtemporal';
    params.cluster(4).electrodes = {'B08','B09','B13','B14','B17','B18','B24'};
    params.cluster(5).name = 'occipital';
    params.cluster(5).electrodes = {'A26','A29','A30','A31','B23','B26','B27','B29','B30'};
elseif strcmp(params.preset_cluster, 'custom')
    if ~isfield(params, 'cluster')
        error('Custom clusters were not defined.');
    end
else
    params.cluster = 'none';
end

% ---------------------------------------------- %
% Check user input for options regarding montage %
% ---------------------------------------------- %
if strcmp(params.montage, 'stdClinicalCh')
    % Electrodes to remove, for Standard Clinical Electrodes Montage
    params.excludedchannels = [66 65 64 63 61 59 57 54 53 52 51 50 49 48 47 45 44 43 42 41 39 38 37 35 34 32 30 28 25 24 23 22 21 20 19 18 17 14 13 12 11 9 5 4 3];
elseif strcmp(params.montage, 'extClnicalCh')
    % Electrodes to remove, for Extended Clinical Electrodes Montage
    params.excludedchannels = [9 19 20 28 32 39 47 48 57 63 64 65 66];
else % TODO: Implement ability for user to specify custom exclusion using e.g. 'A03', etc
    params.montage = NaN;
end

% ---------------------------------------------------------- %
% Run through all files and apply montage, exclusion options %
% ---------------------------------------------------------- %
files = dir(fullfile(strcat(importpath, '/*.set')));
for i = 1:numel(files)
    
    EEG = pop_loadset(files(i).name, importpath);
    
    % Add clusters to the bottom of the EEG
    if ~strcmp(params.cluster, 'none')
        for j = 1:numel(params.cluster)
            % Add empty channel to the bottom of EEG.data; update EEG structure info
            EEG.data(end+1, :) = 0;
            EEG.nbchan = size(EEG.data, 1);
            EEG.chanlocs(end+1).labels = params.cluster(j).name;

            % Calculate mean of this cluster's electrodes
            for ch = 1:numel(params.cluster(j).electrodes)
                ch_name = params.cluster(j).electrodes{ch};
                EEG.data(end, :) = EEG.data(end, :) + EEG.data(chindex(EEG.chanlocs, ch_name), :);
            end
            EEG.data(end, :) = EEG.data(end, :) / numel(params.cluster(j).electrodes);
        end
    end

    % Exclude specified channels
    if ~isnan(params.montage)
        EEG = pop_select(EEG, 'nochannel', params.excludedchannels)
    end

    % Save resulting EEG structure
    pop_saveset(EEG, 'filename', files(i).name(1:end-4), 'filepath', exportpath, 'savemode', 'onefile');
end
end
