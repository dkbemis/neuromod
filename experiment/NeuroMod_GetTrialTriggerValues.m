
% Lots of conditions, so we'll set them with care.
% All triggers will be the same for the stimuli except for the
%   last one. We'll have to adjust later to analyze other words.
%
% The generalized #s:
%   * stim 1-4:     101 + offset
%   * stim 5:       1 + offset
%   * delay:        2 + offset
%   * probe:        [3/4/5] + offset (match/nomatch_1/nomatch_2)

function [stim_trigger critical_trigger delay_trigger probe_trigger] =...
    NeuroMod_GetTrialTriggerValues(p_l, n_v, cond, answer)

% Put all the phrases low
num_conditions = 5;
num_phrase_types = 2;
num_critical_stim = 5;
trigger = 0;
if strcmp(p_l, 'list')
    trigger = num_conditions*num_phrase_types*num_critical_stim; 
end

% Then, divide by nouns or verbs
if strcmp(n_v, 'verb')
    trigger = trigger + num_conditions*num_critical_stim;
end

% Space the conditions
trigger = trigger + (cond-1)*num_critical_stim;

% And set the triggers
stim_trigger = trigger+101;
critical_trigger = trigger+1;
delay_trigger = trigger+2;

% Mark the different answers
switch answer
    case 'match'
        probe_trigger = trigger+3;

    case 'nomatch_1'
        probe_trigger = trigger+4;

    case 'nomatch_2'
        probe_trigger = trigger+5;
end        


