function zach_createSubdirsInOutdir(outDir, mprageFlag)
% zach_createSubdirsInOutdir. Creates subdirectories to organize
% CVR-MRICloud's outputs and moves files into appropriate directories.
%
% Inputs:
%       outDir : str
%           The full path of the directory where all outputs are located
%           and will be zipped.
%       mprageFlag : bool
%           True (1) if mprage data is included (meaning that mprage and
%           mni space results are present). False (0) otherwise.

    % make dirs to separate globalshift maps, voxelshift maps, and matlab
    % figures (text files will be left on the surface)
    voxDir = [outDir filesep 'Voxelshift_maps'];
    gloDir = [outDir filesep 'Globalshift_maps'];
    matlabFigDir = [outDir filesep 'MATLAB_figures'];
    mkdir(gloDir)
    mkdir(voxDir)
    mkdir(matlabFigDir)
    
    % move globalshift maps to gloDir
    glos = spm_select('FPList', outDir, '.*globalshift.*(.img$|.hdr$)');
    for i = 1:size(glos,1)
        movefile(strtrim(glos(i,:)), gloDir, 'f')
    end
    
    % move voxelshift maps to voxDir
    voxs = spm_select('FPList', outDir, '.*voxelshift.*(.img$|.hdr$)');
    for i = 1:size(voxs,1)
        movefile(strtrim(voxs(i,:)), voxDir, 'f')
    end

    % move matlab figs to matlabFigDir
    figs = spm_select('FPList', outDir, '.fig');
    for i = 1:size(figs,1)
        movefile(strtrim(figs(i,:)), matlabFigDir, 'f')
    end
    
    % make and move maps to boldspace, mprspace, and mnispace subdirs
    shiftDirs = {gloDir, voxDir};
    for i = 1:length(shiftDirs)
        current_shiftDir = shiftDirs{i};
        if mprageFlag
            spaces = {'BOLDspace', 'MPRspace', 'MNIspace'};
        else
            spaces = {'BOLDspace'};
        end
        for j = 1:length(spaces)
            spaceDir = [current_shiftDir filesep spaces{j}];
            mkdir(spaceDir)
            mapPaths = spm_select('FPList', current_shiftDir,...
                ['.*' spaces{j} '.*(.img$|.hdr$)']);
            if ~isempty(regexp(current_shiftDir, 'Voxelshift_maps', 'once'))
                mapPaths2 = spm_select('FPList', outDir,...
                [spaces{j} '.*BAT.*(.img$|.hdr$)']);
                for k = 1:size(mapPaths2, 1)
                    movefile(strtrim(mapPaths2(k,:)), spaceDir, 'f')
                end
            end
            for k = 1:size(mapPaths, 1)
                movefile(strtrim(mapPaths(k,:)), spaceDir, 'f')
            end
%             % sort globalshift and voxelshift for CVR maps as well
%             current_mapFolder = strsplit(shiftDirs{i}, filesep);
%             if strcmp(current_mapFolder{end}, 'CVR_maps')
%                 shifts = {'globalshift', 'voxelshift'};
%                 for k = 1:length(shifts)
%                     shiftDir = [spaceDir filesep shifts{k}];
%                     mkdir(shiftDir)
%                     mapPaths = spm_select('FPList', spaceDir,...
%                         ['.*' shifts{k} '.*(.img$|.hdr$)']);
%                     for m = 1:size(mapPaths, 1)
%                         movefile(strtrim(mapPaths(m,:)), shiftDir, 'f')
%                     end
%                 end
%             end
        end
        
    end

end