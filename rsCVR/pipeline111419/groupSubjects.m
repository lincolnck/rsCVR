function f = groupSubjects(targetDir, os)

if os=='mac'
    commands = {'mv -v', 'rm -r', 'mkdir -p'};
else
    commands = {'MOVE', 'RMDIR /q/s', 'MD'};
end
if ~exist(targetDir, 'dir') || isempty(targetDir)
    error('The specified target directory: %s does not exist.', targetDir);
end
subTargetDir = dir(fullfile(targetDir,'*'));
nTargetDir = setdiff({subTargetDir([subTargetDir.isdir]).name},{'.','..'});

for ii = 1:numel(nTargetDir)
    subjectName = extractBefore(nTargetDir{ii},"_");
    subjectDir = join([targetDir filesep subjectName],"");
    cmd = sprintf('%s %s', commands{3}, subjectDir);
    system(cmd, '-echo');
    T = dir(fullfile(targetDir,nTargetDir{ii},'*'));
    C = {T(~[T.isdir]).name}; % files in subfolder.
    for jj = 1:numel(C)
        subjectImage = fullfile(targetDir,nTargetDir{ii},C{jj});
        cmd = sprintf('%s %s %s', commands{1}, subjectImage, subjectDir);
        system(cmd, '-echo');
    end
    cmd = sprintf('%s %s', commands{2}, join([targetDir filesep nTargetDir{ii}],""));
    system(cmd, '-echo');
end