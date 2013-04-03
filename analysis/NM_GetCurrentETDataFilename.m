function f_name = NM_GetCurrentETDataFilename()

global GLA_trial_type;
global GLA_subject;
f_name = [NM_GetCurrentDataDirectory() '/analysis/' GLA_subject ...
    '/' GLA_subject '_' GLA_trial_type '_et_data.mat']; 
