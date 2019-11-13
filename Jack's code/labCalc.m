
%%Clear 
close all;
clear all;


%% Calculation
deltaE = DeltaECalc(lab24_9,lab24_10);



% %%Get all LAB files 
% addpath('FM100 info/lab file');
% 
% path = dir('FM100 info/lab file/*.mat');
% 
% labMatrix = zeros(length(path),3);
% nameMatrix = strings(length(path),1);
% 
% for c = 1:length(path)
%    temp = struct2array(load(path(c).name));
%    nameMatrix(c) = path(c).name;
%    labMatrix(c,:) = temp;
% end
% 
% numCompare = length(path) - 1;
% labCompareMatrix = zeros(numCompare,1);
% for i = 1:numCompare
%     numCompare(i) = DeltaECalc(labMatrix(i,:),labMatrix(i+1,:));
% end 
% 
% plot(numCompare);