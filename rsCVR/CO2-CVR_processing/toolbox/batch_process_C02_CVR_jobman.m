clear all;
%GENERAL
cwd = '/Volumes/LINCOLN/liu/test_data/testy'; %Project path
subjectlist={
    'liz'
    'lincoln'
    };   % Subject folder name(s)
nsub=length(subjectlist);

for sub=1:nsub
    json_name = [cwd filesep subjectlist{sub} filesep 'rscvr_parameters.json'];
    disp(json_name);
    CVR_pipeline_jobman('/Volumes/LINCOLN/liu/rsCVR/scripts/commands', json_name)
    cd '/Volumes/LINCOLN/liu/rsCVR/C02-CVR_processing/toolbox'
end
