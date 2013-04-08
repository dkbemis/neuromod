function NM_LoadETData()

global GLA_subject;
global GLA_trial_type;
disp(['Loading ' GLA_trial_type ' eye tracking data for ' GLA_subject '...']);
NM_LoadSubjectData();

% Default to use matching data in memory
global GLA_et_data;
if isempty(GLA_et_data) || ~strcmp(GLA_subject,GLA_et_data.settings.subject) ||...
        ~strcmp(GLA_trial_type,GLA_et_data.settings.trial_type)

    % Load if we've made one
    f_name = NM_GetCurrentETDataFilename();
    if exist(f_name,'file')
        GLA_et_data = load(f_name);

    % "preprocess" the raw data to load as a single long trial
    else
        while 1
            ch = input([GLA_trial_type ' et data for '...
                GLA_subject ' not found. Create (y/n)? '],'s');
            if strcmp(ch,'y')
                break;
            elseif strcmp(ch,'n')
                error('Data not loaded.');
            end
        end
        NM_InitializeETData();
    end
end
disp('Done.');
