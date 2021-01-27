function boldAndEtco2Path = zach_generateBoldAndEtco2Txt(name_avgboldPath,...
    boldSyncedEtco2Path, TR, workDir, outDir)
% Inputs:
%       name_avgboldPath : str
%           The full path pointing to the text file containing the average
%           BOLD signal of the whole brain.
%       boldSyncedEtco2Path : str
%           The full path pointing to the text file containing the etco2
%           signal (syncronized in time with the BOLD signal)
%       TR : double
%           The repetition time of the scan being processed
%       workDir : str
%           The full path pointing to the main processing directory
%       outDir : str
%           The full path pointing to the directory containing the files
%           returned to the user
%
% Ouputs:
%       boldAndEtco2Path : str
%           The full path pointing to the text file containing both the
%           average BOLD signal of the whole brain and the etco2 signal
%           (truncated and interpolated to the BOLD signal time).

fid = fopen(name_avgboldPath);
r1 = textscan(fid,'%f %f','delimiter',',');
fclose(fid); 
boldData = [r1{1}, r1{2}];

fid = fopen(boldSyncedEtco2Path);
r1 = textscan(fid,'%f %f','delimiter',',');
fclose(fid); 
etco2Data = [r1{1}, r1{2}];

nVol = size(boldData,1);

interpolatedEtco2 = cvr_func_interpTimecourse(etco2Data,0,nVol,TR);

data2Write = [boldData, interpolatedEtco2];

boldAndEtco2Path = [workDir filesep 'boldAndEtco2Signal.txt'];

fid = fopen(boldAndEtco2Path, 'w');

headerline = ['Time (s), BOLD (a.u.), EtCO2 (mmHg)' char(10)];
fprintf(fid, headerline);
for i = 1:size(data2Write, 1)
    values = data2Write(i,:);
    line = [num2str(values(1)), ', ' num2str(values(2)), ', ',...
        num2str(values(3)), char(10)];
    fprintf(fid, line);
end
fprintf(fid, '');

fclose(fid);

copyfile(boldAndEtco2Path, outDir, 'f')
