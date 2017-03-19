% Parses EMSE's EVT files to produce an array of structures that contain
% segment names, start and end times, and event number in the recording,
% according to the EEGLAB method of organizing events. That is, the output
% of this function can be directly fed to EEG.event, as such:
%
%   >> EEG.event = cl_evtparser(...);
%
% Usage:
%   >> events = cl_evtparser(filepath, segments)
%   >> events = cl_evtparser('subject101.evt', {'Clean Closed', 'Clean Open'})
% 
% Inputs:
% filepath: Path to the .evt file we're processing.
% 
% use_segs: Boolean specifying whether to only extract segments in the recording
%           marked off in the recording by strings passed in the next parameter.
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
% >> cl_evtparser(...);
% 1x56 struct array with fields:
%   type
%   latency
%   urevent

function events = cl_EMSEevtparser(filepath, use_segs, segments)
    xmlevents = xml2struct(filepath);
    xmlevents = xmlevents.EMSE_Event_List.Event;

    n = 1; 
    for i = 1:numel(xmlevents)
        if use_segs == true
            for j = 1:numel(segments)
                if strcmp(xmlevents{i}.Name.Text, segments{j})
                    events(n).type    = strcat(xmlevents{i}.Name.Text, '1');
                    events(n).latency = str2double(xmlevents{i}.Start.Text);
                    events(n).urevent = n;

                    n = n + 1;
                    events(n).type    = strcat(xmlevents{i}.Name.Text, '2');
                    events(n).latency = str2double(xmlevents{i}.Stop.Text);
                    events(n).urevent = n;
                    n = n + 1;
                end
            end
        else
            events(i).type    = strcat(xmlevents{i}.Name.Text, '1');
            events(i).latency = str2double(xmlevents{i}.Start.Text);
            events(i).urevent = i;
        end
    end
end
