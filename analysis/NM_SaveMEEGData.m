function NM_SaveMEEGData()

global GLA_meeg_data;
disp(['Saving ' GLA_meeg_data.settings.trial_type ' ' ...
    GLA_meeg_data.settings.meeg_type ' data for ' ...
    GLA_meeg_data.settings.subject '...']);
save(NM_GetCurrentMEEGDataFilename,'-struct','GLA_meeg_data','-v7.3');
disp('Done');


