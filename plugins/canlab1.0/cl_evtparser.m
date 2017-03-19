% Imports BESA or EMSE preprocessed evt files to produce an array of
% structures that contain event names, latencies, and event number in
% the recording, according to the EEGLAB method of organizing events.
% That is, the output of this function can be directly fed to EEG.event.
% 
% Usage:
%   >> events = cl_evtparser(filepath, segments);
%   
%   Example:
%   >> events = cl_evtparser('subject01.evt', {'C', 'O'});
%   
% Inputs:
% filepath: String, path to the .evt file we're importing.
% 
% segments: MATLAB cell, OPTIONAL, contains the names of the segments that
%           we want to extract. If we're importing 'C' or 'O' segments,
%           for example, they'd be present in the .evt file as 'C1' and
%           'C2' and 'O1' and 'O2', respectively, we'd pass the following
%           cell: {'C', 'O'}.
%           
% Outputs:
% events: Array of structures, matches that of EEG.event.
% 
% >> cl_evtparser(...);
% 1x56 struct array with fields:
%   type
%   latency
%   urevent

function events = cl_evtparser(filepath, segments)

evts = tdfread(filepath);

n = 1;
for i = 1:numel(evts.Latency)
    if exist('segments', 'var')
        for j = 1:numel(segments)
            if strcmp(evts.Type(i, 1), segments{j})
                events(n).type = evts.Type(i,:);
                events(n).latency = evts.Latency(i);
                events(n).urevent = n;
                n = n + 1;
            end
        end
    else
        events(i).type = evts.Type(i,:);
        events(i).latency = evts.Latency(i);
        events(i).urevent = i;
    end
end
