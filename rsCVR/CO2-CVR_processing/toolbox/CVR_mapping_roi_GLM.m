function [roi_cvr,roi_delay,roi_cc]=CVR_mapping_roi_GLM(varargin)
% CVR_mapping_voxelwise_GLM(roitimecourse,etco2name,TR,delayrange);

roisig = varargin{1};
etco2name = varargin{2};
TR = varargin{3};
delayrange = varargin{4};
EtCO2_mean = varargin{5};
EtCO2_min = varargin{6};
roisig = [TR*(0:length(roisig)-1)',roisig];


nVol=length(roisig);
fid = fopen(etco2name);
% r1 = textscan(fid,'%f','delimiter','/t');
r1 = textscan(fid,'%f %f','delimiter',',');
etco2timecourse = [r1{1}, r1{2}];
fclose(fid);
% etco2timecourse = [r1{1}, r1{2}];

% Initial    
optDelay = cvr_func_findCO2delay(roisig, TR, etco2timecourse, delayrange,0,0,1);

delay_range = [optDelay-5, optDelay+5];
[optDelay, optEtCO2] = cvr_func_findCO2delay(roisig, TR, etco2timecourse, delay_range,0,0,0.1);
co2delay=optDelay;
    
roi_delay=co2delay;
[coefs, Yp, ~, ~] = cvr_func_glm(optEtCO2,roisig(:,2));
roi_cc = corr(Yp,roisig(:,2));

% thre = 4;
% nave=floor(nVol/thre);
% [Yco2,~]=sort(optEtCO2,'descend');
% EtCO2_min =mean(Yco2(end-nave:end));  % lowest 1/4 as baseline
% EtCO2_mean=mean(Yco2);

roi_cvr=(coefs(1)/(coefs(3)-coefs(1)*(EtCO2_mean-EtCO2_min)))*100;
