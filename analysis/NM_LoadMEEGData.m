function NM_LoadMEEGData()

global GLA_subject;
global GLA_trial_type;
global GLA_meeg_type;
disp(['Loading ' GLA_trial_type ' ' GLA_meeg_type ' data for ' GLA_subject '...']);
NM_LoadSubjectData();

% Default to use matching data in memory
global GLA_meeg_data;
if isempty(GLA_meeg_data) || ~strcmp(GLA_subject,GLA_meeg_data.settings.subject) ||...
        ~strcmp(GLA_trial_type,GLA_meeg_data.settings.trial_type) ||...
        ~strcmp(GLA_meeg_type,GLA_meeg_data.settings.meeg_type)
    
    % Load if we've made one
    f_name = NM_GetCurrentMEEGDataFilename();
    if exist(f_name,'file')
        load(f_name);

    % Otherwise initialize
    else
        NM_InitializeMEEGData();
    end
end
disp('Done.');
