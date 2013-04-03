function NM_SetETRejections()

% Load the data
global GLA_subject;
global GLA_trial_type;
disp(['Setting eye tracking rejections for ' GLA_trial_type ' for ' GLA_subject]);
NM_LoadETData();

% See what we want to reject
global GLA_et_data;
GLA_et_data.rejections.trials = [];
GLA_et_data.rejections.criteria = {};
types = {'blink','saccade'};
for t = 1:length(types)
    rej = getPossibleRejections(types{t});
    if isempty(rej)
        continue;
    end
    rej_str = ['Reject ' types{t} 's? (y/n) [' num2str(length(rej)) ': '];
    for r = 1:length(rej)
        rej_str = [rej_str num2str(rej(r)) ' '];  %#ok<AGROW>
    end
    rej_str = [rej_str ']: ']; %#ok<AGROW>
    while 1
        ch = input(rej_str,'s');
        if strcmp(ch,'y')
            GLA_et_data.rejections.criteria{end+1} = types{t};
            GLA_et_data.rejections.trials(end+1:end+length(rej)) = rej;
            break;
        elseif strcmp(ch,'n')
            break;
        end
    end
end

% Take out duplicates and save
GLA_et_data.rejections.trials = sort(unique(GLA_et_data.rejections.trials));
NM_SaveETData();
disp('Done.');


function rej = getPossibleRejections(type)

% Get any trial with a start or end
rej = [];
global GLA_et_data;
starts = GLA_et_data.data.([type '_starts']);
ends = GLA_et_data.data.([type '_starts']);
for t = 1:length(GLA_et_data.data.cond)
    if ~isempty(starts{t}) || ~isempty(ends{t})
        rej(end+1) = t; %#ok<AGROW>
    end
end
