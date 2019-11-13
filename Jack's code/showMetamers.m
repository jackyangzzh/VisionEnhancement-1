function showMetamers(xyz1, xyz2)

rgb1 = xyz2rgb(xyz1);
rgb2 = xyz2rgb(xyz2);

RGB = zeros(512,512,3);
for i = 1:512
    for j = 1:256
        RGB(i,j,:) = rgb1;
    end
    for j = 257:512
        RGB(i,j,:) = rgb2;
    end
end
rgbImage = uint8(255*RGB);
imshow(rgbImage);