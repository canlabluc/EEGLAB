% Handles recalculation of IAF, TF through fitting 15th degree polynomials onto
% power spectrum. Local minimum in the 0 - 7 Hz range is chosen as the TF, and 
% the local maximum in the 7 - 13 Hz range is chosen as the maximum. 
% NOTE: This function is used specfically for cl_alpha3alpha2 and cl_alphatheta
% 
% Usage:
%   This function is utilized by cl_alpha3alpha2 and cl_alphatheta.
%   
% Inputs:
% subj:     The subject structure present throughout analysis functions in 
%           canlab.
% 
% measure:  Determines which measure we're re-evaluating.
%           Options:
%               'TF': Transition Frequency
%               'IAF': Individualized Alpha Frequency
% 
% i: Subject index within cl_alpha3alpha2 or cl_alphatheta
% 
% j: Channel index within cl_alpha3alpha2 or cl_alphatheta
% 
% rejectBadFits: SET BY CL_ALPHATHETA OR CL_ALPHA3ALPHA2.
% 
% guiFit:        SET BY CL_ALPHATHETA OR CL_ALPHA3ALPHA2. 

function subj = cl_correctBadFits(subj, channelPeakObj, Signal, i, j, rejectBadFits, guiFit)

if strcmp(subj(i).misc.measure, 'IAF') == 1
    subj(i).misc.inspectedIAFs(j) = j;
    fprintf('ERROR: %s calculated by NBT: %d\n', subj(i).misc.measure, channelPeakObj.IAF);
    fprintf('Fitting polynomial in order to recalculate %s...\n', subj(i).misc.measure);
else
    subj(i).misc.inspectedTFs(j) = j;
    fprintf('ERROR: %s calculated by NBT: %d\n', subj(i).misc.measure, channelPeakObj.TF);
    fprintf('Fitting polynomial in order to recalculate %s...\n', subj(i).misc.measure);
end
[spectra, freqs] = spectopo(Signal(:,j)', 0, 512, 'freqrange', [0 16], 'plot', 'off');
ws = warning('off', 'all');           
p  = polyfit(freqs', spectra, 15);
warning(ws);
y1 = polyval(p, freqs');

% ------- %
%   IAF   %
% ------- %
if strcmp(subj(i).misc.measure, 'IAF')
    % Find max between 7 and 13
    [dummy, ind] = max(y1(find(freqs > 7):find(freqs > 13, 1)));
    if freqs(ind) > 12.9 || freqs(ind) < 7
        if guiFit == true
            disp('IAF is too low or too high. Confirm by clicking: ');
            spectopo(Signal(:,j)', 0, 512, 'freqrange', [0 16]);
            [x, y] = ginput(1);
            if strcmp(subj(i).misc.analysisType, 'C3_alphatheta')
                subj(i).C3(subj(i).chAdded).IAF = x;
            elseif strcmp(subj(i).misc.analysisType, 'O1_alphatheta')
                subj(i).O1(subj(i).chAdded).IAF = x;
            else % analysisType == cl_alpha3alpha2
                subj(i).IAFs(j) = x;   
            end
            close(2);
        elseif rejectBadFits == true
            disp('IAF is too low or too high. Rejecting calculated IAF.');
            subj(i).misc.rejectedIAFs = [subj(i).misc.rejectedIAFs, j];
        else % rejectBadFits, guiFit == false
            disp('IAF is too low or too high. Choosing IAF = 9 Hz');
            if strcmp(subj(i).misc.analysisType, 'C3_alphatheta')
                subj(i).C3(subj(i).misc.C3Added).IAF = 9;
            elseif strcmp(subj(i).misc.analysisType, 'O1_alphatheta')
                subj(i).O1(subj(i).misc.O1Added).IAF = 9;
            else
                subj(i).IAFs(j) = 9;
            end
        end
    else
        % Polynomial-derived IAF is reasonable
        if strcmp(subj(i).misc.analysisType, 'C3_alphatheta')
            subj(i).C3(subj(i).misc.C3Added).IAF = freqs(ind);
        elseif strcmp(subj.misc.analysisType, 'O1_alphatheta')
            subj(i).O1(subj(i).misc.O1Added).IAF = freqs(ind);
        else
            subj(i).IAFs(j) = freqs(ind);
        end
    end

% ------ %
%   TF   %
% ------ %
elseif strcmp(subj(i).misc.measure, 'TF')
     % Find minimum between 1 and 7.5
    [dummy, ind] = min(y1(1:find(freqs > 7.5, 1)));
    if freqs(ind) > 6.9 || freqs(ind) < 3
        if guiFit == true
            disp('TF is too low or too high. Confirm by clicking: ');
            spectopo(Signal(:,j)', 0, 512, 'freqrange', [0 16]);
            [x, y] = ginput(1);
            if strcmp(subj(i).misc.analysisType, 'C3_alphatheta')
                subj(i).C3(subj(i).misc.C3Added).TF = x;
            elseif strcmp(subj(i).misc.analysisType, 'O1_alphatheta')
                subj(i).O1(subj(i).misc.O1Added).TF = x;
            else % analysisType == cl_alpha3alpha2
                subj(i).TFs(j) = x;   
            end
            close(2);
        elseif rejectBadFits == true
            disp('TF is too low or too high. Rejecting calculated TF.');
            subj(i).misc.rejectedTFs = [subj(i).misc.rejectedTFs, j];
        else % rejectBadFits, guiFit == false
            disp('TF is too low or too high. Choosing TF = 4.5 Hz');
            if strcmp(subj(i).misc.analysisType, 'C3_alphatheta')
                subj(i).C3(subj(i).misc.C3Added).TF = 4.5;
            elseif strcmp(subj(i).misc.analysisType, 'O1_alphatheta')
                subj(i).O1(subj(i).misc.O1Added).TF = 4.5;
            else
                subj(i).TFs(j) = 4.5;
            end
        end
    else
        % Polynomial-derived TF is reasonable
        if strcmp(subj(i).misc.analysisType, 'C3_alphatheta')
            subj(i).C3(subj(i).misc.C3Added).TF = freqs(ind);
        elseif strcmp(subj(i).misc.analysisType, 'O1_alphatheta')
            subj(i).O1(subj(i).misc.O1Added).TF = freqs(ind);
        else
            subj(i).TFs(j) = freqs(ind);
        end
    end
else
    error('Please specify the measure parameter to cl_correctBadFits');
end
end
