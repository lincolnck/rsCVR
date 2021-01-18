function rsCVR_singlesub_analysis(filename,tr, cutfreq, matsize, matresol, SmoothFWHMmm,templatedir)

warning off;
global defaults;
defaults = spm_get_defaults;

[bolddir,boldname]=fileparts(filename);

fs=1/tr;
fcutoff = cutfreq/(fs/2);  %Hz
[b,a]= butter(2,fcutoff); 


%%%%%%%%%%%%% realign bold images %%%%%%%%%%%%%%%%%%%%%%%%%%%%
P = filename;
V = spm_vol(P);
FlagsC = struct('quality',defaults.realign.estimate.quality,'fwhm',5,'rtm',0);
spm_realign(V, FlagsC);
which_writerealign = 2;
mean_writerealign = 1;
FlagsR = struct('interp',defaults.realign.write.interp,...
    'wrap',defaults.realign.write.wrap,...
    'mask',defaults.realign.write.mask,...
    'which',which_writerealign,'mean',mean_writerealign);
spm_reslice(P,FlagsR);
clear P V;
disp('done realignment');


%%%%%%%%%%%%%%% smoothing %%%%%%%%%%%%%%%%%%%%%%%%%%%%
P = spm_select('FPList',bolddir,['^r' boldname '.*\.img']);
V = spm_vol(P);
[pth,nam,ext] = fileparts(V(1).fname);
fnameIn       = fullfile(pth,[nam ext]);
fname         = fullfile(pth,['s' int2str(SmoothFWHMmm) nam ext]);
spm_smooth(fnameIn,fname,SmoothFWHMmm);
clear P V;
disp('done smoothing');


%%%%%%%%%%%%%%% get brain mask %%%%%%%%%%%%%%%%%%%%%%%
imgtpm=[templatedir filesep 'TPM.nii'];
meanimg = spm_select('FPList',bolddir,['^mean' boldname '.*\.img']);
[brnmsk, brnmsk_clcu] = bold_getBrainMask(imgtpm,meanimg);
write_ANALYZE(brnmsk,[bolddir filesep 'brainmask.img'],matsize,matresol,1,4,0);
write_ANALYZE(brnmsk_clcu,[bolddir filesep 'brainmask_calculation.img'],matsize,matresol,1,4,0);


%%%%%%%%%%%%%%%% linear detrend and filtering %%%%%%%%%%%
outdir = [bolddir filesep 'filtered'];mkdir(outdir);
% load image
P = spm_select('FPList',bolddir,['^s' int2str(SmoothFWHMmm) 'r' boldname '.*\.img']);
V = spm_vol(P);
img_4D = spm_read_vols(V);
handles.img_4D = img_4D;
handles.brainMask = brnmsk;
mask = handles.brainMask;
% detrend and filter
brainVox = find(mask == max(mask(:)));
imgSize = size(mask);
detrendLinear_4D = zeros(size(handles.img_4D));
filteredImg_4D = zeros(size(handles.img_4D));
for vox = 1:length(brainVox)
    [row,col,sl] = ind2sub(imgSize,brainVox(vox));
    TS1 = double(squeeze(handles.img_4D(row,col,sl,:)));
    sig = detrend(TS1);
    meansig = mean(TS1-sig);
    detrendLinear_4D(row,col,sl,:) = sig + meansig;
    filteredTS1 = filtfilt(b,a,double(sig));
    filteredImg_4D(row,col,sl,:) = filteredTS1+meansig;
end
% write filtered images
for dyn=1:size(filteredImg_4D,4)
    if dyn<10
        na=['00' int2str(dyn)];
    elseif dyn<100
        na=['0' int2str(dyn)];
    else
        na=int2str(dyn);
    end
    dtempname=[outdir filesep 'ds' int2str(SmoothFWHMmm) 'r' boldname '_' na '.img'];
    write_ANALYZE(detrendLinear_4D(:,:,:,dyn),dtempname,matsize,matresol,1,16,0);
    ftempname=[outdir filesep 'fds' int2str(SmoothFWHMmm) 'r' boldname '_' na '.img'];
    write_ANALYZE(filteredImg_4D(:,:,:,dyn),ftempname,matsize,matresol,1,16,0);
end
disp('done filtering');


%%%%%%%%%%%%%%Calculate average timecourse %%%%%%%%%%%
dynnum=size(filteredImg_4D,4);
wbsignal=zeros(dynnum,1);
for i=1:dynnum
    %read in a volume
    data1 = filteredImg_4D(:,:,:,i);
    wbsignal(i)  = mean(data1(brnmsk_clcu>0));
end
tcname=[outdir filesep 'AvgWB_BOLD_filtered.txt'];
save(tcname, 'wbsignal','-ascii');


%%%%%%%%%%%%%%% SPM GLM analysis to generate CVR map%%%%%%%%%%%%%%%%%%%%%%%%
flip_images = 0; %do you want SPM to flip your images?
defaults.analyze.flip     = flip_images;
num_slices = 16; %number of time bins, 16 is default
ref_slice = 1; % when data slice time corrected, take same ref_slice as ref_slice in slice timing. Otherwise, 1 is default
estimate = true; %if set to false, experiment will be modelled and data assigned, but computer will not automatically estimate results
HighPassFilterSec = Inf; %set to Inf to switch off. rule of thumb: 2 times length of 1 on/off cycle of 1 condition
convolve_model = 'Finite Impulse Response';
global_normalization = 'None'; %OPTIONS: 'Scaling' or 'None'
onset_unit = 'scans'; %OPTIONS: 'scans' or 'secs' for onsets conditions
ncon = 0; %number of conditions
conname = {'WB avergae','m1' 'm2' 'm3' 'm4' 'm5' 'm6' 'drift'}; %separate with commas, names of the condition
ncontrast = 1; %number of statistical contrasts CHECK
contrast_name{1} = 'WB reference';
contrast_content{1} = [1 0 0 0 0 0 0 0 0];
swd=[bolddir filesep 'RS_CVRmap' ];mkdir(swd);
cd(swd);

% motion
fm=spm_select('FPList',bolddir,['^rp' '.*\.txt']);
mtmp=textread(fm,'%f');
allm=reshape(mtmp,6,length(mtmp)/6)';
motion=allm(1:dynnum,:);
fmotion=zeros(size(motion));
for mi=1:6
    fmotion(:,mi)=filtfilt(b,a,motion(:,mi));
end
drift=[1:1:dynnum]'-mean([1:1:dynnum]);

P = spm_select('FPList',outdir,['^fds' int2str(SmoothFWHMmm) 'r' boldname '.*\.img']); %Altered YUS Dec 26, 2007   // might need to change
V = spm_vol(P);
nVol = size(V,1);

r1=wbsignal;
refsig=(r1-mean(r1))/(2*norm(r1-mean(r1))/sqrt(nVol));  % make reference signal unitless

ses = 1; %number of sessions
%NEXT define all the conditions
ncon = 0; %number of conditions
clear SPM;

%number of scans and sessions
SPM.nscan = nVol;
%start session loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EDIT NEXT LINES....
%specification of condition onsets and durations
%if condition onsets and durations are the same for each subject, the
%if-end loop can be deleted
if (ses == 1) %&& (sub == 1)  %NOTE: using if/else loops you can specify different onsets for each sub/ses
    consets{1} = [15 135 255 375]; %normally multiple events, e.g.  [29.42366, 65.42366, 101.42366,];
    consets{2} =   [540 900 1260]; %normally multiple events, e.g.  [29.42366, 65.42366, 101.42366,];
    condur{1} = [50 50 50 50]; %normally multiple durations, e.g.  [18, 18, 18];
    condur{2} = [180 180 180]; %normally multiple durations, e.g.  [18, 18, 18];
end;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%END OF THE SECTION THAT NEEDS EDITING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%basis functions and timing parameters
%----------------------------------------------------------------------
SPM.xBF.name = convolve_model;
%SPM.xBF.order = 3; %order of basis set - not used for hrf
SPM.xBF.order = 4;
SPM.xBF.length = 32; %length in seconds - not used for hrf
SPM.xBF.T = num_slices;
SPM.xBF.TO = ref_slice;
SPM.xBF.UNITS = onset_unit;
SPM.xBF.Volterra = 1; %OPTIONS: 1 or 2 = order of convolution
%trial specification: onsets, duration and parameters for modulation
%------------------------------------------------------------------
for con=1:ncon
    SPM.Sess(ses).U(con).name = {conname{con}};
    SPM.Sess(ses).U(con).ons = consets{con};
    SPM.Sess(ses).U(con).dur = condur{con};
    SPM.Sess(ses).U(con).P(1).name = 'none';
end
%modified AUG 2008, stop the pop-up from SPM, if there are zero
%contrasts specified.
if(ncon==0)
    SPM.Sess(ses).U = {};
end

%design (user specified covariates, eg movement parameters) - other
%regressors
%--------------------------------------------------------------------------
%note: inclusion of movement parameters makes unwarping somewhat redundant,
%but done here to illustrate facilities of SPM

%SPM.Sess(ses).C.C = refsig;
SPM.Sess(ses).C.C = [refsig fmotion drift];
SPM.Sess(ses).C.name = conname;

%global normalization: OPTIONS: 'Scaling' or 'None'
%--------------------------------------------------------------------------
SPM.xGX.iGXcalc = global_normalization;

%low frequency confound: highpass cutoff (secs) [Inf = no filtering]
%--------------------------------------------------------------------------

SPM.xX.K(ses).HParam = Inf; % Also modified in line 43

%intrinsic autocorrelations: OPTIONS: 'none' or 'AR(1) + w'
%--------------------------------------------------------------------------
SPM.xVi.form       = 'none'; %in SPM2 use AR(1), in SPM999 many used SPM.xVi.form = 'none';

%specify data: matrix of filenames and TR
%--------------------------------------------------------------------------
SPM.xY.P = P;
SPM.xY.RT = tr;

%--------------------------------------------------------------------------

%configure designmatrix
%--------------------------------------------------------------------------
SPM = spm_fmri_spm_ui(SPM);

if estimate
    
    %estimate parameters
    %--------------------------------------------------------------------------
    SPM = spm_spm(SPM);
    
    %add extra contrasts
    %--------------------------------------------------------------------------
    
    for contrast=1:ncontrast
        cx{contrast} = contrast_content{contrast};
        cname{contrast} = contrast_name{contrast};
    end
    
    %make contrasts
    SPM.xCon = spm_FcUtil('Set',cname{1},'T','c',cx{1}(:),SPM.xX.xKXs);
    for (jx=1:ncontrast)
        SPM.xCon(jx) = spm_FcUtil('Set',cname{jx},'T','c',cx{jx}(:),SPM.xX.xKXs);
    end;
    
    %--------------------------------------------------------------------------
    spm_contrasts(SPM);
end %if estimate


% Generating CVR maps
%--------------------------------------------------------------------------
fnBeta1 = spm_select('FPList',swd,'beta_.*01.nii');
volBeta1 = spm_vol(fnBeta1);
datBeta1 = spm_read_vols(volBeta1);
fnBeta0 = spm_select('FPList',swd,['beta_.*0' int2str(length(contrast_content{1})) '.nii']);
volBeta0 = spm_vol(fnBeta0);
datBeta0 = spm_read_vols(volBeta0);

datOut = datBeta1./datBeta0*100.*brnmsk; % Generating CVR map
V0 = volBeta1;
V0.fname = [swd filesep 'RS_sCVRmap_' boldname '.img']; %Write corresponding image as a new image
spm_write_vol(V0,datOut);

% Relative CVR map for further analysis
wbmean=nanmean(datOut(brnmsk>0));
V0 = volBeta1;
V0.fname = [swd filesep 'RS_rCVRmap_' boldname '.img']; %Write corresponding image as a new image
spm_write_vol(V0,datOut./wbmean);
disp('done GLM');
clear SPM;

% Spatial Correlation between CVR map and GM segmentation
% -------------------------------------------------------------------------
clear P V;
% Load brain mask
P = spm_select('FPList',bolddir,'brainmask.img');
V = spm_vol(P);
brain_mask = spm_read_vols(V);

clear P V;

SmoothFWHMmm_max = 16;
fileID = fopen('r_value.txt','a');
for i=2:2:SmoothFWHMmm_max
    % Load GM segmentation
    P = spm_select('FPList',bolddir,['c1mean' boldname '.nii']);
    V = spm_vol(P);
    
    gm_seg = spm_read_vols(V);
    gm_seg_z = norminv(gm_seg);

    %smooth gm_segmentation FWHM = 8
    [pth,nam,ext] = fileparts(V(1).fname);
    fnameIn       = fullfile(pth,[nam ext]);
    fname         = fullfile(pth,['s' int2str(i) nam ext]);
    spm_smooth(fnameIn,fname,i);

    clear P V;

    P = spm_select('FPList', bolddir, ['s' int2str(i) nam ext]);
    V = spm_vol(P);
    gm_segmentation_smoothed = spm_read_vols(V);
    % Load CVR map
    swd=[bolddir filesep 'RS_CVRmap'];
    cd(swd);

    P = spm_select('FPList',swd,['RS_rCVRmap_' boldname '.img']);
    V = spm_vol(P);
    cvr_map = spm_read_vols(V);

    % Constrain GM segmentation and CVR map to brain mask

    gm_segmentation_smoothed = gm_segmentation_smoothed.*brain_mask;
    gm_seg_z = gm_seg_z.*brain_mask;
    cvr_map = cvr_map.*brain_mask;
    
    gm_segmentation_smoothed_scaled = rescale(gm_segmentation_smoothed, 0, 3);
    cvr_map_scaled = rescale(cvr_map, 0, 3);

    [r, p, rl, ru] = corrcoef(gm_segmentation_smoothed, cvr_map, 'rows', 'complete');
    [r_scaled, p_scaled, rl_scaled, ru_scaled] = corrcoef(gm_segmentation_smoothed_scaled, cvr_map_scaled, 'rows', 'complete');
    r_z = corrcoef(gm_seg_z, cvr_map, 'rows', 'complete');

    % write r value as txt file
    fprintf(fileID, '%i \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \t %f \n', i, r(2,1), p(2,1), rl(2,1), ru(2,1), r_scaled(2,1), p_scaled(2,1), rl_scaled(2,1), ru_scaled(2,1), r_z(2,1));
end
fclose(fileID);

disp('Current Dataset Complete!');
end