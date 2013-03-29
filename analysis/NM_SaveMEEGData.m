function NM_SaveMEEGData()

global GLA_meeg_data; %#ok<NUSED>
disp('Saving data...');
save(NM_GetCurrentMEEGDataFilename,'GLA_meeg_data','-v7.3');
disp('Done');


