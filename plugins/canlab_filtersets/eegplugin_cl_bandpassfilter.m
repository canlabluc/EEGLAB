function eegplugin_cl_bandpassfilter( fig, try_strings, catch_strings )
% This plugin utilizes pop_eegfiltnew to apply a bandpass filter of .5 - 45
% Hz to .set files in a folder specified by the user. The datasets are then
% written to a separate folder also specified by the user, with a "filt"
% suffix added to the name of the file. 

% add folder to path
% ------------------
if ~exist('cl_bandpassfilter')
    p = which('eegplugin_cl_bandpassfilter.m');
    p = p(1:strfind(p,'eegplugin_cl_bandpassfilter.m')-1);
    addpath( p );
end;

% find import data menu
% ---------------------
menu = findobj(fig, 'tag', 'tools');

% menu callbacks
% --------------
uimenu( menu, 'label', 'CANLAB: Batched bandpass filter', 'callback', 'cl_bandpassfilter');
end