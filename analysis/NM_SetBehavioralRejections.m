function NM_SetBehavioralRejections()

% Nothing to do for the localizer
if strcmp(NM_GetBehavioralDataType(),'localizer')
    return;
end

% Load the data
global GLA_subject;
disp(['Setting ' NM_GetBehavioralDataType() ' behavioral rejections for ' GLA_subject]);
NM_LoadBehavioralData();

% See what we have to reject
global GLA_behavioral_data;
GLA_behavioral_data.rejections = {};
types = {'outliers','timeouts','errors'};
for t = 1:length(types)
    GLA_behavioral_data.rejections(t).type = types{t};
    GLA_behavioral_data.rejections(t).trials = GLA_behavioral_data.data.(types{t});
end

% And save
NM_SaveBehavioralData();
disp('Done.');

