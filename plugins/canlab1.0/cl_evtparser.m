% This script parses .evt files (exported from EMSE) to extract the eyes-closed
% and eyes-open segments in the Aging project. 

% Need to do two things:
% - Match each EVT with the subject EEG data.
% - Parse the output of xml2struct into a struct so we can place segments
%   into each subject's EEG.event array. 

function event_struct = cl_evt_parser(importpath)

% filelist = dir(fullfile(strcat(importpath, '/*.evt')))
xmlevents = xml2struct(importpath);
xmlevents = xmlevents.EMSE_Event_List.Event;
n = 1;
for i = 1:numel(xmlevents)
    if strcmp(xmlevents{i}.Name.Text, 'Clean Closed') || strcmp(xmlevents{i}.Name.Text, 'Clean Open')
        
        event_struct(n).type    = xmlevents{i}.Name.Text;
        event_struct(n).latency = str2num(xmlevents{i}.Start.Text);
        event_struct(n).urevent = n;

        n = n + 1
        event_struct(n).type    = xmlevents{i}.Name.Text;
        event_struct(n).latency = str2num(xmlevents{i}.Stop.Text);
        event_struct(n).urevent = n;

    end
end
