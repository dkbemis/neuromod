function NM_SetETRejections()

% Load the data
global GLA_subject;
global GLA_trial_type;
disp(['Setting eye tracking rejections for ' GLA_trial_type ' for ' GLA_subject]);
NM_LoadETData();

% See what we want to reject
global GLA_et_data;
GLA_et_data.rejections = {};
types = {'blink','saccade'};
for t = 1:length(types)
    GLA_et_data.rejections(t).trials = getPossibleRejections(types{t});

    % No blinks, for blinks
    if strcmp(GLA_trial_type,'blinks')
        GLA_et_data.rejections(t).type = ['no_' types{t}];       

    % No saccades for eye movements
    elseif (strcmp(GLA_trial_type,'left_eye_movements') ||...
                strcmp(GLA_trial_type,'right_eye_movements')) && ... 
                strcmp(types{t},'saccade')
        GLA_et_data.rejections(t).type = ['no_' types{t}];       
    else
        GLA_et_data.rejections(t).type = types{t};
    end
end
NM_SaveETData();
disp('Done.');


function rej = getPossibleRejections(type)

% Get any trial with a start or end
rej = [];
global GLA_trial_type;
global GLA_et_data;
starts = GLA_et_data.data.([type '_starts']);
ends = GLA_et_data.data.([type '_starts']);
for t = 1:length(GLA_et_data.data.cond)
    
    % Want no blinks if averaging blinks
    if strcmp(GLA_trial_type,'blinks') 
        if isempty(starts{t}) || isempty(ends{t})
            rej(end+1) = t; %#ok<AGROW>
        end
    % No saccades for eye movements
    elseif (strcmp(GLA_trial_type,'left_eye_movements') ||...
                strcmp(GLA_trial_type,'right_eye_movements')) && ... 
                strcmp(type,'saccade')
        if isempty(starts{t}) || isempty(ends{t})
            rej(end+1) = t; %#ok<AGROW>
        end
    else
        if ~isempty(starts{t}) || ~isempty(ends{t})
            rej(end+1) = t; %#ok<AGROW>
        end
    end
end
