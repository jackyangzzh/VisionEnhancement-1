function deltaI = DeltaICalc(spec1, spec2)
% spectrum length should be 204
deltaI = 0;
sz = size(spec1);
for i = 1:sz(2)
   deltaI = deltaI + abs(spec1(i)- spec2(i)); 
end
