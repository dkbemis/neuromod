function NM_SetBehavioralRejections()

% Load the data
global GLA_subject;
disp(['Setting behavioral rejections for ' GLA_subject]);
NM_LoadBehavioralData();

global GLA_behavioral_data;

% See what we want to reject
GLA_behavioral_data.rejections.trials = [];
GLA_behavioral_data.rejections.criteria = {};
types = {'outliers','timeouts','errors'};
for t = 1:length(types)
    rej = GLA_behavioral_data.data.(types{t});
    if isempty(rej)
        continue;
    end
    rej_str = ['Reject ' types{t} '? (y/n) [' num2str(length(rej)) ': '];
    for r = 1:length(rej)
        rej_str = [rej_str num2str(rej(r)) ' '];  %#ok<AGROW>
    end
    rej_str = [rej_str ']: ']; %#ok<AGROW>
    while 1
        ch = input(rej_str,'s');
        if strcmp(ch,'y')
            GLA_behavioral_data.rejections.criteria{end+1} = types{t};
            GLA_behavioral_data.rejections.trials(end+1:end+length(rej)) = rej;
            break;
        elseif strcmp(ch,'n')
            break;
        end
    end
end

% Take out duplicates and save
GLA_behavioral_data.rejections.trials = sort(unique(GLA_behavioral_data.rejections.trials));
NM_SaveBehavioralData();
disp('Done.');

