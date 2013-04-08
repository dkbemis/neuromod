function t_time = NM_GetTrialTriggerTime(trial, type)

global GLA_trial_type;
switch GLA_trial_type
    case 'blinks'
        t_time = trial.([type '_triggers'])(1).([type '_time']);
        
    case 'left_eye_movements'
        if trial.et_triggers(1).value == 3
            t_time = trial.([type '_triggers'])(1).([type '_time']);
        else
            t_time = trial.([type '_triggers'])(2).([type '_time']);            
        end
        
    case 'right_eye_movements'
        if trial.et_triggers(1).value == 4
            t_time = trial.([type '_triggers'])(1).([type '_time']);
        else
            t_time = trial.([type '_triggers'])(2).([type '_time']);            
        end
        
    case 'word_5'
        t_time = trial.([type '_triggers'])(5).([type '_time']);
        
    otherwise
        error('Unknown type.');
end


