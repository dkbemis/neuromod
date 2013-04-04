% Returns the definition of each trial in the data for later processing
% trl contains one row per trial and columns:
%   beginsample     endsample   offset
%
% For a trial with a 200 sample baseline that begins at sample 1000 and has
% 1000 samples after the trigger, the definition would be:
%   1000    2199    -200
%

function trl = NM_DefineMEEGTrial(cfg)

% Set the trials we're using
global GLA_subject_data;
global GLA_trial_type;
switch GLA_trial_type
    case 'blinks'
        trials = GLA_subject_data.baseline.blinks;
        trig_values = 1;
        
    case 'word_5'
        trials = GLA_subject_data.runs(str2double(cfg.run_id(end))).trials;
        trig_values = 5;
        
    case 'word_4'
        trials = GLA_subject_data.runs(str2double(cfg.run_id(end))).trials;
        trig_values = 4;
        
    case 'word_3'
        trials = GLA_subject_data.runs(str2double(cfg.run_id(end))).trials;
        trig_values = 3;
        
    case 'word_2'
        trials = GLA_subject_data.runs(str2double(cfg.run_id(end))).trials;
        trig_values = 2;
        
    case 'word_1'
        trials = GLA_subject_data.runs(str2double(cfg.run_id(end))).trials;
        trig_values = 1;    
        
    case 'delay'
        trials = GLA_subject_data.runs(str2double(cfg.run_id(end))).trials;
        trig_values = 6;
        
    case 'target'
        trials = GLA_subject_data.runs(str2double(cfg.run_id(end))).trials;
        trig_values = 7;
        
    case 'all'
        trials = GLA_subject_data.runs(str2double(cfg.run_id(end))).trials;
        trig_values = 1;

    otherwise
        error('Unknown type');
end

% Set the trials
trl = [];
global GLA_meeg_type;
for t = 1:length(trials)

    % Add the events
    triggers = trials(t).([GLA_meeg_type '_triggers']);
    for i = trig_values

        % Get the condition
        cond = getCondition(trials(t));

        % NOTE: Samples are 1-1 with ms for now.
        % Just get the critical trigger.
        trigger_time = triggers(i).([GLA_meeg_type '_time']);
        trl(end+1,:) = [trigger_time + GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(1)...
            trigger_time + GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(2)-1 ...
            GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(1) cond]; %#ok<AGROW>
    end
end

function cond = getCondition(trial)

global GLA_trial_type;
if strcmp(GLA_trial_type,'blinks')
    cond = 2;
else

    % Get the condition
    cond = trial.parameters.cond;
    if strcmp(trial.parameters.p_l,'list')
        cond = cond+5;
    end
end


