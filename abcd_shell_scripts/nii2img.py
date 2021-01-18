import nibabel as nb
import os


rootdir = '/Volumes/LincolnHardDrive/Lincoln/School/JHU/research/HIV_rsCVR/HIV_Tobacco/FunImg'
for subdir, dirs, files in os.walk(rootdir):
	for file in files:
		if file.endswith('.nii'):
			fname = os.path.join(rootdir, subdir, file)
			img = nb.load(fname)
			# newname = os.path.join(rootdir, subdir, 'image')
			nb.save(img, fname.replace('.nii', '.img'))
