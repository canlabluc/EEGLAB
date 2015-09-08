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
% i:        Subject index within cl_alpha3alpha2 or cl_alphatheta
% 
% j:        Channel index within cl_alpha3alpha2 or cl_alphatheta
% 
% rejectBadFits: SET BY CL_ALPHATHETA OR CL_ALPHA3ALPHA2.
% 
% guiFit:        SET BY CL_ALPHATHETA OR CL_ALPHA3ALPHA2. 

function subj = cl_correctBadFits(subj, measure,i, j, rejectBadFits, guiFit)

fprintf('ERROR: %s calculated by NBT: %d\n', measure, channelPeakObj.IAF);
fprintf('Fitting polynomial in order to recalculate %s...\n', measure);
if measure == 'IAF'
    subj(i).inspectedIAFs(j) = j;
else
    subj(i).inspectedTFs(j) = j;
end
[spectra, freqs] = spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16], 'plot', 'off');
ws = warning('off', 'all');           
p  = polyfit(freqs', spectra, 15);
warning(ws);
y1 = polyval(p, freqs');
if measure == 'IAF'
    [dummy, ind] = max(y1(find(freqs > 7):find(freqs > 13, 1)));
    if freqs(ind) > 12.9 || freqs(ind) < 7
        if guiFit == true
            disp('IAF is too low or too high. Confirm by clicking: ');
            spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16]);
            [x, y] = ginput(1);
            subj(i).IAFs(j) = x;
            close(2);
        elseif rejectBadFits == true
            disp('IAF is too low or too high. Rejecting calculated IAF.');
            subj(i).rejectedIAFs = [subj(i).rejectedIAFs, j];
        else
            disp('IAF is too low or too high. Choosing IAF = 9 Hz');
            subj(i).IAFs(j) = 9;
        end
    else
        % Polynomial-derived IAF is reasonable
        subj(i).IAFs(j) = freqs(ind);
    end
else % measure == 'TF'
    [dummy, ind] = min(y1(1:find(freqs > 7.5, 1)));
    if freqs(ind) > 6.9 || freqs(ind) < 3
        if guiFit == true
            disp('TF is too low or too high. Confirm by clicking: ');
            spectopo(Signal(:,j)', 0, SignalInfo.converted_sample_frequency, 'freqrange', [0 16]);
            [x, y] = ginput(1);
            subj(i).TFs(j) = x;
            close(2);
        elseif rejectBadFits == true
            disp('TF is too low or too high. Rejecting calculated TF.');
            subj(i).rejectedTFs = [subj(i).rejectedTFs, j];
        else
            disp('TF is too low or too high. Choosing TF = 4.5 Hz');
            subj(i).TFs(j) = 4.5;
        end
    else
        % Polynomial-derived TF is reasonable
        subj(i).TFs(j) = freqs(ind);
    end
end
end