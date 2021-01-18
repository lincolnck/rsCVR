function zach_resetRotationMatrix(fl1, matInfo)

% rewrite all files in fl1 to have the same rotation matrix (matInfo)

for jj = 1:length(fl1)
    p_img = spm_vol(fl1{jj});
    v_img = spm_read_vols(p_img);
    p_img.mat = matInfo; % acquired at Process Additional Values subheading
    spm_write_vol(p_img,v_img);
end
