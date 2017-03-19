% Preprocessing script for the original sensor-level data, for
% computing spectral slopes. Prior to running, change the parameters
% below.
%
% Usage:
%   >> cl_preprocessingoriginal
%
% Parameters:
% importpath_set: String, specifies the absolute path to the .set files which
%                         contain the original, 66-channel full recordings.
%
% importpath_evt: String, specifies the absolute path to the .evt files which
%                         contain EMSE-exported event-related information, such
%                         as clean segments in the data.
%
% exportpath_set: String, specifies the absolute path to the .set files produced
%                         at the end of the preprocessing pipeline.
%
% exportpath_mat: String, specifies the absolute path to the .mat files produced
%                         at the end of the preprocessing pipeline, for importing
%                         into Python.
%
% montage: String, specifies the montage to use. Options:
%                   'stdClinicalCh': Exclude all channels except those that make
%                                    up the Standard Clinical Montage (19 channels)
%                   'extClinicalCh': Exclude only the following channels: electrodes
%                                    that monitor eye activity, mastoid (reference
%                                    electodes), and electrodes that fall further 
%                                    down the head than what the standard clinical 
%                                    montage uses. We thus get a montage similar to
%                                    the standard clinical one -- the difference
%                                    being that this one is denser.
%
% segments: Cell of strings, specifies the events to extract from the EMSE .evt 
%                            files. For resting state, this is usually {'C', 'O'}.
%
% filter_lofreq: Scalar, specifies the lower bound of the bandpass filter.
%
% filter_hifreq: Scalar, specifies the upper bound of the bandpass filter.
%
% reference: String, specifies the reference we rereference to during preprocessing.
%                    Only supported option is currently 'CAR' for the common average.
%
% preset_cluster: String, specifies the clusters to construct from the data. Options
%                         are '10-20-dense', '10-20-sparse', or 'custom'. See
%                         cl_clusters.m for more information.
%
% custom_cluster: Array of structs, optional, use only if preset_cluster is set to
%                 'custom'. See cl_cluster.m for more information.

importpath_set = '';
importpath_evt = '';

exportpath_set = '';
exportpath_mat = '';

montage = '';
segments = {'C', 'O'};
filter_lofreq = 0.5;
filter_hifreq = 45;
reference = 'CAR';
preset_cluster = '';
custom_cluster = struct();

% Import raw cnt data
cl_importcnt(importpath_cnt, exportpath_set);

% Add event-related information to identify clean segments in data
cl_modifyeventsEMSE(exportpath_set, importpath_evt, exportpath_set, segments);

% Apply 0.5 - 45 Hz bandpass filter
cl_bandpassfilter(exportpath_set, exportpath_set, filter_lofreq, filter_hifreq);

% Re-reference data to common average
cl_rereference(exportpath_set, exportpath_set, reference);

% Construct clusters
cl_clusters(exportpath_set, exportpath_set, preset_clusters, custom_cluster);

% Convert files to .mat format for importing into Python
set_mat_converter(exportpath_set, exportpath_mat);
