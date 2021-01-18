% Convert BOLD image

cwd = '/Volumes/LincolnHardDrive/Lincoln/School/JHU/research/HIV_rsCVR/HIV_Tobacco/FunImg'; %Project path
%     t1dir='D:\work\HIV_Tobacco\T1Img\040002_F04';

subjectlist={
    '040002_F04' %T1
    '050056_F05' %T1_copy
    '050096_F03' %48 %T1_copy2
    '050101_F06' %3
    '050137_F07' %4
    '060005_F07' %5
    '060028_F04' %6
    '060091_F05' %7
    '060096_F05' %8
    '060097_F04' %47 9
    '060167_F06' %48 10
    '060172_S04' %11
    '060181_F11' %12
    '070022_F05' %13
    '070073_F04' %14
    '070074_F03' %48 15
    '070081_F04' %16 
    '070118_F02' %17
    '080069_F03' %18
    '080093_F03' %19
    '090157_F03'
    '100294_F04'
    '100303_F04'
    '110047_F03'
    '110050_F04'
    '110054_F03'
    '110196_OSS01'
    '110202_F03'
    '110205_OSS01'
    '110223_OSS01'
    '110255_F04'
    '120040_F03'
    '120042_F02'
    '120117_F01'
    '120172_F03'
    '120229_F03'
    '120281_F04'
    '130020_F03'
    '130021_F01'
    '130047_F02'
    '130113_F01'
    '130135_F03'
    '130136_F03'
    '130139_F03'
    '130172_F03'
    '130173_F03'
    '140061_F03'
    '160126_F01'
    };   % Subject folder name(s)
nsub=length(subjectlist);


for sub=1:nsub
%     P = [cwd filesep subjectlist{sub} filesep [] '.nii'];
    boldname = spm_select('FPList', [cwd filesep subjectlist{sub} filesep], '.*.nii');
    boldvol = spm_vol(boldname);
    boldimg = spm_read_vols(boldvol);

    % bolddir='D:\work\HIV_Tobacco\FunImg\040002_F04';
    % boldname=spm_select('FPList',bolddir,'.*REST.nii');
    % boldvol=spm_vol(boldname);
    % boldimg= spm_read_vols(boldvol); %if you use spm_read_vols to convert T1, there you should also use it to convert BOLD.
    for ii = 1:size(boldimg,4)
        outVol          = boldvol(ii);
        outVol.n        = [ii,1];
        outVol.fname    = [cwd filesep subjectlist{sub} filesep 'bold.img'];
        spm_write_vol(outVol,boldimg(:,:,:,ii));
    end
end
 