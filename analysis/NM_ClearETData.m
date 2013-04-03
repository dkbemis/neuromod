function NM_ClearETData()

% Make sure we're up to date
NM_LoadSubjectData();

global GLA_et_data; %#ok<NUSED>
clear global GLA_et_data;
if exist(NM_GetCurrentETDataFilename(),'file')
    delete(NM_GetCurrentETDataFilename());
end

global GLA_subject;
global GLA_trial_type;
disp(['Cleared ' GLA_trial_type ' eye tracking data for ' GLA_subject '.']);


