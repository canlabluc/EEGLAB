function eegplugin_cl_importcnt( fig, try_strings, catch_strings );
% This plugin utilizes the pop_loadcnt() function to import cnt files from
% a directory specified by the user. Each dataset is added to the ALLEEG
% object, and saved as a .set file to another directory also specified by
% the user.
% Default parameters passed to pop_loadcnt():
%   'blockread', 1
% All .cnt files are added to the ALLEEG struct array. 

% add folder to path
% ------------------
if ~exist('pop_cl_importcnt')
    p = which('eegplugin_cl_importcnt.m');
    p = p(1:strfind(p,'eegplugin_cl_importcnt.m')-1);
    addpath( p );
end;

% find import data menu
% ---------------------
menu = findobj(fig, 'tag', 'import data');

% menu callbacks
% --------------
uimenu( menu, 'label', 'CANLAB: Import multiple .cnt files', 'callback', 'cl_importcnt');
end