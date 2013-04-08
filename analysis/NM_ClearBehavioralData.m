function NM_ClearBehavioralData()

% Make sure we're up to date
NM_LoadSubjectData();

global GLA_behavioral_data; %#ok<NUSED>
clear global GLA_behavioral_data;
if exist(NM_GetCurrentBehavioralDataFilename(),'file')
    delete(NM_GetCurrentBehavioralDataFilename());
end

global GLA_subject;
disp(['Cleared ' NM_GetBehavioralDataType() ' behavioral data for ' GLA_subject '.']);


