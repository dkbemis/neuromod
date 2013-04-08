function NM_LoadBehavioralData()

% Load up the subject data
disp('Loading behavioral data...');
NM_LoadSubjectData();

% Default to use matching data in memory
global GLA_behavioral_data;
global GLA_subject;
if isempty(GLA_behavioral_data) || ...
        ~strcmp(GLA_subject,GLA_behavioral_data.settings.subject) ||...
        ~strcmp(NM_GetBehavioralDataType(),GLA_behavioral_data.settings.type) 

    % Load if we've made one
    f_name = NM_GetCurrentBehavioralDataFilename();
    if exist(f_name,'file')
        GLA_behavioral_data = load(f_name);

    % Or initialize
    else
        while 1
            ch = input([NM_GetBehavioralDataType() ' behavioral data for '...
                GLA_subject ' not found. Create (y/n)? '],'s');
            if strcmp(ch,'y')
                break;
            elseif strcmp(ch,'n')
                error('Data not loaded.');
            end
        end
        NM_InitializeBehavioralData();
    end
end
disp('Done.');
