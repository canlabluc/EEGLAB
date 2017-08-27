# CAN Lab's EEGLAB plugin
The cl plugin primarily acts as a data pre-processing tool. Generally we use it for any of the following: EEG bandpass filtering, re-referencing, resampling, specifying montages, channel cluster construction, and exporting to Python-readable files (much of our analyses are done in Python). For any given step in preprocessing, the plugin generally reads a set of files, performs that step (such as bandpass filtering), and writes the modified data back onto the disk. As such, most of the functions in this folder look like so:

```matlab
function cl_somefunction(importpath, exportpath, param1, param2,...)
...
```

Where `importpath` specifies the directory path to the files that need to be processed by `cl_somefunction`, `exportpath` specifies the path to the directory into which we'll write the processed files, and `param1`, `param2`, and so on specify function-specific arguments. In the case of a function like `cl_bandpassfilter`, these would be the parameters that specify the lower and upper frequencies of the bandpass filter.

However, there are still two analyses one can run without having to export to Python. These are specified in `cl_alpha3alpha2.m` and `cl_alphatheta.m`, and were originally what the canlab plugin was written for. For instructions on running these analyses, see the `Alpha Ratios Walkthrough.md` file, located in this directory.

# General Pipeline for Preprocessing
While preprocessing can be done step by step in MATLAB's command window, doing so usually slows us down, and it's often difficult to remember precisely which functions were run with which parameters. Thus, when writing up a new analysis, it's always a good idea to create a new preprocessing script specific for that analysis. Any one of the existing `cl_preprocessing_` files in this directory can serve as examples for this.

Once preprocessed, analysis continues using the [PSD slope-fitting code](https://github.com/canlabluc/psd-slope-rs-gng).

# Current Preprocessing Scripts
The preprocessing scripts that are currently available are:
- `cl_preprocessing_gng_sensorlevel.m`: Handles sensor-level EEG data for the Go-NoGo task. Subjects are from Study 120/132 (older adults) and 120/113 (younger adults).
- `cl_preprocessing_rs_sensorlevel.m`: Handles sensor-level EEG data for the resting-state paradigm. Subjects are from Study 120/127 (older adults) and 120/118 (younger adults).
- `cl_preprocessing_rs_srcmodels.m`: Handles source modeled EEG data for the resting-state paradigm. Same subjects as above (120/127, 120/118).
