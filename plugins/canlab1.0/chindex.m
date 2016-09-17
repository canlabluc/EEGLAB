% Auxilliary function; returns index of specified channel
%
% Usage:
%	>> idx = chindex(chanlocs, chan);
% 	>> idx = chindex(EEG.chanlocs, 'A01');
%

function index = chindex(chanlocs, chan)

index = -1;
for i = 1:numel(chanlocs)
    if strcmp(sprintf(chanlocs(i).labels), chan)
        index = i;
        break;
    end
end
if index == -1
	error('Channel not found in chanlocs.');
end
end