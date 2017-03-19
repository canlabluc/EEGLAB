function x = cl_getEventInformation(importpath_evt)
    files = dir(fullfile(strcat(importpath_evt, '*.evt')));
    
    for i = 1:numel(files)
        xmlevents = xml2struct(files(i).name);
        xmlevents = xmlevents.EMSE_Event_List.Event;
        % Organize events into an array of structures
        n = 1; 
        for j = 1:numel(xmlevents)
            events(n).type    = xmlevents{j}.Name.Text;
            events(n).latency = str2double(xmlevents{j}.Start.Text);
            events(n).urevent = n;
            n = n + 1;
            events(n).type    = xmlevents{j}.Name.Text;
            events(n).latency = str2double(xmlevents{j}.Stop.Text);
            events(n).urevent = n;
            n = n + 1;
        end

        % Now remove events we're not interested in.
        idx = false(1, length(events));
        for j = 1:numel(events)
            if length(events(j).type) ~= 3 || strcmp(events(j).type, '255')
                idx(j) = true;
            end
        end
        events(idx) = [];

        eyesc_segs = 0;
        eyeso_segs = 0;
        eyesc_seg_length = 0;
        eyeso_seg_length = 0;

        for j = 1:numel(events)-1
            if strcmp(events(j).type(1:2), '10') && strcmp(events(j+1).type(1:2), '20')
                eyesc_segs = eyesc_segs + 1;
                eyesc_seg_length = eyesc_seg_length + (events(j+1).latency - events(j).latency);
            if strcmp(events(j).type(1:2), '11') && strcmp(events(j+1).type(1:2), '21')
                eyeso_segs = eyeso_segs + 1;
                eyeso_seg_length = eyeso_seg_length + (events(j+1).latency - events(j).latency);
            end
            eyesc_seg_length = eyesc_seg_length / eyesc_segs;
            eyeso_seg_length = eyeso_seg_length / eyeso_segs;
        end

        fprintf('%s | eyesc_seg_length: %d | eyeso_seg_length: %d | neyesc: %d | neyeso: %d\n',...
            files(i).name, eyesc_seg_length, eyeso_seg_length, eyesc_segs, eyeso_segs);
    end

x = 1;
end