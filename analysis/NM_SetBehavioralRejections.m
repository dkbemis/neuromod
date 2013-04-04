function NM_SetBehavioralRejections()

% Load the data
global GLA_subject;
disp(['Setting behavioral rejections for ' GLA_subject]);
NM_LoadBehavioralData();

global GLA_behavioral_data;

% See what we have to reject
GLA_behavioral_data.rejections = {};
types = {'outliers','timeouts','errors'};
for t = 1:length(types)
    GLA_behavioral_data.rejections(t).type = types{t};
    GLA_behavioral_data.rejections(t).trials = GLA_behavioral_data.data.(types{t});
end

% And save
NM_SaveBehavioralData();
disp('Done.');

