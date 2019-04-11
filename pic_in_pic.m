%% find image in an image 
raw_data_dir = 'C:\Users\bop15\Desktop\EBSD\raw_data\';
% Larger image 
[Pic_l, path_l] = uigetfile({'*.png';'*.tif'},'Pick your large file',raw_data_dir);
Full_l = [path_l Pic_l];

% smaller image
[Pic_s, path_s] = uigetfile({'*.png';'*.tif'},'Pick your small file',raw_data_dir);
Full_s = [path_s Pic_s];

%%
% sort out magnifications
magL = 400;
magS = 750;

% get grey versions
read_L = rgb2gray(imread(Full_l));
read_S = rgb2gray(imread(Full_s));

% resize to the correct size 
read_SR = imresize(read_S, magL/magS);

c = normxcorr2(read_SR,read_L);
figure, surf(c), shading flat

%% 
[ypeak, xpeak] = find(c==max(c(:)));
yoffSet = ypeak-size(read_SR,1);
xoffSet = xpeak-size(read_SR,2);

%%
figure
imshow(read_L);
imrect(gca, [xoffSet+1, yoffSet+1, size(read_SR,2), size(read_SR,1)]);