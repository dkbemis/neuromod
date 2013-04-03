function NM_SaveBehavioralData()

global GLA_behavioral_data; %#ok<NUSED>
disp('Saving behavioral data...');
save(NM_GetCurrentBehavioralDataFilename(),'GLA_behavioral_data','-v7.3');
disp('Done');


