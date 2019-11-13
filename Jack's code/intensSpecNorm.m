function normalizedSpectrum = intensSpecNorm(spectrum, maxIntensity)
sz = size(spectrum);
normalizedSpectrum = zeros(sz);
max = -1;
for i = 1:sz(3)
    if spectrum(1,1,i) > max
        max = spectrum(1,1,i);
    end
end
factor = maxIntensity/max;
for i = 1:sz(3)
     normalizedSpectrum(1,1,i) = spectrum(1,1,i)*factor;
end