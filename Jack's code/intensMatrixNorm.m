function normalizedMatrix = intensMatrixNorm(spectrumMatrix, maxIntensity)
%needs function intensSpecNorm
sz = size(spectrumMatrix);
normalizedMatrix = zeros(sz);
for i=1:sz(1)
   for j=1:sz(2)
       normalizedMatrix(i,j,:) = intensSpecNorm(spectrumMatrix(i,j,:),maxIntensity);
   end
end
