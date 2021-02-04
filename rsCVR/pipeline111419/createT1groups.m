function f = createT1groups(targetDir,groupSize,imageType,zipFiles,groupsDir)

d_number=1;
new_subdir_name=join(["group" d_number],"_");

if ~exist(targetDir, 'dir') || isempty(targetDir)
    error('The specified target directory: %s does not exist.', targetDir);
end
if ~exist(groupsDir, 'dir')
    cd(fullfile(targetDir))
    mkdir(fullfile(join([".." filesep groupsDir],"")))
end
mkdir(fullfile(join([".." filesep groupsDir filesep new_subdir_name],"")))

subTargetDir = dir(fullfile(targetDir,'*'));
nTargetDir = setdiff({subTargetDir([subTargetDir.isdir]).name},{'.','..'});
for ii = 1:numel(nTargetDir)
    T = dir(fullfile(targetDir,nTargetDir{ii},'*'));
    C = {T(~[T.isdir]).name}; % files in subfolder.
    for jj = 1:numel(C)
        subjectImage = fullfile(targetDir,nTargetDir{ii},C{jj});
        numFiles=dir(fullfile(join([".." filesep groupsDir filesep new_subdir_name],"")));
        image_number=groupSize*2;
        if numel(numFiles) < image_number
            if contains(subjectImage,imageType)
                subject_and_image_name = split(subjectImage,filesep);
                subject_name = subject_and_image_name{end-1};
                image_name = subject_and_image_name{end};
                dest_name = join([subject_name, image_name],"_");
                copyfile(subjectImage, fullfile(join([".." filesep groupsDir filesep new_subdir_name filesep dest_name],"")));
            end
        else
            if zipFiles == "Y"
                cd(fullfile(join([".." filesep groupsDir filesep new_subdir_name],"")))
                zip(new_subdir_name,{'*.img','*.hdr'})
                cd(fullfile(targetDir))
            end
            d_number=d_number+1;
            new_subdir_name=join(["group" d_number],"_");
            mkdir(fullfile(join([".." filesep groupsDir filesep new_subdir_name],"")));
            if contains(subjectImage,imageType)
                subject_and_image_name = split(subjectImage,filesep);
                subject_name = subject_and_image_name{end-1};
                image_name = subject_and_image_name{end};
                dest_name = join([subject_name, image_name],"_");
                copyfile(subjectImage, fullfile(join([".." filesep groupsDir filesep new_subdir_name filesep dest_name],"")));
            end
        end
    end
end