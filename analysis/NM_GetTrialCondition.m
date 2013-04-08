function cond = NM_GetTrialCondition(trial)

global GLA_trial_type;
switch GLA_trial_type
    case 'blinks'
        cond = 2;
            
    case 'right_eye_movements'
        cond = 3;

    case 'left_eye_movements'
        cond = 4;
        
    case 'word_5';
        cond = trial.log_stims(1).cond;
        if strcmp(trial.log_stims(1).p_l,'list')
            cond = cond + 5;
        end
        
    otherwise
        error('Unknown type');
end
