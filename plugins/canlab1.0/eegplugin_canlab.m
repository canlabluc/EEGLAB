function eegplugin_canlab( fig, try_strings, catch_strings )
% This plugin manages CANLab's processing scripts for importing, filtering,
% and manipulating datasets.
%
%   cl_importcnt: Imports directory full of .cnt files into EEGLAB.
%   cl_bandpassfilter: Applies 0.5 - 45 Hz filter to a directory of datasets.
%   cl_nbtfilenames: Converts directory of datasets to NBT nomenclature
%   cl_selectchannels: Allows user to exclude specific channels
%   cl_alpha3alpha2: Calculates the IAF, TF, alpha3/alpha2 ratio for grand average
%   cl_alphatheta: Calculates alpha/theta ratio for C3 and O1 electrodes
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
if ~exist('cl_alpha3alpha2', 'file')
    p = which('cl_alpha3alpha2.m');
    p = p(1:strfind(p,'cl_alpha3alpha2.m')-1);
    addpath( p );
end;
if ~exist('cl_alphatheta', 'file')
    p = which('cl_alphatheta.m');
    p = p(1:strfind(p,'cl_alphatheta.m')-1);
    addpath( p );
end;

% find import data menu
% ---------------------
menuImportCNT      = findobj(fig, 'tag', 'import data');
menuBandpass       = findobj(fig, 'tag', 'tools');
menuNBTFilenames   = findobj(fig, 'tag', 'tools');
menuSelectChannels = findobj(fig, 'tag', 'tools');
menuAlpha3Alpha2   = findobj(fig, 'tag', 'tools');
menuAlphaTheta     = findobj(fig, 'tag', 'tools');

% menu callbacks (so that they show up in EEGLAB's interface)
% --------------
uimenu( menuImportCNT,     'label', 'CANLAB: Import multiple .cnt files', 'callback', 'cl_importcnt');
uimenu( menuBandpass,      'label', 'CANLAB: Batched bandpass filter', 'callback', 'cl_bandpassfilter');
uimenu( menuSelectChannels,'label', 'CANLAB: Batched exclusion of channels', 'callback', 'cl_selectchannels');
uimenu( menuNBTFilenames,  'label', 'CANLAB: Convert files to NBT nomenclature', 'callback', 'cl_nbtfilenames');
uimenu( menuAlpha3Alpha2,  'label', 'CANLAB: Compute Alpha3/Alpha2 ratio', 'callback', 'cl_alpha3alpha2');
uimenu( menuAlphaTheta,    'label', 'CANLAB: Compute Alpha/Theta ratio', 'callback', 'cl_alphatheta');
end