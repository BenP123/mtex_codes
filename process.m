%% my masterful MTEX doing script

clear; %clear variables
close all; %close all figures
home; %hide all the items in the command window, better than clc


%% import things
% file name - this file is output by the tool BCF
fname = 'n60_750x_750nm_step'
% fname = '20190213_nitronic_60_test_w_pen_on_sample.h5';

% convert bcf to hdf5?
conv_yes = 0; % 0 for no

% run in this dir
InputUser.BCF_folder = cd;
InputUser.HDF5_folder = InputUser.BCF_folder;
InputUser.BCF2HDF5_loc='C:\Users\bop15\Desktop\EBSD\BCF2HDF5\BCF2HDF5cmd.exe';
InputUser.EBSD_File = fname;


BCF_H5Conv(InputUser)




%% set up plotting
% get the screen size from the computer - useful for full sizing figures
% PlotData.ssize=get(groot,'ScreenSize'); %makes the figures "full-screen"

setMTEXpref('xAxisDirection','west');
setMTEXpref('zAxisDirection','outOfPlane');

%% import the h5 file to MTEX
% header is a struct which contains all the microscope data
fname = [fname '.h5'];
material = 'Nitronic_60';
[ebsd,header] = loadEBSD_h5(fname)

%% import phase lists

%% visually check the result
%figure('Position',PlotData.ssize)
subplot(2,3,1),
plot(ebsd,ebsd.prop.X_BEAM,'micronbar','off','parent',gca); title('XBeamPosition')
subplot(2,3,2),
plot(ebsd,ebsd.prop.Y_BEAM,'micronbar','off','parent',gca); title('YBeamPosition')
subplot(2,3,3),
plot(ebsd,header.SEM_Image./256,'micronbar','off','parent',gca);
title('SEM Image')
subplot(2,3,4), plot(ebsd,ebsd.x,'micronbar','off','parent',gca);
title('X-Sample Position')
subplot(2,3,5), plot(ebsd,ebsd.y,'micronbar','off','parent',gca);
title('Y-Sample Position')
subplot(2,3,6),
plot(ebsd,ebsd.prop.RadonQuality,'micronbar','off','parent',gca);
title('Quality')

%% plot the phase map and quality map

%plot the EBSD phase map
FigH.phase=figure;
plot(ebsd);

% Quality map
FigH.Quality=figure;
plot(ebsd,ebsd.prop.RadonQuality); colormap('gray')

%% pole figures
phase = 'Ferrite, bcc (New)';
% calculate an ODF for the Ferrite phase
odf = calcODF(ebsd(phase).orientations,'halfwidth',5*degree);
% decide on the representations we want in the PDF
h = Miller({1,0,0},{0,1,1},{1,1,1},odf.CS);
% set the range for the PDF plotter - I know the xRandom settings here
pf_range=0.1:0.5:5;
% plot the probability distribution functions, as needed for the
plotPDF(odf,h,'upper','projection','eangle','contourf',pf_range,'minmax')
mtexColorbar
% remove what is not needed later
clear h odf pf_range

figure
phase = 'Austenite, fcc (New)';
% calculate an ODF for the Ferrite phase
odf = calcODF(ebsd(phase).orientations,'halfwidth',5*degree);
% decide on the representations we want in the PDF
h = Miller({1,0,0},{0,1,1},{1,1,1},odf.CS);
% set the range for the PDF plotter - I know the xRandom settings here
pf_range=0.1:0.5:5;
% plot the probability distribution functions, as needed for the
plotPDF(odf,h,'upper','projection','eangle','contourf',pf_range,'minmax')
mtexColorbar
% remove what is not needed later
clear h odf pf_range
