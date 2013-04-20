%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_GetTrialCondition.m
%
% Notes:
%   * Helper to get a condition number from a trial structure 
%       - For baseline, will just give a contant number
%       - For run trials, we'll get back 1-10
%           - 1-5: Phrases; 6-10: Lists
%
% Inputs:
%   * trial: A trial from GLA_subject_data
%
% Outputs:
%   * The condition of that trial
%
% Usage: 
%   * cond = NM_GetTrialCondition(GLA_subject_data.data.runs(1).trials(1))
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
