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
        GLA_meeg_data = load(f_name);

    % Otherwise initialize
    else
        while 1
            ch = input([GLA_trial_type ' ' GLA_meeg_type ' data for '...
                GLA_subject ' not found. Create (y/n)? '],'s');
            if strcmp(ch,'y')
                break;
            elseif strcmp(ch,'n')
                error('Data not loaded.');
            end
        end
        NM_InitializeMEEGData();
    end
end
disp('Done.');
