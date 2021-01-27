function t1Path = zach_unzipT1(workDir, multiatlasFileName)
% zach_unzipT1 Unzips the zip file with the name multiatlasFileName in
% workDir and subsequently finds the lowest directory (assumes that the
% zip file only has one or zero subdirectories in each level).
%
% Inputs:
%       workDir : str
%           Full path to the workDir; the directory designated for all of
%           CVR-MRICloud's processing
%       multiatlasFileName : str
%           The name of the zip file being unzipped
%
% Outputs:
%       t1Path : str
%           Full path pointing to the found lowest directory of the
%           unzipped multiatlasFileName

    % get path to zip folder, sans '.zip' and unzip it
    unzipPath = [workDir filesep multiatlasFileName(1:end-4)];
    if exist(unzipPath,'dir')
        rmdir(unzipPath,'s')
    end
    mkdir(unzipPath)
    unzip([unzipPath '.zip'], unzipPath)
    
    % find lowest point
    loc = unzipPath;
    while 1
        contents = dir(loc);
        folders = 0;
        for i = 3:length(contents)
            if contents(i).isdir
                folders = folders+1;
                loc = [loc filesep contents(i).name];
            end
        end
        % ensure that there is at most one subdirectory
        if folders > 1
            error(['T1 Segmentation zip may not have subdirectories ',...
                'with multiple folders'])
        end
        % if the lowest point is found, break from the while loop
        if folders == 0
            break
        end  
    end
    
    % return t1Path
    t1Path = loc;
