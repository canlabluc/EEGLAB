% Handles exclusion of EEG channels to achieve certain montages.
%
% Usage:
%   >> cl_montage(importpath, exportpath, params);
%   >> cl_montage('raw-set', 'excl-set', params);
%
% Inputs:
% importpath: A string which specifies the directory containing the EEG datasets
% with channels that are to be excluded / averaged to form clusters. 
% 
% exportpath: A string which specifies the directory containing the .set files
% that are to be saved for further analysis.
%
% montage: A string which specifies which montage to produce. Either:
%	- 'stdClinicalCh': Exclude all channels except those that make up the
%	                   Standard Clinical Montage, composed of 19 channels
%	- 'extClinicalCh': Exclude only the following channels: electrodes that
%	                   monitor eye activity, mastoid (reference electodes),
%	                   and electrodes that fall further down the head than
%	                   what the standard clinical montage uses. We thus get
%	                   a montage similar to the standard clinical one -- the
%	                   difference being that this one is denser.

function cl_montage(importpath, exportpath, montage)

% ---------------------------------------------- %
% Check user input for options regarding montage %
% ---------------------------------------------- %
if strcmp(montage, 'stdClinicalCh')
    % Electrodes to remove, for Standard Clinical Electrodes Montage
    excludedchannels = [66 65 64 63 61 59 57 54 53 52 51 50 49 48 47 45 44 43 42 41 39 38 37 35 34 32 30 28 25 24 23 22 21 20 19 18 17 14 13 12 11 9 5 4 3];
elseif strcmp(montage, 'extClinicalCh')
    % Electrodes to remove, for Extended Clinical Electrodes Montage
    excludedchannels = [9 19 20 28 32 39 47 48 57 63 64 65 66];
else % TODO: Implement ability for user to specify custom exclusion using e.g. 'A03', etc
    error('Please specify a montage');
end

% ---------------------------------------------------------- %
% Run through all files and apply montage, exclusion options %
% ---------------------------------------------------------- %
files = dir(fullfile(strcat(importpath, '/*.set')));
for i = 1:numel(files)
    EEG = pop_loadset(files(i).name, importpath);
    EEG = pop_select(EEG, 'nochannel', excludedchannels);
    pop_saveset(EEG, 'filename', files(i).name(1:end-4), 'filepath', exportpath, 'savemode', 'onefile');
end
end
