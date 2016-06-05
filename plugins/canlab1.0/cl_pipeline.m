% Runs through the entire pipeline.
%
% Usage:
%  >>> cl_pipeline(importpath, exportpath, params)
%  >>> cl_pipeline('~/data/raw_set', '~/sample_project/results/', params)
%
% Inputs:
% importpath: A string which specifies the directory containing either .cnt or
%             .set files that are to be imported. Specify whether the imported
%             files are in .cnt or .set form through params.cntImport
%
% exportpath: A string which specifies the directory containing the .set files
%             that are to be saved for further analysis
%
% params: A struct that contains the parameters necessary to run the pipeline.
%         
% The struct looks like:
%
%      analysis: string, either 'cl_alpha3alpha2' or 'cl_alphatheta'
%     cntimport: boolean, specifies whether we're importing cnt (true) or set files (false)
%    samplerate: scalar, specifies the sampling rate for the imported EEG files
%     lowerfreq: scalar, lower limit of the digital bandpass filter
%    higherfreq: scalar, upper limit of the digital bandpass filter
%   chexclusion: string, specifies desired montage. 'extClinicalCh' or 'stdClinicalCh'. See cl_excludechannels
%     reference: string, specifies desired reference. Only option currently available is the Common Average; 'CAR'
% rejectBadFits: boolean, see either cl_alpha3alpha2 or cl_alphatheta and cl_correctBadFits
%        guiFit: boolean, see either cl_alpha3alpha2 or cl_alphatheta and cl_correctBadFits
%
% Outputs:
% subj: An array of structures, one for each subject that is processed. The
%       structure contains all of the results of the analysis.

function subj = cl_pipeline(importpath, exportpath, params)

% Check that importpath, exportpath, and params.analysis are valid
if (~exist('importpath', 'var')) || strcmp(importpath, '')
  importpath = uigetdir('~', 'Select folder to import .cnt / .set files from');
  if importpath == 0
    error('Error: Please specify the folder that contains the .cnt files.');
  end
  fprintf('Import path: %s\n', importpath);
end
if (~exist('exportpath', 'var')) || strcmp(exportpath, '')
  exportpath = uigetdir('~', 'Select folder to export .set files and results to');
  if exportpath == 0
    error('Error: Please specify the folder to export the .set files to.');
  end
  fprintf('Export path: %s\n', exportpath);
end
if (~isfield(params, 'analysis')) && (strcmp(params.analysis, 'cl_alpha3alpha2') || strcmp(params.analysis, 'cl_alphatheta'))
  error('Error: params.analysis not specified or incorrect');
end

% Check that all parameters have been specified
if ~isfield(params, 'cntimport'),     error('params.cntimport not specified'),     end
if ~isfield(params, 'samplerate'),    error('params.samplerate not specified'),    end
if ~isfield(params, 'lowerfreq'),     error('params.lowerfreq not specified'),     end
if ~isfield(params, 'higherfreq'),    error('params.higherfreq not specified'),    end
if ~isfield(params, 'chexclusion'),   error('params.chexclusion not specified'),   end
if ~isfield(params, 'reference'),     error('params.reference not specified'),     end
if ~isfield(params, 'rejectBadFits'), error('params.rejectBadFits not specified'), end
if ~isfield(params, 'guiFit'),        error('params.guiFit not specified'),        end

% Write parameters to text file
fileID = fopen(strcat(export, '/cl_pipeline-parameters-', date, '.txt'), 'w');
fprintf(fileID, 'Import path: %s\n', importpath)
fprintf(fileID, 'Export path: %s\n', exportpath)
fprintf(fileID, 'Parameters:\n%s', evalc('disp(params)'))
fclose(fileID)

mkdir(strcat(exportpath, '/excl-set'));
mkdir(strcat(exportpath, '/exclfilt-set'));
mkdir(strcat(exportpath, '/exclfiltCAR-set'));
mkdir(strcat(exportpath, '/exclfiltCAR-NBT-mat'));

if params.cntimport == true
  mkdir(strcat(exportpath, '/raw-set'))
  cl_importcnt(importpath, strcat(exportpath, '/raw-set'));
end
cl_excludechannels(importpath, strcat(exportpath, '/excl-set'), params.chexclusion);
cl_bandpassfilter(strcat(exportpath, '/excl-set'),      strcat(exportpath, '/exclfilt-set'),    params.lowerfreq, params.higherfreq);
cl_rereference(strcat(exportpath, '/exclfilt-set'),     strcat(exportpath, '/exclfiltCAR-set'), params.reference);
cl_nbtfilenames(strcat(exportpath, '/exclfiltCAR-set'), strcat(exportpath, '/exclfiltCAR-NBT-mat'));
if strcmp(params.analysis, 'cl_alpha3alpha2')
    subj = cl_alpha3alpha2(strcat(exportpath, '/exclfiltCAR-NBT-mat'), exportpath, params.rejectBadFits, params.guiFit);
else
    subj = cl_alphatheta(strcat(exportpath, '/exclfiltCAR-NBT-mat'),   exportpath, params.rejectBadFits, params.guiFit);
end
