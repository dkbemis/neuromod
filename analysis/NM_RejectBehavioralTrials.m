function NM_RejectBehavioralTrials()

% Load the data
global GLA_subject;
disp(['Rejecting behavioral trials for ' GLA_subject]);
NM_LoadBehavioralData();

global GLA_behavioral_data;

% Set parameters
global GLA_subject_data;
GLA_behavioral_data.settings.min_resp_time = ...
    GLA_subject_data.parameters.min_resp_time;
GLA_behavioral_data.settings.max_resp_time = ...
    GLA_subject_data.parameters.max_resp_time;

% Calcualte outliers, timeouts, and errors
GLA_behavioral_data.data.outliers = [];
GLA_behavioral_data.data.timeouts = [];
GLA_behavioral_data.data.errors = [];
for t = 1:length(GLA_behavioral_data.data.cond)
    if GLA_behavioral_data.data.acc{t} == 0
        GLA_behavioral_data.data.errors(end+1) = t;
    end
    if isempty(GLA_behavioral_data.data.acc{t})
        GLA_behavioral_data.data.timeouts(end+1) = t;
    end
    if GLA_behavioral_data.data.rt{t} < GLA_behavioral_data.settings.min_resp_time ||...
            GLA_behavioral_data.data.rt{t} > GLA_behavioral_data.settings.max_resp_time 
        GLA_behavioral_data.data.outliers(end+1) = t;
    end
end

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

