function eegplugin_canlab( fig, try_strings, catch_strings )
% This plugin manages CANLab's processing scripts for importing, filtering,
% and manipulating datasets.
%
%   cl_importcnt: Imports directory full of .cnt files into EEGLAB.
%   cl_bandpassfilter: Applies 0.5 - 45 Hz filter to a directory of datasets.
%   cl_nbtfilenames: Converts directory of datasets to NBT nomenclature
%   cl_selectchannels: Allows user to exclude specific channels
%   cl_poweranalysis: Calculates the IAF, TF, and other indexes in PSD
%

% add folders to path
% ------------------
if ~exist('cl_importcnt.m', 'file')
    p = which('cl_importcnt.m');
    p = p(1:strfind(p,'cl_importcnt.m')-1);
    addpath( p );
end;
if ~exist('cl_bandpassfilter.m', 'file')
    p = which('cl_bandpassfilter.m');
    p = p(1:strfind(p,'cl_bandpassfilter.m')-1);
    addpath( p );
end;
if ~exist('cl_nbtfilenames', 'file')
    p = which('cl_nbtfilenames.m');
    p = p(1:strfind(p,'cl_nbtfilenames.m')-1);
    addpath( p );
end;
if ~exist('cl_selectchannels', 'file')
    p = which('cl_selectchannels.m');
    p = p(1:strfind(p,'cl_selectchannels.m')-1);
    addpath( p );
end;
if ~exist('cl_poweranalysis', 'file')
    p = which('cl_poweranalysis.m');
    p = p(1:strfind(p,'poweranalysis.m')-1);
    addpath( p );
end;

% find import data menu
% ---------------------
menuImportCNT      = findobj(fig, 'tag', 'import data');
menuBandpass       = findobj(fig, 'tag', 'tools');
menuNBTFilenames   = findobj(fig, 'tag', 'tools');
menuSelectChannels = findobj(fig, 'tag', 'tools');
menuPowerAnalysis  = findobj(fig, 'tag', 'tools');

% menu callbacks (so that they show up in EEGLAB's interface)
% --------------
uimenu( menuImportCNT,     'label', 'CANLab: Import multiple .cnt files', 'callback', 'cl_importcnt');
uimenu( menuBandpass,      'label', 'CANLab: Batched bandpass filter', 'callback', 'cl_bandpassfilter');
uimenu( menuNBTFilenames,  'label', 'CANLab: Convert files to NBT nomenclature', 'callback', 'cl_nbtfilenames');
uimenu( menuSelectChannels,'label', 'CANLab: Batched exclusion of channels', 'callback', 'cl_selectchannels');
uimenu( menuPowerAnalysis, 'label', 'CANLAB: Run power analysis', 'callback', 'cl_poweranalysis');
end