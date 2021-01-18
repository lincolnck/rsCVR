% Convert BOLD image

cwd = '/Volumes/LINCOLNHD/Lincoln/School/JHU/research/HIV_rsCVR/HIV_newsubjects/FunImg'; %Project path
%     t1dir='D:\work\HIV_Tobacco\T1Img\040002_F04';

subjectlist={
    '040003_F07'
    '040008_F07'
    '050001_F11'
    '050016_F06'
    '050028_F03'
    '050037_F06'
    '050043_F06'
    '050054_F05'
    '050059_F06'
    '050066_F05'
    '050075_F01'
    '050090_F04'
    '050135_F04'
    '050144_F04'
    '050164_F04'
    '050204_F06'
    '050207_F04'
    '060003_F09'
    '060012_F09'
    '060041_F04'
    '060047_F05'
    '060048_F09'
    '060068_F01'
    '060080_F06'
    '060089_F03'
    '060140_F03'
    '060147_F07'
    '060160_F04'
    '060163_F06'
    '060194_F06'
    '060198_F06'
    '070065_F02'
    '070098_F02'
    '080143_OGM01'
    '090067_OSS01'
    '100013_F02'
    '100033_OGM01'
    '100092_F01'
    '100103_OGM01'
    '100242_F03'
    '110225_F01'
    '120074_F02'
    '120147_F01'
    '120171_OGM01'
    '120191_F03'
    '120243_OSS01'
    '120249_F03'
    '120255_OSS01'
    '130019_F01'
    '130022_F05'
    '130033_F03'
    '130049_F01'
    '130050_F01'
    '130066_F01'
    '130073_F01'
    '130075_F05'
    '130076_F01'
    '130099_F01'
    '130143_F01'
    '130149_F01'
    '130168_F01'
    '140005_F01'
    '140017_F01'
    '140019_F02'
    '140044_F01'
    '140046_F01'
    '140056_F01'
    '140060_F01'
    '140065_F01'
    '140080_F01'
    '140081_F01'
    '140083_F01'
    '140085_F01'
    '140100_F01'
    '140113_F01'
    '140115_F01'
    '140121_F01'
    '140129_F01'
    '140138_F01'
    '140143_F01'
    '140173_F01'
    '150002_F01'
    '150015_F01'
    '150018_F01'
    '150021_F01'
    '150025_F01'
    '150035_F01'
    '150039_F01'
    '150040_F01'
    '150042_F04'
    '150045_F01'
    '150046_F01'
    '150078_F01'
    '150079_F01'
    '150080_F01'
    '150084_F01'
    '150098_F01'
    '150105_F01'
    '150106_F01'
    '150107_F01'
    '150110_F01'
    '150111_F01'
    '150112_F01'
    '150113_F02'
    '160014_F01'
    '160018_F01'
    '160021_F01'
    '160112_F02'
    '160130_F01'
    '160143_F01'
    '160149_F01'
    '160151_F01'
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
 