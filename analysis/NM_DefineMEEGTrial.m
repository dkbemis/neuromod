% Returns the definition of each trial in the data for later processing
% trl contains one row per trial and columns:
%   beginsample     endsample   offset
%
% For a trial with a 200 sample baseline that begins at sample 1000 and has
% 1000 samples after the trigger, the definition would be:
%   1000    2199    -200
%

function trl = NM_DefineMEEGTrial(cfg)


% Set the trials
trl = [];
trials = NM_GetTrials(cfg.run_id(end));
global GLA_subject_data;
global GLA_trial_type;
global GLA_meeg_type;
for t = 1:length(trials)
    cond = NM_GetTrialCondition(trials(t));
    trigger_time = NM_GetTrialTriggerTime(trials(t),GLA_meeg_type);
    trl(end+1,:) = [trigger_time + GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(1)...
        trigger_time + GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(2)-1 ...
        GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(1) cond]; %#ok<AGROW>
end


