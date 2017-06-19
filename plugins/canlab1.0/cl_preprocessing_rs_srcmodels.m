% Preprocessing script for the resting-state source models. 
% This script contains the preprocessing pipeline for the 
% BESA-exported source models we use to compute spectral slopes.
% Prior to running, change the parameters below.
%
% Usage:
%   >> cl_preprocessingsrcmodelsrs_srcmodels
%
% Parameters:
% importpath_mul: String, specifies the absolute path to the .mul source model
%                         files.
%
% importpath_set: String, specifies the absolute path to the .set files which
%                         contain the original, 66-channel full recordings.
%
% exportpath_set: String, specifies the absolute path to the .set files produced
%                         at the end of the preprocessing pipeline.
%
% exportpath_mat: String, specifies the absolute path to the .mat files produced
%                         at the end of the preprocessing pipeline, for importing
%                         into Python.
%
% montage: String, specifies the source model we're preprocessing. Options:
%               'dmn': For preprocessing the Default Mode Network souce model.
%               'frontal': For preprocessing the frontal source model.
%               'dorsal': For preprocessing the dorsal source model.
%               'ventral': For preprocessing the ventral source model.
%
% filter_lofreq: Scalar, specifies the lower bound of the bandpass filter.
%
% filter_hifreq: Scalar, specifies the upper bound of the bandpass filter.
%
% reference: String, specifies the reference we rereference to during preprocessing.
%                    Only supported option is currently 'CAR' for the common average.
%

importpath_mul = '';
importpath_set = '';

exportpath_set = '';
exportpath_mat = '';

montage = '';
filter_lofreq = 0.5;
filter_hifreq = 45;
reference = 'CAR';

% Import raw data; compute channel magnitudes from components
cl_importmul(importpath_mul, importpath_set, exportpath_set, montage);

% Apply 0.5 - 45 Hz bandpass filter
cl_bandpassfilter(exportpath_set, exportpath_set, filter_lofreq, filter_hifreq);

% Re-reference data to common average
cl_rereference(exportpath_set, exportpath_set, reference);

% Convert files to .mat format for importing into Python
set_mat_converter(exportpath_set, exportpath_mat);
