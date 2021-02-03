function success = CVR_pipeline_jobman(path_code, jsonInput)
% CVR_pipeline_jobman The wrapper function for running the CVR_pipeline
% function.
%
% Inputs:
%       path_code : str
%           The full path pointing to the 'commands' directory. This
%           directory contains the IMG_apply_AIR_tform1,
%           IMG_change_res_info, and TPM.nii files.
%       jsonInput : str
%           The full pth pointing to the scan's json file. This file
%           contains all user-specified inputs for CVR_pipeline. On
%           CVR-MRICloud the json file is created by the web page based on
%           the user's uploaded files and specifications.
%
% Ouputs:
%       success : bool
%           Is true if no error is caught during processing; otherwise is
%           false.

    % get main path and output path from json file
    cvr_paras = loadjson(jsonInput);
    path_data = cvr_paras.Dir.mainPath;
    path_output = cvr_paras.Dir.outPath;
    
    % specify the name of the output file
    outputFileName = 'Result';    
    
    % create a .log file to record output info/error msg
    datetimestr     = sprintf('%4d%02d%02d_%02d%02d%02d',int16(clock));
    diaryFile       = [path_data,filesep,'CVRMRICloud_' datetimestr '.log'];
    if ~isempty(dir([path_data,filesep,'*.log']))
        delete([path_data,filesep,'*.log']);
    end
    diary(diaryFile); % start the diary
    
    % initialize return value
    success = false;
    
    % call CVR_pipeline inside try statement to handle any errors
    % if error happens, provide a .log for user to download
    try
        disp('CVRMRICloud: Single dataset...');
        
        % run CVR_pipeline
        tic
        output_content = CVR_pipeline_v2(path_code, jsonInput);
        toc
        
        % zip the folder for download
        delete(   [path_output,filesep,outputFileName,'.zip']);
        zipname = [path_output,filesep,outputFileName,'.zip'];
        contents = dir(output_content);
        contents = {contents.name};
        contents = contents(3:end);
        zip(zipname, contents, output_content);
        disp('CVRMRICloud zipped for download...');
        
        % processing was run without error; set return value to true
        success = true;
    
    % if error happens, provide a .log for user to download
    catch ME 
        msgErr = getReport(ME);
        fileID = fopen(diaryFile,'a');
        fprintf(fileID,'\n');
        fprintf(fileID,'CVRMRICloud: Error message...\n');
        fprintf(fileID,'%s\n',msgErr);
        fclose(fileID);
        if ~isempty(dir([path_output,filesep,'*.log'])) % delete .log in path_output if any before copy
            delete([path_output,filesep,'*.log']);
        end
        copyfile(diaryFile, path_output);

        % zip .log for download
        zipname = [path_output,filesep,outputFileName,'.zip'];
        zip(zipname,diaryFile);
    end

% end the diary
diary off; 
