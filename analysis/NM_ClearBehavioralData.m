function NM_ClearBehavioralData()

global GLA_behavioral_data; %#ok<NUSED>
clear global GLA_behavioral_data;
if exist(NM_GetCurrentBehavioralDataFilename(),'file')
    delete(NM_GetCurrentBehavioralDataFilename());
end

global GLA_subject;
disp(['Cleared behavioral data for ' GLA_subject '.']);


