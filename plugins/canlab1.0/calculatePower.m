% Calculates absolute power between specified frequencies in the power spectrum
% Spectopo returns the power spectrum density in units of 10*log10(uV^2 / Hz),
% which is why the following transformation is necessary.[1][2]
% [1]: http://sccn.ucsd.edu/pipermail/eeglablist/2015/009249.html
% [2]: http://sccn.ucsd.edu/pipermail/eeglablist/2015/009245.html
function absPower = calculatePower(PSD, Spectra, lowerFrequency, higherFrequency)
absPower = nanmean(10.^(PSD(Spectra >= lowerFrequency & Spectra <= higherFrequency)/10));