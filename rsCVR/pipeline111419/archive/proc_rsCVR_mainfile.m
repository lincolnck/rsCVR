clear all;
%GENERAL
cwd = '/Volumes/LincolnHardDrive/Lincoln/School/JHU/research/HIV_rsCVR/HIV_Tobacco/FunImg'; %Project path
subjectlist={
    '040002_F04' %T1
%     '050056_F05' %T1_copy
%     '050096_F03' %48 %T1_copy2
%     '050101_F06' %3
%     '050137_F07' %4
%     '060005_F07' 5
%     '060028_F04' 6
%     '060091_F05' 7
%     '060096_F05' 8
%     '060097_F04' %47 9
%     '060167_F06' %48 10
%     '060172_S04' 11
%     '060181_F11' 12
%     '070022_F05' 13
%     '070073_F04' 14
%     '070074_F03' %48 15
%     '070081_F04' 16 
%     '070118_F02' 17
%     '080069_F03' 18
%     '080093_F03' 19
%     '090157_F03'
%     '100294_F04'
%     '100303_F04'
%     '110047_F03'
%     '110050_F04'
%     '110054_F03'
%     '110196_OSS01'
%     '110202_F03'
%     '110205_OSS01'
%     '110223_OSS01'
%     '110255_F04'
%     '120040_F03'
%     '120042_F02'
%     '120117_F01'
%     '120172_F03'
%     '120229_F03'
%     '120281_F04'
%     '130020_F03'
%     '130021_F01'
%     '130047_F02'
%     '130113_F01'
%     '130135_F03'
%     '130136_F03'
%     '130139_F03'
%     '130172_F03'
%     '130173_F03'
%     '140061_F03'
%     '160126_F01'
    };   % Subject folder name(s)
nsub=length(subjectlist);

% BOLD imaging parameters
tr=3;   % TR, in seconds
matsize = [64 64 46];
matresol = [3 3 3];

% Analysis parameters
cutfreq = 0.1164;    % Cutoff frequency range, in Hz. The recommended value is 0.1164
SmoothFWHMmm = 8;    % Gaussian smoothing kernal, in mm. The Recommended value is 8
templatedir = '/Users/lincolnkartchner/spm12/tpm';  % SPM folder that contains the TPM.nii file

for sub=1:nsub
    filename=[cwd filesep subjectlist{sub} filesep 'bold.img'];
    rsCVR_singlesub_analysis(filename,tr, cutfreq, matsize, matresol, SmoothFWHMmm,templatedir)
    cd '/Volumes/LincolnHardDrive/Lincoln/School/JHU/research/rsCVR/pipeline111419'
end
