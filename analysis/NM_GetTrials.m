function trials = NM_GetTrials(run_num)

global GLA_subject_data;
global GLA_trial_type;
switch GLA_trial_type
    case 'blinks'
        trials = GLA_subject_data.baseline.blinks;
        
    case 'left_eye_movements'
        trials = GLA_subject_data.baseline.eye_movements;
        
    case 'right_eye_movements'
        trials = GLA_subject_data.baseline.eye_movements;
        
    case 'word_5'
        trials = GLA_subject_data.runs(run_num).trials;
        
    otherwise
        error('Unknown type');
end
