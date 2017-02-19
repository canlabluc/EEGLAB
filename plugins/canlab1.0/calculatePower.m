% Calculates absolute power between specified frequencies in the power spectrum.
%
% Usage:
%   >> power = calculatePower(PSD, frequencies, lowerFrequency, upperFrequency);
%
% Inputs:
% PSD: A 1xN vector representing the power spectral density.
%
% frequencies: A 1xN vector representing the corresponding frequencies
%              of the PSD.
%
% lowerFrequency: A scalar value specifying the lower frequency of the band
%                 from which to calculate power.
%
% upperFrequency: A scalar value specifying the upper frequency of the band
%                 from which to calculate power.
%
% For example, computing the absolute alpha power in a single channel is done
% like so:
% 
%   >> [PSD, Freqs] = spectopo(EEG.data(1,:), 0, 512, 'plot', 'off');
%   >> alphaPower = calculatePower(PSD, Freqs, 8, 13);
%
% Notes:
% Spectopo returns the power spectrum density in units of 10*log10(uV^2 / Hz),
% which is why the 10.^ transformation is necessary.[1][2]
% [1]: http://sccn.ucsd.edu/pipermail/eeglablist/2015/009249.html
% [2]: http://sccn.ucsd.edu/pipermail/eeglablist/2015/009245.html
function power = calculatePower(PSD, frequencies, lowerFrequency, upperFrequency)
power = nanmean(10.^(PSD(frequencies >= lowerFrequency & frequencies <= upperFrequency)/10));
end
