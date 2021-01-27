% This function convert DICOM images saved in compressed .tgz 
% archives into NIfTI/ANALYZE images
%
% Input:
%    sourceDir: The full filepath of the directory containing the .tgz
%    files.
%    targetDir: The full filepath of the desired target directory, where
%    the NIfTI/ANALYZE images will be saved.
%    dcm2nii: The full filepath pointing to the 'dcm2nii' helper tool. 
%
%       More information on 'dcm2nii', including how to download and
%       install it can be found on the website url below. Note: this
%       function uses the obsolete version of 'dcm2nii', which allows
%       conversion to ANALYZE format, rather than the newe 'dcm2niix'.
%
%               https://people.cas.sc.edu/rorden/mricron/dcm2nii.html
%
% Output:
%    The DICOM images are saved in the target directory as NIfTI/ANALYZE
%    images.
%    
% written by Lincoln Kartchner (lincoln@jhu.edu)
% 2021-01-27

function f = tgz_dcm2analyze(sourceDir, targetDir, dcm2nii)

sourceDir = '/Volumes/My Passport/fMRI3/image03';
targetDir = '/Volumes/ABCD/dec_abcd';
dcm2nii = '/usr/local/bin/dcm2nii';

if ~exist(dcm2nii,'file'), error('Unable to find %s',dcm2nii); 
end

d = dir(fullfile(sourceDir,'*.tgz'));

if isempty(sourceDir), error('No tgz files in %s', sourceDir); 
end

nams ={d.name};
nams =sort(nams);
for i = numel(nams): -1 : 1 %173numel(nams)
    nam = nams{i};
    [~, n] = fileparts(nam);
    fprintf('%d/%d >> %s\n', i, numel(nams), n);
    nam2 = fullfile(sourceDir,nam);
    outDir2 = fullfile(targetDir,n);
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
