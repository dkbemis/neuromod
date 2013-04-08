function NM_AnalyzeBehavioralData()

% Make sure we're ready
NM_LoadSubjectData({...
    {[NM_GetBehavioralDataType() '_behavioral_data_preprocessed'],1},...
    });

cfg = [];
cfg.data_type = 'behavioral';

% Get the rejections once
% Use the critical trials for now
global GLA_trial_type;
curr_tt = GLA_trial_type;
GLA_trial_type = 'word_5'; %#ok<NASGU>
cfg.rejections = NM_SuggestRejections();
GLA_trial_type = curr_tt;

% Analyze the measures
measures =  {'rt','acc'};
for m = 1:length(measures)
    cfg.measure = measures{m};
    NM_AnalyzeSingleValues(cfg);
end
