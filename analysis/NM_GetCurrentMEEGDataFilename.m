function f_name = NM_GetCurrentMEEGDataFilename()

global GLA_subject;
global GLA_meeg_type;
global GLA_trial_type;
f_name = [NM_GetCurrentDataDirectory() '/analysis/' GLA_subject ...
    '/' GLA_subject '_' GLA_meeg_type '_' GLA_trial_type '_data.mat']; 
