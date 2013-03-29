% Returns the definition of each trial in the data for later processing
% trl contains one row per trial and columns:
%   beginsample     endsample   offset
%
% For a trial with a 200 sample baseline that begins at sample 1000 and has
% 1000 samples after the trigger, the definition would be:
%   1000    2199    -200
%
% NOTE: To add extra outputs, set function [trl, event] = ... (I think)

function trl = NM_DefineMEEGRunTrial(cfg)

% Let's get all the critical words for now...
trl = [];
global GLA_subject_data;
global GLA_meeg_type;
for t = 1:length(GLA_subject_data.runs(cfg.run_num).trials)
    
    % Get the condition
    cond = GLA_subject_data.runs(cfg.run_num).trials(t).parameters.cond;
    if strcmp(GLA_subject_data.runs(cfg.run_num).trials(t).parameters.p_l,'list')
        cond = cond+5;
    end
    
    % NOTE: Samples are 1-1 with ms for now.
    % Just get the critical trigger.
    trigger_time = GLA_subject_data.runs(cfg.run_num).trials(t).([GLA_meeg_type '_triggers'])(...
        GLA_subject_data.parameters.num_critical_stim).([GLA_meeg_type '_time']);
    trl(end+1,:) = [trigger_time+cfg.pre_stim trigger_time+cfg.post_stim-1 cfg.pre_stim cond]; %#ok<AGROW>
end
