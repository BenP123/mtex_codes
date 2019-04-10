%% my masterful MTEX doing script

clear; %clear variables
% close all; %close all figures
home; %hide all the items in the command window, better than clc


%% import things
% file name - this file is output by the tool BCF
raw_data_dir = 'C:\Users\bop15\Desktop\EBSD\raw_data\';
[file,path] = uigetfile({'*.bcf';'*h5';'*.ctf'},'Pick your EBSD file',raw_data_dir);
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
end

%% convert bcf to hdf5 if you pick a bcf
file_type = file(end-2:end);
% catch h5
if file_type == '.h5'; file_type = 'h5'; end


if strcmp(file_type, 'bcf')
    % check the hdf5 doesn't already exist
    if exist([path file(1:end-3) 'h5'], 'file') == 2
        disp('Converted hdf5 file exists, will use that instead')
        
        % switch to the already converted hdf5 file
        file = [file(1:end-3) 'h5'];
        file_type = 'h5';
        disp(['Swapped to ' file]) 
    else       
        disp('Converting bcf to hdf5 ...')
        
        % run in this dir
        InputUser.BCF_folder = path;
        InputUser.HDF5_folder = InputUser.BCF_folder;
        InputUser.BCF2HDF5_loc='C:\Users\bop15\Desktop\EBSD\BCF2HDF5\BCF2HDF5cmd.exe';
        InputUser.EBSD_File = file(1:end-4);
        BCF_H5Conv(InputUser)
        disp('Conversion done...')
        disp('Now EBSD data are hdf5')
        % switch to newly converted h5 file
        file_type = 'h5';
        file = [file(1:end-3) 'h5'];
    end
elseif strcmp(file_type, 'h5')
    disp('EBSD data are already hdf5')
elseif strcmp(file_type, 'ctf')
    disp('EBSD data are ctf')
else 
    disp('Your EBSD is wrong. It should be hdf5, bcf, ctf!')
end

%% load the EBSD
Full_file = [path file];

if strcmp(file_type, 'bcf')
    disp("Can't load EBSD data is they are bcf format! Something has gone wrong...")
elseif strcmp(file_type, 'h5')
    [ebsd,header] = loadEBSD_h5(Full_file);
elseif strcmp(file_type, 'ctf')
    [ebsd,header] = loadEBSD_ctf(Full_file);
else 
    disp('Make sure the converter is working or your data are hdf5 or ctf.')
end

%% set up plotting
% get the screen size from the computer - useful for full sizing figures
% PlotData.ssize=get(groot,'ScreenSize'); %makes the figures "full-screen"

setMTEXpref('xAxisDirection','west');
setMTEXpref('zAxisDirection','outOfPlane');

%% import the h5 file to MTEX
% header is a struct which contains all the microscope data

% import phase lists

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

% %% pole figures
% phase = 'Ferrite, bcc (New)';
% % calculate an ODF for the Ferrite phase
% odf = calcODF(ebsd(phase).orientations,'halfwidth',5*degree);
% % decide on the representations we want in the PDF
% h = Miller({1,0,0},{0,1,1},{1,1,1},odf.CS);
% % set the range for the PDF plotter - I know the xRandom settings here
% pf_range=0.1:0.5:5;
% % plot the probability distribution functions, as needed for the
% plotPDF(odf,h,'upper','projection','eangle','contourf',pf_range,'minmax')
% mtexColorbar
% % remove what is not needed later
% clear h odf pf_range
% 
% figure
% phase = 'Austenite, fcc (New)';
% % calculate an ODF for the Ferrite phase
% odf = calcODF(ebsd(phase).orientations,'halfwidth',5*degree);
% % decide on the representations we want in the PDF
% h = Miller({1,0,0},{0,1,1},{1,1,1},odf.CS);
% % set the range for the PDF plotter - I know the xRandom settings here
% pf_range=0.1:0.5:5;
% % plot the probability distribution functions, as needed for the
% plotPDF(odf,h,'upper','projection','eangle','contourf',pf_range,'minmax')
% mtexColorbar
% % remove what is not needed later
% clear h odf pf_range

%% find the grains 

grains_raw = calcGrains(ebsd('indexed'));
% figure
% plot(grains_raw)

gbThreshold = 5*degree; %set the MSet for the grain boundary angle threshold
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',gbThreshold);

% Remove small grains -
% e.g. misindexed points, and grains that are smaller than we want explore
smallGrains = 10; % in pixels

% cull the graindata to select only those with a grain size greater than the
% small grains threshold values
grains = grains(grains.area >= smallGrains); %remove grains

% and throw away these measurements from the ebsd data set
ebsd = ebsd(grains);

% re-number the grain indexing
[grains,ebsd.grainId,ebsd.mis2mean] = calcGrains(ebsd('indexed'),'angle',gbThreshold);

% and smooth the grain boundaries a bit to avoid staircasing effect
% this should be done before denoising the ebsd data
grains = smooth(grains,3);

% remove what is not needed later
clear smallGrains gbThreshold

figure
plot(grains)

