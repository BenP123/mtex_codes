function BCF_H5Conv( InputUser )
%BCF_H5CONV Converts bcf to HDF5
%   Works on windows only
InputUser.HDF5_file=[InputUser.EBSD_File '.h5'];
InputUser.BCF_file=[InputUser.EBSD_File '.bcf'];


InputUser.HDF5FullFile=fullfile(InputUser.HDF5_folder,InputUser.HDF5_file)


if exist(InputUser.HDF5FullFile) == 0
    InputUser.BCFFullFile=fullfile(InputUser.BCF_folder,InputUser.BCF_file);
    
    if exist(InputUser.BCFFullFile) == 0
        error('The input BCF file does not exist');
    end
    if exist(InputUser.BCF2HDF5_loc) == 0
        error('The converter tool is absent');
    end
    
    %construct the input arguement
    Text_Run=[InputUser.BCF2HDF5_loc ' "' InputUser.BCFFullFile '" "' InputUser.HDF5FullFile '" "' InputUser.EBSD_File '"'];
    
    %run via DOS
    dos(Text_Run);
end

end

