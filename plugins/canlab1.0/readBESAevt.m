function evt = readBESAevt(filename)
% READBESAEVT reads events from a BESA EVT-file. 
%
% Parameters:
%     [filename]
%         In the case that the current folder is not the folder containing 
%         the file it should be the full path including the name of the 
%         evt file else only the name of the file should be specified. 
% 
% Return:
%     [evt] 
%         A matrix containing the events from the file. The size is
%         [NumberEvents x 3], where for every event three values are
%         available: event time, event code, trigger number.
% 
% Copyright (C) 2015, BESA GmbH
%
% File name: readBESAevt.m
%
% Author: Todor Jordanov
% Created: 2015-11-20

evt = [];

fp = fopen(filename, 'r');

% MATLAB reserves file identifiers 0, 1, and 2 for standard input,  
% standard output (the screen), and standard error, respectively. When 
% fopen successfully opens a file, it returns a file identifier greater 
% than or equal to 3.
if(fp >= 3)
    
    % Get the first line of the file. It looks something like that:
    % Tmu         	Code	TriNo	Comnt
    FirstLine = fgetl(fp);
    
    LineCounter = 1;
    
    while(true)
        
        CurrentLine = fgetl(fp);
        % Check if end of file.
        if(~ischar(CurrentLine))
            
            break;
            
        end
        
        evt(LineCounter, :) = sscanf(CurrentLine, '%d', 3);
        LineCounter = LineCounter + 1;
        
    end
    
    fclose(fp);
    
else
    
    evt = [];
    disp('Error! Invalid file identifier.')
    
end