function deltaE = DeltaECalc(lab1, lab2)
deltaE = 0;
for i = 1:3
   deltaE = deltaE + (lab1(i)-lab2(i))*(lab1(i)-lab2(i)); 
end
deltaE = sqrt(deltaE);