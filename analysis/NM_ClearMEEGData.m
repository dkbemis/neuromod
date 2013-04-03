function NM_ClearMEEGData()

% Make sure we're up to date
NM_LoadSubjectData();

global GLA_meeg_data; %#ok<NUSED>
clear global GLA_meeg_data;
if exist(NM_GetCurrentMEEGDataFilename(),'file')
    delete(NM_GetCurrentMEEGDataFilename());
end

global GLA_subject;
global GLA_trial_type;
global GLA_meeg_type;
disp(['Cleared ' GLA_meeg_type ' ' GLA_trial_type ' data for ' GLA_subject '.']);

