function rsCVR_T1ROI_masks(path_mpr,name_mpr,cvrfile,rmskfile,outpath)
% calculate the CBF ROI average for three segmentation levels (Type1-L5, Type1-L3, and Type1-L2)
% yli20160627

% read the mutilevel_lookup_table.txt to determine the version of T1
% multiatlas and ROI lookups for all levels
roi_lookup_file = [path_mpr filesep 'multilevel_lookup_table.txt'];
roi_lookup_all  = read_roi_lookup_tabl(roi_lookup_file);

label_idx = str2num(char(roi_lookup_all{1,1}));
label_num = length(label_idx);
atlas_ver = [num2str(label_num)];


% read the roi name lists for the three segmentation levels
roitypes = {'Type1-L2';
            'Type1-L3';
            'Type1-L5'}; % order: type1-L2, type1-L3, type1-L5
roi_lookup_tbl = {roi_lookup_all{1,5};
                  roi_lookup_all{1,4};
                  roi_lookup_all{1,2}}; % orduer: type1-L2, type1-L3, type1-L5
              
roi_stats_file = spm_select('FPList',path_mpr,['^' name_mpr '.*' atlas_ver '.*corrected_stats.txt$']);
roi_stats_file = roi_stats_file(1,:);
roi_lists_info = read_roi_lists_info(roi_stats_file,roitypes);
roi_lists_info{3,2} = label_num;
roi_lists_info{3,3} = roi_lookup_all{1,2};



% get mask and CBF maps
P0 = spm_select('FPList',path_mpr,['^' name_mpr '.*' atlas_ver '.*Labels_M2.img$']);
roimaskfile = P0(1,:);

V0      = spm_vol(roimaskfile);
V1      = spm_vol(cvrfile);
V2      = spm_vol(rmskfile);
mskv    = spm_read_vols(V0);
rcvr    = spm_read_vols(V1); rcvr(isnan(rcvr)) = 0;
msk1    = spm_read_vols(V2); msk1(isnan(msk1)) = 0;

% Combine parcellations to Type1-L2 or Type1-L3 segmentations
[~,cvffname,~] = fileparts(cvrfile);
fresult  = [outpath filesep cvffname(1:end-14) '_rCVR_T1segmented_ROIs_mskonMPR.txt'];
fid        = fopen(fresult, 'wt');
coltitle = 'ROI analysis by %d major tissue types\n';
colnames = 'Index\tMask_name\tRegional_relative_CBF\tNumber_of_voxels\n';
colformt = '%d\t%s\t%1.2f\t%u\n';

% for tt = 1:length(roi_lists_info)-1
tt=2;
roi_tbl = roi_lookup_tbl{tt};
roi_lst = roi_lists_info{tt,3};

% label the mask with other level of segmentation
seg_num = length(roi_lst);
seg_idx = zeros(size(roi_lst));
segmask = zeros(size(mskv));

for ii = 1:seg_num
    seg_idx(ii) = ii;
    for kk = 1:label_num
        if strcmp(roi_lst{ii},roi_tbl{kk})
            segmask(mskv == label_idx(kk)) = ii;
        end
    end
end

frontal_mask = zeros(size(mskv));
parietal_mask = zeros(size(mskv));
temporal_mask = zeros(size(mskv));
limbic_mask = zeros(size(mskv));
occipital_mask = zeros(size(mskv));
insula_mask = zeros(size(mskv));
basalganglia_mask = zeros(size(mskv));
thalamus_mask = zeros(size(mskv));
basalforebrain_mask = zeros(size(mskv));
midbrain_mask = zeros(size(mskv));
cerebellum_mask = zeros(size(mskv));

frontal_mask(segmask == 1 | segmask == 2) = 1;
parietal_mask(segmask == 3 | segmask == 4) = 1;
temporal_mask(segmask == 5 | segmask == 6) = 1;
limbic_mask(segmask == 7  | segmask == 8) = 1;
occipital_mask(segmask == 9  |  segmask == 10) = 1;
insula_mask(segmask == 11  | segmask == 12) = 1;
basalganglia_mask(segmask == 13  | segmask == 14) = 1;
thalamus_mask(segmask == 15  |  segmask == 16) = 1;
basalforebrain_mask(segmask == 17  |  segmask == 18) = 1;
midbrain_mask(segmask == 19  |  segmask == 20) = 1;
cerebellum_mask(segmask == 21 |  segmask == 22) = 1;
% write out the segmented mask volume
outVol = V0;
outVol.fname = [outpath filesep name_mpr '_frontal_mask.img'];
spm_write_vol(outVol, frontal_mask);
outVol = V0;
outVol.fname = [outpath filesep name_mpr '_parietal_mask.img'];
spm_write_vol(outVol, parietal_mask);
outVol = V0;
outVol.fname = [outpath filesep name_mpr '_temporal_mask.img'];
spm_write_vol(outVol, temporal_mask);
outVol = V0;
outVol.fname = [outpath filesep name_mpr '_limbic_mask.img'];
spm_write_vol(outVol, limbic_mask);
outVol = V0;
outVol.fname = [outpath filesep name_mpr '_occipital_mask.img'];
spm_write_vol(outVol, occipital_mask);
outVol = V0;
outVol.fname = [outpath filesep name_mpr '_insula_mask.img'];
spm_write_vol(outVol, insula_mask);
outVol = V0;
outVol.fname = [outpath filesep name_mpr '_basalganglia_mask.img'];
spm_write_vol(outVol, basalganglia_mask);
outVol = V0;
outVol.fname = [outpath filesep name_mpr '_thalamus_mask.img'];
spm_write_vol(outVol, thalamus_mask);
outVol = V0;
outVol.fname = [outpath filesep name_mpr '_basalforebrain_mask.img'];
spm_write_vol(outVol, basalforebrain_mask);
outVol = V0;
outVol.fname = [outpath filesep name_mpr '_midbrain_mask.img'];
spm_write_vol(outVol, midbrain_mask);
outVol = V0;
outVol.fname = [outpath filesep name_mpr '_cerebellum_mask.img'];
spm_write_vol(outVol, cerebellum_mask);
% calculate the ROI CBF average and print to text file
fprintf(fid,coltitle,seg_num);
fprintf(fid,colnames);
for ii = 1:seg_num
    idxvox_seg = logical( (segmask == seg_idx(ii)) .* (msk1 > 0.5) ); % count vox only within brain mask (in case of partial coverage)
    seg_rcvr = mean( rcvr( idxvox_seg ) );
    seg_nvox = length( rcvr( idxvox_seg ) );
    seg_name = roi_lst{ii};
    fprintf(fid,colformt,seg_idx(ii),seg_name,seg_rcvr,seg_nvox);
end
fprintf(fid,'\n\n');
% end



% calculate the ROI CBF average of Type1-L5 segmentations and print
fprintf(fid,coltitle,label_num);
fprintf(fid,colnames);
for ii = 1:label_num
    idxvox_seg = logical( (mskv == label_idx(ii)) .* (msk1 > 0.5) );  % count vox only within brain mask (in case of partial coverage)
    seg_rcvr = mean( rcvr( idxvox_seg ) );
    seg_nvox = length( rcvr( idxvox_seg ) );
    seg_name = roi_lists_info{3,3}{ii};
    fprintf(fid,colformt,label_idx(ii),seg_name,seg_rcvr,seg_nvox);
end
fclose(fid);
end


function roi_lookup_tabl = read_roi_lookup_tabl(roi_lookup_file)
fileid = fopen(roi_lookup_file);
title  = textscan(fileid,'%s',1,...
                    'delimiter','\n');

roi_lookup_tabl = textscan(fileid,repmat('%s ',1,11),...
                    'delimiter',{' ','\b','\t'},'MultipleDelimsAsOne',1);
                
fclose(fileid);
end


function roi_lists_info = read_roi_lists_info(roi_stats_file,roitypes)
% return the level tag, # of rois, & roi list for each segmentation level

fileid  = fopen(roi_stats_file);
tmp     = textscan(fileid,'%s','delimiter','\n','whitespace','');
fclose(fileid);

alllines = tmp{:};
nline    = length(alllines);
ntype    = length(roitypes);

tmpinfo  = cell(ntype,3);
iline = 1;
while iline < nline
    splitStr = regexp(alllines{iline,1},'[ \t\b]','split');
    
    for itype = 1:ntype
        if strcmp(splitStr{1},roitypes{itype})
            tmpinfo{itype,1} = splitStr{1};
            
            roilist     = cell(1,1);
            roicount    = 0;
            iline       = iline + 2;
            while ~isempty(regexp(alllines{iline,1},'.img','ONCE'))
                roicount = roicount+1;
                
                splitStr2 = regexp(alllines{iline,1},'[ \t]','split');
                roilist{roicount,1} = splitStr2{2};
                
                iline = iline + 1;
            end
            
            tmpinfo{itype,2} = roicount;
            tmpinfo{itype,3} = roilist;
        end
    end
    
    iline = iline + 1;
end

roi_lists_info = tmpinfo;
end

