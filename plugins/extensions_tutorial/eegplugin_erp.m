function eegplugin_erp( fig, try_strings, catch_strings );
% Testing EEGLAB's extension integration service. From EEGLAB's
% tutorial (http://sccn.ucsd.edu/wiki/A07:_Contributing_to_EEGLAB#How_to_write_an_EEGLAB_extension).
%   This extension plots the ERP trial average at every channel in a
%   different color. 

% Create menu
plotmenu = findobj(fig, 'tag', 'plot');
uimenu( plotmenu, 'label', 'Plot ERP', 'callback', 'figure; plot(EEG.times, mean(EEG.data,3));');
end
