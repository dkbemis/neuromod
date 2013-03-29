% Helper to convert the .edf files to .asc files for reading.
%
% Expects the edf2asc converter in the eye_tracking_data folder

function NM_ConvertETData()

global GLA_subject;
disp(['Converting eyetracker data for ' GLA_subject '...']);

% Load / create the data
NM_LoadSubjectData({});

% Just run the edf2asc program on the files
global GLA_subject_data;
for r = 1:GLA_subject_data.parameters.num_runs
    c_cmd = [NM_GetCurrentDataDirectory() '/eye_tracking_data/edf2asc ' ...
        NM_GetCurrentDataDirectory() '/eye_tracking_data/' GLA_subject '/'...
        GLA_subject '_run_' num2str(r) '.edf'];
    system(c_cmd);
end    

% Resave...
NM_SaveSubjectData({{'et_data_converted',1}});
disp(['Eyetracker data for ' GLA_subject ' converted.']);

