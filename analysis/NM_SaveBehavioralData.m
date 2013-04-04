function NM_SaveBehavioralData()

global GLA_behavioral_data; %#ok<NUSED>
disp('Saving behavioral data...');

% Save the pieces
save(NM_GetCurrentBehavioralDataFilename(),'-struct','GLA_behavioral_data','-v7.3');
disp('Done');


