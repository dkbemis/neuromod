function NM_SaveETData()

global GLA_et_data;
disp(['Saving ' GLA_et_data.settings.trial_type ' eye tracking data for '...
    GLA_et_data.settings.subject '...']);
save(NM_GetCurrentETDataFilename(),'GLA_et_data','-v7.3');
disp('Done');


