function accumDiff = specDiffIntegrate(spec1, spec2)
%this function
Diff = 0;
sz = size(spec1);
for i = 3:sz(3)
   Diff = Diff + abs(spec1(1,1,i)-spec2(1,1,i)); 
end
accumDiff = Diff;