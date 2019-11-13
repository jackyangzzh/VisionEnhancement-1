function spectrum = applyIlluminant(R, illuminant)
    spectrum = zeros(size(R));
    for i = 1:size(R,1)
        for j = 1:size(R,2)
            temp = R(i,j,:);
            spectrum(i,j,:) = temp(1,:).*illuminant;
        end 
    end 
end