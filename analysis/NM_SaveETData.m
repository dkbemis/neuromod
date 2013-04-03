function NM_SaveETData()

global GLA_et_data; %#ok<NUSED>
global GLA_trial_type;
global GLA_subject;
disp(['Saving ' GLA_trial_type ' eye tracking data for ' GLA_subject '...']);
save(NM_GetCurrentETDataFilename(),'GLA_et_data','-v7.3');
disp('Done');


