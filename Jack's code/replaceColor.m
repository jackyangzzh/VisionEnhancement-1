%% Display image from CMF
% Read in original RGB image.
% rgbImage = imread('RGBSCENE_2018-09-09_001.png');
rgbImage = uint8(255*rgb); 
imshow(rgbImage);
% Extract color channels.
redChannel = rgbImage(:,:,1); % Red channel
greenChannel = rgbImage(:,:,2); % Green channel
blueChannel = rgbImage(:,:,3); % Blue channel
  


% Recombine the individual color channels to create the original RGB image again.
recombinedRGBImage = cat(3, redChannel, greenChannel, blueChannel);


%% Replace Red Function

% Read in original RGB image.
% rgbImage = imread('RGBSCENE_2018-09-09_001.png');
rgbImage = uint8(255*rgb);
% Extract color channels.
redChannel = rgbImage(:,:,1); % Red channel
greenChannel = rgbImage(:,:,2); % Green channel
blueChannel = rgbImage(:,:,3); % Blue channel
% Create an all black channel.
allBlack = zeros(size(rgbImage, 1), size(rgbImage, 2), 'uint8')
sum = 0;        


nirImage = spectra(:,:,77:104);
    %620nm-700nm = 77-104
    %700nm-750nm = 104-121
    %750nm-810nm = 121-141
arrayInt = zeros(512,512,1);
delta = diff(nirImage(1,1,:));
delta = abs(delta(1));
Rnew = zeros(512,512,length(nirImage(1,1,:)));
%Integrate through the pixels and calculate spectrum then store
%it inside an array
  for i = 1:512
    for j = 1:512
        for k = 1:length(nirImage(1,1,:))
            tempInt = nirImage(i,j,k) * delta;
            arrayInt(i,j,1) = arrayInt(i,j,1) + tempInt;
        end
    end
  end

%Calculate the max value of the integral array
maxValue = max(max(arrayInt));

just_red = cat(3, redChannel, allBlack, allBlack);

arrayInt = uint8(arrayInt/maxValue*255);

% Difference between new red and old red
redDifference = redChannel - arrayInt;
averageDiff = mean(redDifference,'all');

x = 1:512;
y = 1:512;
[X,Y] = meshgrid(x,y);

% Run in terminal
% pcolor(X,Y,redDifference)
% colormap jet 
% shading interp
% h=colorbar
    
redChannel = arrayInt;
% Create color versions of the individual color channels.

just_green = cat(3, allBlack, greenChannel, allBlack);
just_blue = cat(3, allBlack, allBlack, blueChannel);

% Recombine the individual color channels to create the original RGB image again.
recombinedRGBImage = cat(3, redChannel, greenChannel, blueChannel);
imshow(recombinedRGBImage);

%
%% Slider Function
mySlider(lambda_q,CMF(:,1));

plot(lambda_q,CMF(:,1));
xlim([350 950]);

function mySlider(a,b)

f=figure('visible','off','position',...
    [360 500 500 500]);
slhan=uicontrol('style','slider','position',[100 50 350 20],'callback',@callbackfn);
axes('units','pixels','position',[100 100 350 350]);
movegui(f,'center')
set(f,'visible','on');
    function callbackfn(source,eventdata)
        num=get(slhan,'value')*100;
        x=a+num;
        y=b;
        plot(x,y);
        xlim([350 950]);
        ax=gca;
    end
end
% % Display them all.
% subplot(3, 3, 2);
% imshow(rgbImage);
% fontSize = 20;
% title('Original RGB Image', 'FontSize', fontSize)
% subplot(3, 3, 5);
% imshow(just_red);
% title('Red Channel in Red', 'FontSize', fontSize)
% subplot(3, 3, 8);
% imshow(recombinedRGBImage);
% title('Recombined to Form Original RGB Image Again', 'FontSize', fontSize)
% % Set up figure properties:
% % Enlarge figure to full screen.
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
% % Get rid of tool bar and pulldown menus that are along top of figure.
% % set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% % Give a name to the title bar.
% set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')