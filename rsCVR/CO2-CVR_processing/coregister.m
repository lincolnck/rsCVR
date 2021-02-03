targetdir=[cwd filesep subname filesep 'hc_bold' int2str(boldid(sub,1))];
targetfile=['meanhc_bold' int2str(boldid(sub,1)) '-001-001.img'];
target=[targetdir filesep targetfile];

for scan=2:nscan
    boldscan = ['rs_bold' int2str(boldid(sub,scan))];
    scandir  = [cwd filesep subname filesep boldscan];           
    source   = [scandir filesep 'mean' boldscan '-001-001.img'];
    other = spm_select('List',scandir,['r' boldscan '.*img']); %CR original datafiles
    cd(scandir);
    disp(sprintf(['coregister ' boldscan]));
    flags=defaults.coreg;
    mireg    = struct('VG',[],'VF',[],'PO','');
    mireg.VG = spm_vol(target);
    mireg.VF = spm_vol(source);
    mireg.PO = other;
    x  = spm_coreg(mireg.VG, mireg.VF,flags.estimate);
    M  = inv(spm_matrix(x));
    MM = zeros(4,4,size(mireg.PO,1));
    for j=1:size(mireg.PO,1)
        MM(:,:,j) = spm_get_space(deblank(mireg.PO(j,:)));
    end
    for j=1:size(mireg.PO,1)
        spm_get_space(deblank(mireg.PO(j,:)), M*MM(:,:,j));
    end
    P         = str2mat(mireg.VG.fname,mireg.PO);
    flg       = flags.write;
    flg.which = 1;
    flg.mean  = 0;
    spm_reslice(P,flg);
end

 