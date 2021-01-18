function outDir = rsCVR_pipeline_v2(commandLocation, paras)
% CVR_pipeline The core of rsCVR-MRICloud. This function executes every step
% of the pipeline's processing. It is run by the wrapper function
% CVR_pipeline_jobman.
%
% Inputs:
%       commandLocation : str
%           The full path pointing to the 'commands' directory. This
%           directory contains the IMG_apply_AIR_tform1,
%           IMG_change_res_info, and TPM.nii files.
%       paras : str
%           The full path pointing to the scan's json file. This file
%           contains all user-specified inputs for rsCVR_pipeline. On
%           rsCVR-MRICloud the json file is created by the web page based on
%           the user's uploaded files and specifications.
%
% Ouputs:
%       outDir : str
%           The full path pointing to the pipeline's output files.



%% Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% load all user-input and other parameters from .json file
cvr_paras = loadjson(paras);

% get BOLD scan file name (.hdr file)                          - user input
boldHdrFileName = cvr_paras.userInput.boldHdrFileName;
% get BOLD scan file name (.img file)                          - user input
boldImgFileName = cvr_paras.userInput.boldImgFileName;
% get output of T1 Multiatlas Segmentation (.zip file)         - user input
multiatlasFileName = cvr_paras.userInput.multiatlasFileName;
% get time of repitition (in seconds)                          - user input
TR = cvr_paras.userInput.TR;

% get cutoff frequency value                                      - private
cutfreq = cvr_paras.private.cutfreq;
% get FWHM of gaussian smoothing kernal (in mm)                   - private
SmoothFWHMmm = cvr_paras.private.SmoothFWHMmm;
% get brain mask file name                                        - private
brainMaskName = cvr_paras.private.brainMaskName;

% project main path                                             - directory
mainPath = cvr_paras.Dir.mainPath;
% workspace file name                                           - directory
workDirFileName = cvr_paras.Dir.workDirFileName;
% output file name                                              - directory
outputFileName = cvr_paras.Dir.outputFileName;
% output main path
outPath = cvr_paras.Dir.outPath;



%% General Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get directory of TPM.nii
imgTpmDir = [commandLocation filesep 'TPM.nii'];

% if there is no mprage data, set mprageFlag off to disable all mprage
% processing
mprageFlag = 1;
if isempty(multiatlasFileName)
    mprageFlag = 0;
end

% create workDir in mainPath, which will contain all interim files; this
% directory is designated for all of CVR-MRICloud's processing
workDir = [mainPath filesep workDirFileName];
if exist(workDir,'dir')
    rmdir(workDir,'s');
end
mkdir(workDir)

% create outDir in mainPath, which will contain the outputs of the pipeline
outDir = outPath;
if exist(outDir,'dir')
    rmdir(outDir,'s');
end
mkdir(outDir)



%% Relocate Input Files to workDir %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% move bold image, co2 trace, and segented mprage (if present) to workDir
copyfile([mainPath filesep boldHdrFileName],workDir,'f')
copyfile([mainPath filesep boldImgFileName],workDir,'f')
if mprageFlag
    copyfile([mainPath filesep multiatlasFileName],workDir,'f')
end



%% Process Additional Values %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get name of bold scan file without .img or .hdr extension
boldname = boldImgFileName(1:end-4);

% get bold scan's matrix size, matrix center, and voxel resolution (in mm)
fn_swrbold  = [workDir filesep boldImgFileName];
[~, matsize, matresol] = read_hdrimg(fn_swrbold);
matcenter = matsize./2;

% unzip mprage data if given
if mprageFlag
    [t1Path] = zach_unzipT1(workDir,multiatlasFileName);
end

% Get .mat info from first dynamic (to be used during coregistration)
P = spm_vol(fn_swrbold);
matInfo = P(1).mat;



%% Global Parameter Setup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% go to workDir set up spm global defaults
cd(workDir);
spm_get_defaults;
global defaults;
defaults.mask.thresh = 0;
warning off;

fs=1/TR;
fcutoff = cutfreq/(fs/2);  %Hz
[b,a]= butter(2,fcutoff); 



%% Realign BOLD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get original bold scan
P = cell(1,1);    
P{1}   = spm_select('List',workDir,['^' boldname '.*img']);

% get the bold scan's data
V       = spm_vol(P); 
V       = cat(1,V{:});

% realign bold scan
disp(sprintf(['realigning ' boldname]));
FlagsC = struct('quality',defaults.realign.estimate.quality,...
    'fwhm',5,'rtm',0);
spm_realign(V, FlagsC);

% reslice bold scan
which_writerealign = 2;
mean_writerealign = 1;
FlagsR = struct('interp',defaults.realign.write.interp,...
    'wrap',defaults.realign.write.wrap,...
    'mask',defaults.realign.write.mask,...
    'which',which_writerealign,'mean',mean_writerealign); 
spm_reslice(P,FlagsR);
clear P V;
disp('done realignment');



%% Smooth BOLD %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get realigned and resliced bold scan (prefixed with 'r')
P = cell(1,1);
P{1}   = spm_select('List',workDir,['^r' boldname '.*img']);

% get the scan's data
V       = spm_vol(P);
V       = cat(1,V{:});

% smooth scan (creates a 4D smoothed scan prefixed with 's' and the FWHM of
% the gaussian kernel)
disp(sprintf(['smoothing ' boldname]));
[pth,nam,ext] = fileparts(V(1).fname);
fnameIn       = fullfile(pth,[nam ext]);
fname         = fullfile(pth,['s' int2str(SmoothFWHMmm) nam ext]);          
spm_smooth(fnameIn,fname,SmoothFWHMmm);
clear P V;
disp('done smoothing');


%% Generate brain mask %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get average smoothed bold scan (prefixed with 'mean')
meanimg = spm_select('List',workDir,['^mean' boldname '.*img']);

% get brain masks using average bold scan
[brnmsk, brnmsk_clcu] = bold_getBrainMask(imgTpmDir,meanimg);

% save masks as 'BrainMask.img' and 'BrainMask_calulation.img'
write_ANALYZE(brnmsk,[brainMaskName '.img'],matsize,matresol,1,4,0,...
    matcenter);
write_ANALYZE(brnmsk_clcu,[brainMaskName '_calulation.img'],matsize,...
    matresol,1,4,0,matcenter);
bold_maskPath = [workDir filesep brainMaskName '.img'];

% make brainMaskStruct to potentially update brainMask
brainMaskStruct.brainMaskName = brainMaskName;
brainMaskStruct.matsize = matsize;
brainMaskStruct.matresol = matresol;
brainMaskStruct.matcenter = matcenter;


%% Linear detrend and filtering %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tmpdir = [workDir filesep 'filtered'];mkdir(tmpdir);
% load image
P = spm_select('FPList',workDir,['^s' int2str(SmoothFWHMmm) 'r' boldname '.*img']);
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
%     dtempname=[tmpdir filesep 'ds' int2str(SmoothFWHMmm) 'r' boldname '_' na '.img'];
%     write_ANALYZE(detrendLinear_4D(:,:,:,dyn),dtempname,matsize,matresol,1,16,0);
    ftempname=[tmpdir filesep 'fds' int2str(SmoothFWHMmm) 'r' boldname '_' na '.img'];
    write_ANALYZE(filteredImg_4D(:,:,:,dyn),ftempname,matsize,matresol,1,16,0);
end
disp('done filtering');
clear P V;



%% Calculate average timecourse %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dynnum=size(filteredImg_4D,4);
wbsignal=zeros(dynnum,1);
for i=1:dynnum
    %read in a volume
    data1 = filteredImg_4D(:,:,:,i);
    wbsignal(i)  = mean(data1(brnmsk_clcu>0));
end
tcname=[workDir filesep 'AvgWB_BOLD_filtered.txt'];
save(tcname, 'wbsignal','-ascii');



%% SPM GLM analysis to generate CVR map%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
swd=[workDir filesep 'RS_CVRmap' ];mkdir(swd);
cd(swd);

% motion
fm=spm_select('FPList',workDir,['^rp' '.*\.txt']);
mtmp=textread(fm,'%f');
allm=reshape(mtmp,6,length(mtmp)/6)';
motion=allm(1:dynnum,:);
fmotion=zeros(size(motion));
for mi=1:6
    fmotion(:,mi)=filtfilt(b,a,motion(:,mi));
end
drift=[1:1:dynnum]'-mean([1:1:dynnum]);

P = spm_select('FPList',tmpdir,['^fds' int2str(SmoothFWHMmm) 'r' boldname '.*\.img']); %Altered YUS Dec 26, 2007   // might need to change
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
SPM.xY.RT = TR;

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

% reload brainmask in case it was updated
brnmsk=loadimage([workDir filesep brainMaskName '.img'],1);

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

% Create and save new whole-brain mask if RS-sCVR contains NaN values
wholeBrainMask = brnmsk;
wholeBrainMask(isnan(datOut)) = 0;
V0 = volBeta1;
V0.fname = [swd filesep brainMaskName '.img'];
spm_write_vol(V0,wholeBrainMask);

% Relative CVR map for further analysis
wbmean=mean(datOut(wholeBrainMask>0));
V0 = volBeta1;
V0.fname = [swd filesep 'RS_rCVRmap_' boldname '.img']; %Write corresponding image as a new image
spm_write_vol(V0,datOut./wbmean.*wholeBrainMask);
disp('done GLM');
clear SPM P V;
bold_cvrPath = [swd filesep 'RS_rCVRmap_' boldname '.img'];
bold_maskPath = [swd filesep brainMaskName '.img'];


%% Skip Further Processing if MPRAGE Data is Omitted %%%%%%%%%%%%%%%%%%%%%%
if mprageFlag
    
    % get T1 file name
    t1ImgSizeFile = spm_select('List',t1Path,'.*[^mni].imgsize$');
    t1ImgName = t1ImgSizeFile(1:end-8);
    
    % get skull-stripped MPRAGE brain scan
    mpr_brain = ASL_mprageSkullstrip(t1Path, t1ImgName);
       
    % coregister maps to skull-stripped MPRAGE
    target = mpr_brain;
    source = [workDir filesep 'mean',boldImgFileName(1:end-4) '.img'];
    other = { bold_cvrPath;          
        bold_maskPath};
    asl_coreg12(target,source,other);
    
    % reset the .mat of each hdr/img to ensure consistent BOLDspace rotation
    % matrix (coregistration changes the rotation matrix of source and other)
    fl1 = {   [workDir filesep 'mean',boldImgFileName(1:end-4) '.img'];
        bold_cvrPath;
        bold_maskPath};
    zach_resetRotationMatrix(fl1, matInfo);
    
    % get coregistered cvr map paths
    [pth,nme,ext] = fileparts(bold_cvrPath);
    mpr_cvrPath = [pth filesep 'r' nme ext];
    
    % get coregistered brain mask path
    [pth,nme,ext] = fileparts(bold_maskPath);
    mpr_maskPath = [pth filesep 'r' nme ext];
    
    % Convert to MNI Space 
%     mni_cvrPath = zach_mniNormalize(mpr_cvrPath, commandLocation, t1Path);
%     mni_maskPath = zach_mniNormalize(mpr_maskPath, commandLocation, t1Path);
%     [pth,nme,ext] = fileparts(mni_cvrPath);
%     ASL_downSampleMNI(mni_cvrPath,[pth filesep nme '_2mm' ext])

    % ROI analysis in MPR space
%     rsCVR_T1ROI_rCVRaverage(t1Path,t1ImgName,mpr_cvrPath,outDir);
    rsCVR_T1ROI_rCVRaverage_mpr(t1Path,t1ImgName,mpr_cvrPath,mpr_maskPath,outDir)
end



%% Send to Output %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% send BOLD space BAT map                                         TO OUTPUT
copyfile(bold_cvrPath,[outDir filesep 'rsCVR_' boldname '_relCVR_BOLDspace.img'])
[pth,nme] = fileparts(bold_cvrPath);
copyfile([pth filesep nme '.hdr'],[outDir filesep 'rsCVR_' boldname '_relCVR_BOLDspace.hdr'])

if mprageFlag
    copyfile(mpr_cvrPath,[outDir filesep 'rsCVR_' boldname '_relCVR_MPRspace.img'])
    [pth,nme] = fileparts(mpr_cvrPath);
    copyfile([pth filesep nme '.hdr'],[outDir filesep 'rsCVR_' boldname '_relCVR_MPRspace.hdr'])

%     copyfile(mni_cvrPath,[outDir filesep 'rsCVR_' boldname '_relCVR_MNIspace.img'])
%     [pth,nme] = fileparts(mni_cvrPath);
%     copyfile([pth filesep nme '.hdr'],[outDir filesep 'rsCVR_' boldname '_relCVR_MNIspace.hdr'])
%     copyfile([pth filesep nme '_2mm.img'],[outDir filesep 'rsCVR_' boldname '_relCVR_MNIspace_2mm.img'])
%     copyfile([pth filesep nme '_2mm.hdr'],[outDir filesep 'rsCVR_' boldname '_relCVR_MNIspace_2mm.hdr'])
end



%% Finish and cleanup %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all
disp('Processing Completed')
end