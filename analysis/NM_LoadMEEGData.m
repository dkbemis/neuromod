function NM_LoadMEEGData()

% Load up the subject data
global GLA_meeg_type;
disp('Loading data...');
NM_LoadSubjectData({{[GLA_meeg_type '_triggers_checked'],1}});
disp('Done.');

% Default to use matching data in memory
global GLA_meeg_data;
global GLA_subject;
global GLA_meeg_trial_type;
if isempty(GLA_meeg_data) || ~strcmp(GLA_subject,GLA_meeg_data.subject) ||...
        ~strcmp(GLA_meeg_trial_type,GLA_meeg_data.trial_type) ||...
        ~isfield(GLA_meeg_data,'data') || isempty(GLA_meeg_data.data)

    % Load if we've made one
    f_name = NM_GetCurrentMEEGDataFilename();
    if exist(f_name,'file')
        load(f_name);

    % "preprocess" the raw data to load as a single long trial
    else
        NM_InitializeMEEGData();
    end
end

