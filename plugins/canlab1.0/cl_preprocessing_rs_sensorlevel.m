% Preprocessing script for the resting-state sensor-level data, for
% computing spectral slopes. Prior to running, change the parameters
% below. Note that event-related information is handled after
% preprocessing, in Python.
%
% Usage:
%   >> cl_preprocessingoriginal
%
% Parameters:
% importpath_cnt: String, specifies the absolute path to the .cnt files which
%                         contain the raw, unprocessed recordings.
%
% exportpath_set: String, specifies the absolute path to the .set files produced
%                         at the end of the preprocessing pipeline.
%
% exportpath_mat: String, specifies the absolute path to the .mat files produced
%                         at the end of the preprocessing pipeline, for importing
%                         into Python.
%
% montage: String, specifies the montage to use. Options:
%               '':              Only exclude eye channels (EXG1, EXG2).
%               'stdClinicalCh': Exclude all channels except those that make
%                                up the Standard Clinical Montage (19 channels)
%               'extClinicalCh': Exclude only the following channels: electrodes
%                                that monitor eye activity, mastoid (reference
%                                electodes), and electrodes that fall further 
%                                down the head than what the standard clinical 
%                                montage uses. We thus get a montage similar to
%                                the standard clinical one -- the difference
%                                being that this one is denser.
%
% filter_lofreq: Scalar, specifies the lower bound of the bandpass filter.
%
% filter_hifreq: Scalar, specifies the upper bound of the bandpass filter.
%
% reference: String, specifies the reference we rereference to during preprocessing.
%                    Only supported option is currently 'CAR' for the common average.
%
% preset_clusters: String, specifies the clusters to construct from the data. Options
%                         are '10-20-dense', '10-20-sparse', or 'custom'. See
%                         cl_clusters.m for more information.
%
% custom_cluster: Array of structs, optional, use only if preset_cluster is set to
%                 'custom'. See cl_cluster.m for more information.

%% Parameters

importpath_cnt = '';

exportpath_set = '';
exportpath_mat = '';

montage = '';
filter_lofreq = 0.5;
filter_hifreq = 45;
reference = 'CAR';
preset_clusters = '10-20-dense';
custom_clusters = struct();

%% Script

% Import raw cnt data
cl_importcnt(importpath_cnt, exportpath_set);

% Modify recording montage
if ~strcmp(montage, '')
    cl_montage(exportpath_set, exportpath_set, montage);
end

% Apply 0.5 - 45 Hz bandpass filter
cl_bandpassfilter(exportpath_set, exportpath_set, filter_lofreq, filter_hifreq);

% Re-reference data to common average
cl_rereference(exportpath_set, exportpath_set, reference);

% Construct clusters
if ~strcmp(preset_clusters, '')
    cl_clusters(exportpath_set, exportpath_set, preset_clusters, custom_clusters);
end

% Convert files to .mat format for importing into Python
set_mat_converter(exportpath_set, exportpath_mat);
