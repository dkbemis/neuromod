% Wrapper for extracting data summaries
function measures = NM_ExtractBehavioralConditionMeasures(type)

% Load the checked data
disp('Loading data...');
NM_LoadSubjectData({{'responses_preprocessed',1}});
disp('Done.');

% Default for no timeout and no outliers
filter.is_response_outlier = {0};
filter.is_timeout = {0};

% If rt, just use correct
if strcmp(type,'rt')
    filter.acc = {1};
end

% Grab the data
filter.p_l = {'phrase'};
[phrase_rts phrase_accs] = summarizeConditionResponses(filter);
filter.p_l = {'list'};
[list_rts list_accs] = summarizeConditionResponses(filter);

% And return
switch type
    case 'rt'
        measures.phrases = phrase_rts;
        measures.lists = list_rts;

    otherwise
        error('Unknown type');
end
        

function [rts accs] = summarizeConditionResponses(filter)

% Get for each condition
rts = {};
accs = {};
global GLA_subject_data;
for c = 1:GLA_subject_data.parameters.num_conditions
    filter.cond = {c};
    [rts{c} accs{c}] = summarizeTrialSetResponses(NM_FilterTrials(filter));
end


% Summarize the responses from a set of trials
function [rts accs] = summarizeTrialSetResponses(trials)

rts = zeros(length(trials),1);
accs = zeros(length(trials),1);
for t = 1:length(trials)
    rts(t) = trials(t).response.rt; 
    accs(t) = trials(t).response.acc; 
end



