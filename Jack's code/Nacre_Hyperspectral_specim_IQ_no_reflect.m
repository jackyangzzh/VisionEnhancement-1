%Script for Biomineralization hyperspectral imaging
%to read in .raw hyperspectral image files and convert them to reflectance
%
%This file is for using the Specim IQ hyperspectral camera.
clear all;
clc;
close all;

%% Define Control values
onNormalizeData = 0; % 1 for S_data using intensity normalize spectra 
                     % 0 for S_data using regular spectra
onWholeImage = 0;    % 1 for S_data in range of whole image
                     % 0 for S_data in range of the selected region                    
%% Import File Infomation
pathrefs = cd;
path = pwd;
file = '../ImageData/2018-09-11_004/capture/2018-09-11_004.raw';
header_file = '../ImageData/2018-09-11_004/capture/2018-09-11_004.hdr';
whiteFile = '../ImageData/2018-09-11_004/capture/2018-09-11_004.raw';
darkForWhiteFile = '../ImageData/2018-09-11_004/capture/DARKREF_2018-09-11_004.raw'; %dark reference taken at same exposure time as white
darkForSampleFile = '../ImageData/2018-09-11_004/capture/DARKREF_2018-09-11_004.raw'; %dark reference taken at same exposure time as sample
[wavelengths, spatial, frames, spectral, tint, settings ] = parseHdrInfo_IQ(path,header_file); %Extract wavelength [nm] and other params.

% Read in image file
img = reshapeImage_IQ(path,file);
white = reshapeImage_IQ(path,whiteFile);
dark = reshapeImage_IQ(path,darkForWhiteFile);
dark_sample = reshapeImage_IQ(path,darkForWhiteFile); 

%Plot raw images of sample data at a single wavlength
figure
wavlen = 148; %Define wavelength index to plot raw image
imagesc(img(:,:,wavlen)); %View single wavelength of sample
title(['Raw sample image @ \lambda = ',num2str(wavelengths(wavlen)),' nm']);
xlabel('Pixel number');
ylabel('Frame number');
axis 'equal'


%Plot at a single wavelength and select region to consider as white
%reference white reference
figure
imagesc(white(:,:,wavlen)); %View single wavelength of white
title(['Raw white ref image @ \lambda = ',num2str(wavelengths(wavlen)),' nm']);
xlabel('Pixel number');
ylabel('Frame number');
axis 'equal'

[x_w,y_w] = ginput; %Grab region in which to average white reference
x_w = round(x_w);
y_w = round(y_w);
%% Extract Spectrum and Illuminant
%use average frame of white & dark references
whiteAvg = zeros(spatial,spectral); %initialize average row of white pixels
darkavg = whiteAvg; %initialize average row of dark pixels
img_dark_sub = zeros(frames,spatial,spectral); %initialize image matrix - dark pixels
white_sub = zeros(size(white,1),size(white,2),size(white,3));
whiteavg_sub = whiteAvg;
for i = 1:spatial
    for j = 1:spectral
        darkavg(i,j) = mean(dark(:,i,j));
        whiteAvg(i,j) = mean(mean(white(y_w(1):y_w(2),x_w(1):x_w(2),j)));
        whiteavg_sub(i,j) = whiteAvg(i,j)-darkavg(i,j);
        img_dark_sub(:,i,j) = img(:,i,j)-darkavg(i,j);
    end
end

illuminant = whiteavg_sub(1,:);
S = img_dark_sub;

%% Intensity Normalize
maxIntensity = 1.0; %maxIntensity we want to normalize to
S_n = intensMatrixNorm(S, maxIntensity);

%% Grab Area
figure
imagesc(S(:,:,wavlen))
%Click two points to define an area to grab spectra for each pixel
[x,y] = ginput;
x = round(x);
y = round(y);

%%Plot individual spectra vs normalized spectra for each pixel in selected area
figure
for i = y(1):y(2)
    for j = x(1):x(2)
        test = S(i,j,:);
        test_n = S_n(i,j,:);
        plot(wavelengths, smooth(test_n(:),1));
        plot(wavelengths, smooth(test(:),1));
        hold on
    end
end

%Save only S spectra for selected pixel positions
if onNormalizeData == 1
    S_mat = S_n(y(1):1:y(2),x(1):1:x(2),:);
else 
    S_mat = S(y(1):1:y(2),x(1):1:x(2),:);
end
lambda_meas = wavelengths;

if onWholeImage == 1
   if onNormalizeData == 1
        S_data = S_n;
   else
        S_data = S;
   end
else
   S_data = S_mat;
end
%% Spectrum to XYZ
% CMF 390 nm to 830 nm 
% Image wavelegnths to index 1:147
load('.\CIE2DegreeObserver.mat')
lambda_q =  wavelengths(1:147); % 390 nm - 830 nm
% Interpolate the CMF
CMF = interp1(CIE2DegreeObserver(:,1),...
                              CIE2DegreeObserver(:,2:end),...
                              lambda_q);

sz = size(S_data);                          
XYZ = zeros(sz(1),sz(2),3);
I = illuminant(1:147);
K = 1;
k = K/(I*CMF(:,2)); %1 is a constant K range from 1 or 100
for i = 1:sz(1)
    for j = 1:sz(2)
        spectra = reshape(S_data(i,j,1:147),[1 147]);
        XYZ(i,j,:) = k*spectra*CMF;
    end
end
%% XYZ to CIELAB
tic
sz2 = size(XYZ);
lab_data = zeros(sz2);
for i = 1:sz2(1)
    for j = 1:sz2(2)
       lab_data(i,j,:) = xyz2lab(reshape(XYZ(i,j,:), [1 3]),'WhitePoint','a');
    end
end
toc
%% Coordinate position, lab_data and S_data into pixel_data
%pixel_data is a list of pixel info aligning with following data format
%[row in S_data(int), col in S_data(int), lab info(3 int), spectra info(204 int)]
sz = size(S_data);
pixel_data = zeros([sz(1)*sz(2),209]);
count = 1;
for i = 1:sz(1)
   for j = 1:sz(2)       
       pixel_data(count,:) = [i+y(1)-1,j+x(1)-1,reshape(lab_data(i,j,:),[1,3]),reshape(S_data(i,j,:),[1,204])];
       count = count+1;
   end
end
%% Bruteforce compare
tic
DeltaE_threshold = 2.3;
DeltaI_threshold = 10;
pairs = [];
countComp = 0; % this is only a counter for #compares so far, used for estimate total evaluate time

for i = 1:size(pixel_data)-1
   for j = i+1:size(pixel_data)
      if i == j
          continue
      end
      countComp = countComp+1;
      deltaE = DeltaECalc(pixel_data(i,3:5),pixel_data(j,3:5));
      if deltaE <= DeltaE_threshold
          deltaI = DeltaICalc(pixel_data(i,6:209),pixel_data(j,6:209));
          if deltaI >= DeltaI_threshold
               temp_pair = [pixel_data(i,1:2),pixel_data(j,1:2), deltaI, deltaE, deltaI/deltaE];
               pairs = [pairs;temp_pair]; 
                        % each pair is in format as follows
                        %[pixel1_row, pixel1_col, pixel2_row, pixel2_col, deltaI, deltaE, deltaI/deltaE]
          end
      end 
   end
end
toc

%% Sorting pairs with deltaI/deltaE factor
sortedPairs = sortrows(pairs,7,'descend');