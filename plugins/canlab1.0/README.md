# CAN Lab's EEGLAB plugin
The cl plugin was developed in order to perform two main analyses. Their implementations and corresponding papers:

| Algorithm Implementation | Paper |
| -------------------------|-------|
| [`cl_alpha3alpha2.m`](https://github.com/canlabluc/EEGLAB/blob/master/plugins/canlab1.0/cl_alpha3alpha2.m) | [Schmidt et al. (2013)](https://www.researchgate.net/profile/Antonio_Nardi/publication/257839823_Index_of_AlphaTheta_Ratio_of_the_Electroencephalogram_A_New_Marker_for_Alzheimers_Disease/links/004635314bb865df72000000.pdf) |
| [`cl_alphatheta.m`](https://github.com/canlabluc/EEGLAB/blob/master/plugins/canlab1.0/cl_alphatheta.m) | [Moretti et al. (2013)](http://www.frontiersin.org/Journal/DownloadFile.ashx?pdf=1&FileId=34165&articleId=65285&ContentTypeId=21&FileName=fnagi-05-00063.pdf&Version=1) |

# General Pipeline
The general pipeline for performing both analyses is shown below. Supposing that we start off with some unprocessed cnt files:

1. Import .cnt files and convert them to .set files for use in MATLAB.
```matlab
>> cl_importcnt('~/data/2015-05-01/raw_cnt_files/', '~/sample_project/raw_set_files/')
```

2. Exclude channels. Currently there are two options: 'stdClinicalCh' and 'extClinicalCh'. See `cl_excludechannels.m` for more detail.
```matlab
>> cl_excludechannels('~/sample_project/raw_set_files', '~/sample_project/excl_set/', 'stdClinicalCh')
```

3. Apply a digital bandpass filter. We'll bandpass from 0.5 Hz to 45 Hz.
```matlab
>> cl_bandpassfilter('~/sample_project/excl_set', '~/sample_project/exclfilt_set', 0.5, 45)
```

4. Re-reference the data to the common average.
```matlab
>> cl_rereference('~/sample_project/exclfilt_set', '~/sample_project/exclfiltCAR_set')
```

5. Convert file names to NBT nomenclature, so that we can utilize NBT's `nbt_doPeakFit` algorithm. This allows us to calculate individualized alpha and theta frequencies, as described in Moretti et al. (2013).
```matlab
>> cl_nbtfilenames('~/sample_project/exclfiltCAR_set', '~/sample_project/exclfiltCAR-NBT_mat')
```

6. Now we perform the analysis, running either `cl_alphatheta` or `cl_alpha3alpha2`. Both will output a CSV to the specified export folder.
```matlab
>> cl_alpha3alpha2('~/sample_project/exclfiltCAR-NBT_mat', '~/sample_project/results/', rejectBadFits=false, guiFit=false)
```

`rejectBadFits`
  - If set to true, subjects for whom `nbt_doPeakFit` returned bad values will simply not be assigned an IAF / TF.
  - If set to false, a subject with a bad IAF value will have the value corrected to a 9. Bad TF values are corrected to 4.5.

`guiFit`
  - If set to true, you will be asked to visually select the IAF and TF for subjects where `nbt_doPeakFit` returned bad values.
  - If set to false, the program will default to whatever `rejectBadFits` is set to.
