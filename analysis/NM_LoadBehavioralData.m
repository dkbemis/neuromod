function NM_LoadBehavioralData()

% Load up the subject data
disp('Loading behavioral data...');
NM_LoadSubjectData();

% Default to use matching data in memory
global GLA_behavioral_data;
global GLA_subject;
if isempty(GLA_behavioral_data) || ~strcmp(GLA_subject,GLA_behavioral_data.settings.subject) 

    % Load if we've made one
    f_name = NM_GetCurrentBehavioralDataFilename();
    if exist(f_name,'file')
        GLA_behavioral_data = load(f_name);

    % "preprocess" the raw data to load as a single long trial
    else
        NM_InitializeBehavioralData();
    end
end
disp('Done.');
