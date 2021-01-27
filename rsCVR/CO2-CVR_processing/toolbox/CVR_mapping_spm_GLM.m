function [EtCO2_mean,EtCO2_min,EtCO2_max] = CVR_mapping_spm_GLM(varargin)
% This function shifts the end-tidal time courses to global BOLD time course 
% Peiying Liu, July 12, 2017

path_temp = varargin{1};
name_cvr = varargin{2};
TR = varargin{3};
SmoothFWHMmm = varargin{4};
brnmsk = varargin{5};
brainMaskStruct = varargin{6};
% flag_o2 = varargin{_};
if nargin>6
    outpath_temp = varargin{7};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
flip_images = 0; %do you want SPM to flip your images?
num_slices = 29; %number of time bins, 16 is default
ref_slice = 1; % when data slice time corrected, take same ref_slice as ref_slice in slice timing. Otherwise, 1 is default
estimate = true; %if set to false, experiment will be modelled and data assigned, but computer will not automatically estimate results
HighPassFilterSec = Inf; %set to Inf to switch off. rule of thumb: 2 times length of 1 on/off cycle of 1 condition
convolve_model = 'Finite Impulse Response';
        % OPTIONS:'hrf'
        %         'hrf (with time derivative)'
        %         'hrf (with time and dispersion derivatives)'
        %         'Fourier set'
        %         'Fourier set (Hanning)'
        %         'Gamma functions'
        %         'Finite Impulse Response'
global_normalization = 'None'; %OPTIONS: 'Scaling' or 'None'
onset_unit = 'scans'; %OPTIONS: 'scans' or 'secs' for onsets conditions

P = spm_select('FPList',path_temp,['^s' int2str(SmoothFWHMmm) 'r' name_cvr '.*\.img']); %Altered YUS Dec 26, 2007   // might need to change
% cd(path_temp);
V = spm_vol(P);
nVol = size(V,1);
drift=[1:1:nVol]';

ses = 1; %number of sessions
%NEXT define all the conditions
ncon = 0; %number of conditions
% if flag_o2==1
%     ncontrast = 2; %number of statistical contrasts CHECK
%     conname = {'CO2','O2'}; %separate with commas, names of the condition
%     contrast_name{1} = 'CO2 Breathing';
%     contrast_name{2} = 'O2 Breathing';
%     contrast_content{1} = [1 0 0 0]; 
%     contrast_content{2} = [0 1 0 0]; 
%     rnam = {'CO2 breathing','O2 breathing','drift'};
%     % MODIFY: take shifted etco2 as input
%     fn = spm_select('List',path_temp,'Sync_EtCO2_timecourse.txt'); 
%     [r1] = textread([path_temp filesep fn],'%f');
%     fn = spm_select('List',path_temp,'Sync_EtO2_timecourse.txt'); 
%     [r2] = textread([path_temp filesep fn],'%f');    
% else
    ncontrast = 1; %number of statistical contrasts CHECK
    conname = {'CO2'}; %separate with commas, names of the condition
    contrast_name{1} = 'CO2 Breathing';
    contrast_content{1} = [1 0 0]; %I do not think SPM will pad zeros - you must place a zero for each column
    rnam = {'CO2 breathing','drift'};
    fn = spm_select('List',path_temp,'Sync_EtCO2_timecourse.txt'); 
    [r1] = textread([path_temp filesep fn],'%f');
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DO NOT CHANGE NEXT FEW LINES, GOTO "EDIT NEXT LINES"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin>6
    cd(outpath_temp);
else
    cd(path_temp);
end
disp(sprintf('fixed effect design matrix started'));
spm_get_defaults;
global defaults
defaults.mask.thresh = 0;
defaults.analyze.flip     = flip_images; % <<= Very important.  Relates to L/R
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

        SPM.Sess(ses).C.C = [];
        SPM.Sess(ses).C.name = {};

%         if flag_o2==1
%             SPM.Sess(ses).C.C = [r1 r2 drift];
%         else
            SPM.Sess(ses).C.C = [r1 drift];
%         end
        SPM.Sess(ses).C.name = rnam;
 		
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
    
% Generating CVR maps
%--------------------------------------------------------------------------
    thre = 4;
    nave=floor(nVol/thre);
    [Y,I]=sort(r1,'descend');
    EtCO2_min =mean(Y(end-nave:end));  % lowest 1/4 as baseline
    EtCO2_mean=mean(Y);
    EtCO2_max =mean(Y(1:nave));        % highest 1/4 for output
    fnBeta1 = spm_select('List',outpath_temp,'beta_.*01.nii');
    volBeta1 = spm_vol(fnBeta1);
    datBeta1 = spm_read_vols(volBeta1);
    fnBeta0 = spm_select('List',outpath_temp,['beta_.*0' int2str(length(contrast_content{1})) '.nii']);
    volBeta0 = spm_vol(fnBeta0);
    datBeta0 = spm_read_vols(volBeta0);
    
    % if nan values are found inside brainmask, rewrite the mask to exclude them
    nans = (isnan(datBeta0) | isnan(datBeta1));
    if sum(sum(sum(nans & brnmsk)))
        newbrainmask = brnmsk;
        idxs = find(nans & brnmsk);
        for i = 1:length(idxs)
            [row,col,hgt] = ind2sub(brainMaskStruct.matsize,idxs(i));
            newbrainmask(row,col,hgt) = 0;
        end
        write_ANALYZE(brnmsk,[path_temp filesep brainMaskStruct.brainMaskName '_unused.img'],...
            brainMaskStruct.matsize,brainMaskStruct.matresol,1,4,0,...
            brainMaskStruct.matcenter);
        write_ANALYZE(newbrainmask,[path_temp filesep brainMaskStruct.brainMaskName '.img'],...
            brainMaskStruct.matsize,brainMaskStruct.matresol,1,4,0,...
            brainMaskStruct.matcenter);
    end
    
    
    outvol = volBeta0;
    outvol.fname = ['HC_CVRmap_s' int2str(SmoothFWHMmm) '.img'];
    datOut = (datBeta1./(datBeta0-datBeta1*(EtCO2_mean-EtCO2_min)))*100.*brnmsk; % Generating CVR map
    spm_write_vol(outvol,datOut);

%     if flag_o2==1
%         [Y,I]=sort(r2,'descend');
%         EtO2_min =mean(Y(end-nave:end));  % lowest 1/4 as baseline
%         EtO2_mean=mean(Y);
% 
%         fnBeta2 = spm_select('List',outpath_temp,'beta_.*02.nii');
%         volBeta2 = spm_vol(fnBeta2);
%         datBeta2 = spm_read_vols(volBeta2);
%         
%         outvol2 = volBeta0;
%         outvol2.fname = ['HO_CBVmap_s' int2str(SmoothFWHMmm) '.img'];
%         datOut2 = (datBeta2./(datBeta0-datBeta2*(EtO2_mean-EtO2_min)))*100.*brainmask; % Generating CVR map
%         spm_write_vol(outvol2,datOut2);
%     end    
end
  
  