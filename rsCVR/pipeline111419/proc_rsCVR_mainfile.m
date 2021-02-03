clear all;
%GENERAL
cwd = '/Volumes/LINCOLN/liu/test_data'; %Project path
subjectlist={
    'liz'
    'linc'
    };   % Subject folder name(s)
nsub=length(subjectlist);

% BOLD imaging parameters
tr=0.72;   % TR, in seconds
% matsize = [70 70 56];
% matresol = [3 3 3];

% Analysis parameters
cutfreq = 0.1164;    % Cutoff frequency range, in Hz. The recommended value is 0.1164
SmoothFWHMmm = 8;    % Gaussian smoothing kernal, in mm. The Recommended value is 8
templatedir = '/Users/lincolnkartchner/spm12/tpm';  % SPM folder that contains the TPM.nii file
count = 1;
for sub=1:nsub
    hdrname=[cwd filesep subjectlist{sub} filesep 'bold' filesep 'bold_3_0.hdr'];
    hdr=analyze75info(hdrname);
    matsize=double(hdr.Dimensions(1:3));
    matresol=double(hdr.PixelDimensions);
    filename=[cwd filesep subjectlist{sub} filesep 'bold' filesep 'bold_3_0.img'];
%     avg_c02_filename=[cwd filesep subjectlist{sub} filesep 'c02_cvr' filesep ];
    count =  count+1;
    if ~isfile(filename)                                                                                                                                                                                                                                                 
        disp("file doesn't exist")
        continue;
    end
    rsCVR_singlesub_analysis(filename, avg_c02_filename, tr, cutfreq, matsize, matresol, SmoothFWHMmm,templatedir)
    cd '/Volumes/LINCOLN/liu/rsCVR/pipeline111419'
end
