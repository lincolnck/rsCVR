% Main file for ABCD preprocessing split into three steps, outlined below.
% It is probably a good idea to check the results of each step before
% proceeding. The following will prepare the images to be processed further
% by both the rsCVR pipeline and the T1 segmentation pipeline on MRICloud.


%% Convert DICOM to ANALYZE

sourceDir = "/Users/lincolnkartchner/Desktop/ABCD";
targetDir = "/Users/lincolnkartchner/Desktop/ABCD/out";
dcm2nii = "/Volumes/LINCOLN/liu/rsCVR/abcd_preprocessing/dcm2nii";

tgz_dcm2analyze(sourceDir, targetDir, dcm2nii);

%% Gather images into subject-specific directories

os = "mac";

groupSubjects(targetDir, os);

%% Create T1 groups for uploading to MRICloud

groupSize = 1;
imageType = "T1";
zipFiles = "Y";
groupsDir = "T1_groups";

createT1groups(targetDir,groupSize,imageType,zipFiles,groupsDir);