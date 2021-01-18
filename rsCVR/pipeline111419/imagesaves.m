% Open and display RS-rCVR

clear all;
%GENERAL
cwd = '/Volumes/LINCOLNHD/ABCD_BOLD_ANALYZE'; %Project path
subjectlist={
    'NDARINV01RGTWD2'
    'NDARINV01Z8HAPV'
    'NDARINV022ZVCT8'
    'NDARINV02UVMTY7'
    'NDARINV040B4TRC'
    'NDARINV05X0LM1N'
    'NDARINV06BKAHN5'
    'NDARINV06DP74KL'
    'NDARINV07XG8391'
    'NDARINV0889M0JE'
    'NDARINV08GBDG8X'
    'NDARINV08YFFYY2'
    'NDARINV09AEBLZH'
    'NDARINV09N9CRAL'
    'NDARINV0CCMBWPE'
    'NDARINV0E350J5D'
    'NDARINV0EXY6KFW'
    'NDARINV0GPKYMDC'
    'NDARINV0H05G0TR'
    'NDARINV0HVEVD01'
    'NDARINV0JRNB4U4'
    'NDARINV0K37T6VD'
    'NDARINV0LN1KD13'
    'NDARINV0P4XZMZA'
    'NDARINV0TTJA443'
    'NDARINV0UERLJJY'
    'NDARINV0UV5WZUN'
    'NDARINV0V1TYBKE'
    'NDARINV0VY70352'
    'NDARINV0YLLNXRL'
    'NDARINV10FDVE0L'
    'NDARINV10HWA6YU'
    'NDARINV10K9CVX2'
    'NDARINV10TEADFM'
    'NDARINV145EPB4G'
    'NDARINV14C1N3KZ'
    'NDARINV155U91DU'
    'NDARINV15MX84A5'
    'NDARINV165NRNVG'
    'NDARINV170X8DA0'
    'NDARINV174DUV2F'
    'NDARINV17UL1T8L'
    'NDARINV19FYU534'
    'NDARINV19LRBB0U'
    'NDARINV1A1Y0V5X'
    'NDARINV1A8C7PRA'
    'NDARINV1ACWERC3'
    'NDARINV1BZ0TUT9'
    'NDARINV1CCL4UAD'
    'NDARINV1CTLWW8V'
    'NDARINV1DZ2VF5K'
    'NDARINV1ERNH60J'
    'NDARINV1F6MVGKL'
    'NDARINV1F6UNTXD'
    'NDARINV1FDC7YAJ'
    'NDARINV1FRN7VDM'
    'NDARINV1GKF0X1J'
    'NDARINV1H7NZZZ9'
    'NDARINV1HKCTUW1'
    'NDARINV1JC1WW5Y'
    'NDARINV1JGK90HZ'
    'NDARINV1JZ17724'
    'NDARINV1KZTEZF5'
    'NDARINV1L1ZCWL5'
    'NDARINV1LMCP4YF'
    'NDARINV1MM7DZYV'
    'NDARINV1P46E6AP'
    'NDARINV1P7L5P3B'
    'NDARINV1PATDM0H'
    'NDARINV1PE0ZVR4'
    'NDARINV1PMXF3DY'
    'NDARINV1TWMU0JK'
    'NDARINV1U4C4M56'
    'NDARINV1VXVRPHJ'
    'NDARINV1WVHVGH7'
    'NDARINV1X4F1YB5'
    'NDARINV1Z7RDZ4Y'
    'NDARINV1ZK55NV1'
    'NDARINV1ZPJCKVC'
    'NDARINV20CX5AWW'
    'NDARINV21CN9606'
    'NDARINV21KEUZ1N'
    'NDARINV22C4YKXN'
    'NDARINV22GRHDPN'
    'NDARINV22LW15TV'
    'NDARINV230CTHZE'
    'NDARINV248BF2KE'
    'NDARINV249JM0NY'
    'NDARINV24BT0Y26'
    'NDARINV24D005FC'
    'NDARINV25ANBT4A'
    };   % Subject folder name(s)
nsub=length(subjectlist);

for sub=1:nsub
   
%     c1meanfname =[cwd filesep subjectlist{sub} filesep  'c1meanbold.nii'];
%     c1meanimg = niftiread(c1meanfname);
% 
%     gm_seg_zfname = [cwd filesep subjectlist{sub} filesep 'gm_seg_z.nii'];
%     gm_seg_zimg = niftiread(gm_seg_zfname);

%% Fix color to hot and display range 0-3
    rs_rcvrfname = [cwd filesep subjectlist{sub} filesep 'RS_CVRmap/RS_rCVRmap_bold_7.img'];
    if ~isfile(rs_rcvrfname)
        disp("file doesn't exist")
        continue;
    end
    rs_rcvrimg = (niftiread(rs_rcvrfname));
    rs_rcvrimg(isnan(rs_rcvrimg)) = 0;
%     image_list = {};
%     for i = 1:7
%         fname = [cwd filesep subjectlist{sub} filesep 'bold_' int2str(i) '.png'];
%         if ~isfile(fname)
%             continue;
%         end
%         image_list{end+1} = fname;
%     end
%     
%     all_montage = montage(image_list);
%     
%     imwrite(all_montage.CData, [cwd filesep subjectlist{sub} filesep 'all_rscvrs.png']);
%     gm_seg_z_smoothedfname = [cwd filesep subjectlist{sub} filesep 's8gm_seg_z.nii'];
%     gm_seg_z_smoothedimg = niftiread(gm_seg_z_smoothedfname);
%     
%     c1smoothedfname = [cwd filesep subjectlist{sub} filesep 's8c1meanbold.nii'];
%     c1smoothedimg = niftiread(c1smoothedfname);
%     
%     figure;
%     m = montage(imrotate(rs_rcvrimg(:,:,40),90));
%     montage_IM = m.CData;
%     imwrite(montage_IM, [cwd filesep subjectlist{sub} filesep 'bold_7.png']);
end