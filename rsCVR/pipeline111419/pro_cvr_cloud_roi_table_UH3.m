% collecting CVR/Volume values from txt files
cwd = '/Volumes/HIV/HIV/HIV_newsubjects/FunImg';
subjectlist={
    '040002_F04'
    '040003_F07'
    '040008_F07'
    '050001_F11'
    '050016_F06'
    '050028_F03'
    '050037_F06'
    '050043_F06'
    '050054_F05'
    '050056_F05'
    '050059_F06'
    '050066_F05'
    '050075_F01'
    '050090_F04'
    '050096_F03'
    '050101_F06'
    '050135_F04'
    '050137_F07'
    '050144_F04'
    '050164_F04'
    '050204_F06'
    '050207_F04'
    '060003_F09'
    '060005_F07'
    '060012_F09'
    '060028_F04'
    '060041_F04'
    '060047_F05'
    '060048_F09'
    '060068_F01'
    '060080_F06'
    '060089_F03'
    '060091_F05'
    '060096_F05'
    '060097_F04'
    '060140_F03'
    '060147_F07'
    '060160_F04'
    '060163_F06'
    '060167_F06'
    '060172_S04'
    '060181_F11'
    '060194_F06'
    '060198_F06'
    '070022_F05'
    '070065_F02'
    '070073_F04'
    '070074_F03'
    '070081_F04'
    '070098_F02'
    '070118_F02'
    '080069_F03'
    '080093_F03'
    '080143_OGM01'
    '090067_OSS01'
    '090157_F03'
    '100013_F02'
    '100033_OGM01'
    '100092_F01'
    '100103_OGM01'
    '100242_F03'
    '100294_F04'
    '100303_F04'
    '110047_F03'
    '110050_F04'
    '110054_F03'
    '110196_OSS01'
    '110202_F03'
    '110205_OSS01'
    '110223_OSS01'
    '110225_F01'
    '110255_F04'
    '120040_F03'
    '120042_F02'
    '120074_F02'
    '120117_F01'
    '120147_F01'
    '120171_OGM01'
    '120172_F03'
    '120191_F03'
    '120229_F03'
    '120243_OSS01'
    '120249_F03'
    '120255_OSS01'
    '120281_F04'
    '130019_F01'
    '130020_F03'
    '130021_F01'
    '130022_F05'
    '130033_F03'
    '130047_F02'
    '130049_F01'
    '130050_F01'
    '130066_F01'
    '130073_F01'
    '130075_F05'
    '130076_F01'
    '130099_F01'
    '130113_F01'
    '130135_F03'
    '130136_F03'
    '130139_F03'
    '130143_F01'
    '130149_F01'
    '130168_F01'
    '130172_F03'
    '130173_F03'
    '140005_F01'
    '140017_F01'
    '140019_F02'
    '140044_F01'
    '140046_F01'
    '140056_F01'
    '140060_F01'
    '140061_F03'
    '140065_F01'
    '140080_F01'
    '140081_F01'
    '140083_F01'
    '140085_F01'
    '140100_F01'
    '140113_F01'
    '140115_F01'
    '140121_F01'
    '140129_F01'
    '140138_F01'
    '140143_F01'
    '140173_F01'
    '150002_F01'
    '150015_F01'
    '150018_F01'
    '150021_F01'
    '150025_F01'
    '150035_F01'
    '150039_F01'
    '150040_F01'
    '150042_F04'
    '150045_F01'
    '150046_F01'
    '150078_F01'
    '150079_F01'
    '150080_F01'
    '150084_F01'
    '150098_F01'
    '150105_F01'
    '150106_F01'
    '150107_F01'
    '150110_F01'
    '150111_F01'
    '150112_F01'
    '150113_F02'
    '160014_F01'
    '160018_F01'
    '160021_F01'
    '160112_F02'
    '160126_F01'
    '160130_F01'
    '160143_F01'
    '160149_F01'
    '160151_F01'
    };   % Subject folder name(s)
nsub=length(subjectlist);

% minco2=zeros(nsub,4);
% deltaco2=zeros(nsub,4);
% co2_CVR=zeros(nsub,4);
for sub=1:nsub
    subid=subjectlist{sub};
%     subdir=[cwd filesep subid filesep subid '_cvr']; %JHU
    subdir=[cwd filesep subid filesep 'out'];  %UKY 
%     subdir=[cwd filesep 'VCIDUH3Y1' subid '_CVR_result'];  %UTHSCSA 
    
    cvrfile = spm_select('FPList',subdir, 'rR_rCVR_T1segmented_ROIs_mskonMPR.txt');
    fid=fopen(cvrfile);
%         for i=1:3
%             line=fgetl(fid);
%         end
%         s= textscan(line, '%f %s %f %f', 1);
%         wbcvr(sub)=s{3};
    for i=1:26
        line=fgetl(fid);
    end
    for i=1:22
        line=fgetl(fid);
        s= textscan(line, '%f %s %f %f', 1);
        voxnum(i)=s{4};
        cvrval(i)=s{3};            
    end
    for i=1:38
        line=fgetl(fid);
    end
    for i=1:164
        j=i+22;
        line=fgetl(fid);
        s= textscan(line, '%f %s %f %f', 1);
        voxnum(j)=s{4};
        cvrval(j)=s{3};
    end
    for i=1:11
        line=fgetl(fid);
    end
    for i=1:72
        k=i+22+164;
        line=fgetl(fid);
        s= textscan(line, '%f %s %f %f', 1);
        voxnum(k)=s{4};
        cvrval(k)=s{3};
    end
    for i=1:4
        line=fgetl(fid);
    end
    for i=1:2
        l=i+22+164+72;
        line=fgetl(fid);
        s= textscan(line, '%f %s %f %f', 1);
        voxnum(l)=s{4};
        cvrval(l)=s{3};
    end
    for i=1:1
        line=fgetl(fid);
    end
    for i=1:20
        m=i+22+164+72+2;
        line=fgetl(fid);
        s= textscan(line, '%f %s %f %f', 1);
        voxnum(m)=s{4};
        cvrval(m)=s{3};
    end
    for i=1:4
        line=fgetl(fid);
    end
    for i=1:2
        n=i+22+164+72+2+20;
        line=fgetl(fid);
        s= textscan(line, '%f %s %f %f', 1);
        voxnum(n)=s{4};
        cvrval(n)=s{3};
    end
    for i=1:1
        line=fgetl(fid);
    end
    for i=1:6
        m=i+22+164+72+2+20+2;
        line=fgetl(fid);
        s= textscan(line, '%f %s %f %f', 1);
        voxnum(m)=s{4};
        cvrval(m)=s{3};
    end
    fclose(fid);
    for roi=1:144
        index=[(roi-1)*2+1,roi*2];
        vox=voxnum(index);
        cvr=cvrval(index);
        roicvr(sub,roi)=sum(double(vox).*cvr)/sum(double(vox));
        roivox(sub,roi)=sum(double(vox));
    end
end
check = [roicvr roivox];

writematrix(check,[cwd filesep 'results_all_subs_vol_cvr.csv']);
writecell(subjectlist,[cwd filesep 'subject_list_all_subs.csv']);