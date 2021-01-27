function [cvr_WB, cvr_WB_path] =...
    zach_wholeBrainCvrCalc(name_avgboldPath, boldSyncedEtco2Path, TR,...
    EtCO2_mean, EtCO2_min, varargin)
% zach_wholeBrainCvrCalc. Takes the text files containing the avergae whole
% brain BOLD signal and syncronized EtCO2 signal and outputs the whole
% brian CVR. Also writes this value to a text file if outdir is given.
%
% Inputs:
%       name_avgboldPath : str
%           The full path pointing to the text file containing the average
%           BOLD signal of the whole brain.
%       boldSyncedEtco2Path : str
%           The full path pointing to the text file containing the
%           EtCO2 signal syncronized with the average BOLD signal of the
%           whole brain.
%       TR : double
%           The time of repetition in seconds.
%       EtCO2_mean : double
%           Average of etco2 curve syncd with WB bold signal.
%       EtCO2_min : double
%           Average of lower 25% of etco2 curve syncd with WB bold signal.
%       varargin{1} : str
%           The full path of the directory where the whole brain cvr text
%           file will be written (optional).
%
% Ouputs:
%       cvr_WB : double
%           The subject's average whole-brain CVR.


    fid = fopen(name_avgboldPath);
    r1 = textscan(fid,'%f %f','delimiter',',');
    fclose(fid); 
    boldData = [r1{1}, r1{2}];
    
    fid = fopen(boldSyncedEtco2Path);
    r1 = textscan(fid,'%f %f','delimiter',',');
    fclose(fid); 
    etco2Data = [r1{1}, r1{2}];

    nVol = size(boldData,1);
    
    optEtCO2 = cvr_func_interpTimecourse(etco2Data,0,nVol,TR);
    
    [coefs, Yp, ~, ~] = cvr_func_glm(optEtCO2,boldData(:,2));
    cc_val = corr(Yp,boldData(:,2));

%     thre = 4;
%     nave=floor(nVol/thre);
%     [Yco2,~]=sort(optEtCO2,'descend');
%     EtCO2_min =mean(Yco2(end-nave:end));  % lowest 1/4 as baseline
%     EtCO2_mean=mean(Yco2);

    cvr_WB=(coefs(1)/(coefs(3)-coefs(1)*(EtCO2_mean-EtCO2_min)))*100;
    
    cvr_WB_path = '';
    
    if ~isempty(varargin)
        workDir = varargin{1};
        cvr_WB_path = [workDir filesep 'cvr_result.txt'];
        fid = fopen(cvr_WB_path,'w');
        fprintf(fid, ['CVR results' char(10)]);
        fprintf(fid, ['Index', char(9), 'ROI_name', char(9),...
            'CVR(%%BOLD/mmHg)', char(9), 'BOLD_EtCO2_cc', char(9),...
            'Notes', char(10)]);
        if cc_val <= 0.6
            warnMsg = 'LOW CC';
        else
            warnMsg = '';
        end
        fprintf(fid, ['1' char(9) 'WholeBrain' char(9) num2str(cvr_WB)...
            char(9) num2str(cc_val) char(9) warnMsg char(10) char(10)...
            char(10)]);
        fclose(fid);
    end

end