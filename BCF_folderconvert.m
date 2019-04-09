clear;
close all;
home;

%small tool to convert a BCF folder into a stack of H5 files with the same
%file names
%% input variables
InputUser.BCF_folder='C:\Users\bop15\Desktop\EBSD\'; %this can be different to the H5 output folder

InputUser.HDF5_folder=InputUser.BCF_folder; %keep the same as the BCF
% InputUser.HDF5_folder='W:\Simon\MTEX_Workshop\Demo1'; %uncomment and change if you want a different destination


InputUser.BCF2HDF5_loc='C:\Users\bop15\Desktop\EBSD\BCF2HDF5\BCF2HDF5cmd.exe'; %location of the converter, should end in .exe
%% create the results folder if need
if isdir(InputUser.HDF5_folder) == 0; mkdir(InputUser.HDF5_folder); end

%% read the folder & check for BCF files
FolderList=dir(InputUser.BCF_folder);

isok=false(size(FolderList,1),1);

for n=1:size(FolderList,1)
    if FolderList(n).isdir == 0 %not a folder
        if strcmpi(FolderList(n).name(end-3:end),'.bcf')
           isok(n)=true; %is a valid bcf
        end
    end
end
FolderBCF=FolderList(isok);

%Run the converter automatically
%This will skip files that have already been converted

for n=1:size(FolderBCF,1)
    InputUser.EBSD_File=FolderBCF(n).name(1:end-4); %has to not have bcf on the end
    BCF_H5Conv( InputUser );
end
    
disp('Conversion complete');
