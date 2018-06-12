% Parses BESA's EVT files to produce an array of structures that contain
% segment names, start and end times, and event number in the recording,
% according to the EEGLAB method of organizing events. That is, the output
% of this function can be directly fed to EEG.event, as such:
%
%   >> EEG.event = cl_BESAevtparser(...);
%
% Usage:
%   >> events = cl_BESAevtparser(filepath, segments)
%
% Inputs:
% filepath: Path to the .evt file we're processing.
%
% segments: A MATLAB cell that contains the names of the segments we want to
%           extract.
%
% Outputs:
% events: An array of structures that match that of EEG.event. Note that
%         segments found in the EVT file get broken up into a start and end.
%         cl_evtparser appends either '1' or '2' to the end of the event, for
%         start and stop, respectively.
%
% >> cl_BESAevtparser(...);
% 1x56 struct array with fields:
%   type
%   latency
%   urevent

code_mappings = {
	

	
};


% Note that we assume that this is a consolidated file from the python scripts.
function events = cl_BESAevtparser(filepath, code_mappings)

evts = tdfread(filepath);
for i = 1:numel(evts.Latency)
    events(i).type    = evts.Trigger(i,:);
    events(i).latency = evts.Latency(i);
    events(i).urevent = i;
end
end

% Read in file and downsample latencies to 512 Hz
evts = readBESAevt(filepath);
evts(:,1) = round( evts(:,1)/10e6 ) * 512;

% Cut out events which do not contain one of the codes specified in
% code_mappings
extractable_codes = code_mappings

% Build events struct array
for i = 1 : 

