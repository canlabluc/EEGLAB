function eegplugin_cl_nbtfilenames( fig, try_strings, catch_strings )
% Handles cl_nbtfilenames through the EEGLAB interface
% add folder to path
% ------------------
if ~exist('pop_cl_nbtfilenames')
    p = which('eegplugin_cl_nbtfilenames.m');
    p = p(1:strfind(p,'eegplugin_cl_nbtfilenames.m')-1);
    addpath( p );
end;

% find import data menu
% ---------------------
menu = findobj(fig, 'tag', 'tools');

% menu callbacks
% --------------
uimenu( menu, 'label', 'CANLAB: Convert files to NBT nomenclature', ...
    'callback', 'cl_nbtfilenames');
end
