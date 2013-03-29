% Helper that gives us all trials that fit a certain filter

function f_trials = NM_FilterTrials(filter)

global GLA_subject_data;
f_trials = {};
for r = 1:length(GLA_subject_data.runs)
    for t = 1:length(GLA_subject_data.runs(r).trials)

        % Check the filters
        if matchesFilter(GLA_subject_data.runs(r).trials(t),filter)
            f_trials = NM_AddStructToArray(GLA_subject_data.runs(r).trials(t),f_trials);
        end
    end
end


function matches = matchesFilter(trial, filter)

matches = 1;
if isempty(filter)
    return;
end

% Check all the fields in the filter
chk_f = fieldnames(filter);
for f = 1:length(chk_f)
    if isempty(filter.(chk_f{f}))
        continue;
    end
    
    % If our trial is not in the filter list, filter it
    matches = 0;
    for v = 1:length(filter.(chk_f{f}))
        
        % NOTE: Expect to have checked trials by now
        chk = filter.(chk_f{f}){v};
        if ischar(trial.parameters.(chk_f{f}))
            if strcmp(chk,trial.parameters.(chk_f{f}))
                matches = 1;
                break;
            end
            
        elseif isnumeric(trial.parameters.(chk_f{f}))
            if chk == trial.parameters.(chk_f{f})
                matches = 1;
                break;
            end
        elseif iscell(trial.parameters.(chk_f{f}))
            for i = 1:length(trial.parameters.(chk_f{f}))
                if strcmp(chk,trial.parameters.(chk_f{f}){i})
                    matches = 1;
                    break;
                end
            end            
        else
            error('Unknown data type');
        end
    end
    if ~matches
        return;
    end
end

