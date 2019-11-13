function output = pixelCompare(pixel1, pixel2)
deltaE = DeltaECalc(pixel1(3:5),pixel2(3:5));
deltaI = DeltaICalc(pixel1(6:209),pixel2(6:209));
output = [pixel1(1:2),pixel2(1:2),deltaI,deltaE];