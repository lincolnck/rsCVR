%matlab script to convert DICOM images saved in compressed .tgz archives
tgzDir = '/Volumes/My Passport/fMRI3/image03';
outDir = '/Volumes/ABCD/dec_abcd';
dcm2nii = '/usr/local/bin/dcm2nii';

if ~exist(dcm2nii,'file'), error('Unable to find %s',dcm2nii); 
end

d = dir(fullfile(tgzDir,'*.tgz'));

if isempty(tgzDir), error('No tgz files in %s', tgzDir); 
end

nams ={d.name};
nams =sort(nams);
for i = numel(nams): -1 : 1 %173numel(nams)
    nam = nams{i};
    [~, n] = fileparts(nam);
    fprintf('%d/%d >> %s\n', i, numel(nams), n);
    nam2 = fullfile(tgzDir,nam);
    outDir2 = fullfile(outDir,n);
    if exist(outDir2,'dir')
        continue; 
    end
    mkdir(outDir2);
    outDir3 = fullfile(outDir2,"temp");
    mkdir(outDir3);
    untar(nam2, outDir3);
    %convert DICOM -> nii
    if contains(nam, "rsfMRI")
        cmd = sprintf('%s -4 y -a n -d n -e n -i n -p n -g n -n n -s y -x n -r n -f %%t_%%s_%%p %s', dcm2nii, outDir2);
    else 
        cmd = sprintf('%s -4 n -a n -d n -e n -i n -p n -g n -n n -s y -x n -r n -f %%t_%%s_%%p %s', dcm2nii, outDir2);
    end
    fprintf('Running \n %s\n', cmd);
    system(cmd,'-echo');
    rmdir(outDir3, 's');
end
