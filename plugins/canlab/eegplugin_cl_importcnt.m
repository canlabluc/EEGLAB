function eegplugin_cl_importcnt( fig, try_strings, catch_strings );
% This script utilizes the pop_loadcnt() function to import all of the cnt
% files in the current working directory using a blockread setting of 1.
% All .cnt files are added to the ALLEEG struct array. 

% Create menu
menu = findobj(fig, 'tag', 'import data');
uimenu( menu, 'label', 'CANLAB: Import multiple CNT', 'callback', 'listcnt');
end