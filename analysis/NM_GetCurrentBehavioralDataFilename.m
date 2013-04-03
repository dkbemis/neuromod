function f_name = NM_GetCurrentBehavioralDataFilename()

global GLA_subject;
f_name = [NM_GetCurrentDataDirectory() '/analysis/' GLA_subject ...
    '/' GLA_subject '_behavioral_data.mat']; 
