% Give a quick analysis of a single subject's responses
%
% For now, just prints a graph of the errors and rt for each condition,
%   separated by structure type

function NM_AnalyzeResponses(filter, label)

global GLA_subject;
disp(['Analyzing responses for ' GLA_subject '...']);

% Load the checked data
disp('Loading data...');
NM_LoadSubjectData({{'responses_preprocessed',1}});
disp('Done.');

% If constraining, need a label
save_file = [NM_GetCurrentDataDirectory() '/analysis/' GLA_subject '/'...
    GLA_subject '_Beh'];
if exist('filter','var')
    save_file = [save_file '_' label];
end

% Quick analysis for now
filter.p_l = {'phrase'};
[phrase_rts phrase_accs] = summarizeConditionResponses(filter);
filter.p_l = {'list'};
[list_rts list_accs] = summarizeConditionResponses(filter);

% Test and summarize each condition for differences
rt_p = []; acc_p = []; rt_means = []; acc_means = []; rt_stderrs = []; acc_stderrs = [];
global GLA_subject_data;
for c = 1:GLA_subject_data.parameters.num_conditions

    % Might be unequal because of outliers...
    rt_p(c) = ttest2(phrase_rts{c}, list_rts{c}); %#ok<*AGROW>
    acc_p(c) = ttest2(phrase_accs{c}, list_accs{c});
    
    % And get summaries
    rt_means(c,1) = mean(phrase_rts{c}); rt_means(c,2) = mean(list_rts{c}); 
    acc_means(c,1) = mean(phrase_accs{c}); acc_means(c,2) = mean(list_accs{c}); 
    
    rt_stderrs(c,1) = std(phrase_rts{c}) / sqrt(length(phrase_rts{c})); 
    rt_stderrs(c,2) = std(list_rts{c}) / sqrt(length(list_rts{c})); 
    acc_stderrs(c,1) = std(phrase_accs{c}) / sqrt(length(phrase_accs{c}));
    acc_stderrs(c,2) = std(list_accs{c}) / sqrt(length(list_accs{c})); 
end


% Plot
figure; 
plotConditions(rt_means, rt_stderrs,'RT',1,rt_p);
plotConditions(1-acc_means, acc_stderrs,'Err',2,acc_p);
legend('phrase','list');
saveas(gcf,[save_file '.jpg'],'jpg');


function plotConditions(vals, errs, label, ind, p)

% Start it up
subplot(2,1,ind); hold on; title(label);

% Plot the two lines
colors = {'b','g'};
for t = 1:2
    errorbar(vals(:,t),errs(:,t),colors{t});
end

% And then any significant values
if sum(p) > 0
    a = axis;
    t = text(find(p > 0),ones(sum(p),1)*a(end),'*');
    set(t,'FontSize',30);
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
function [rts accs] = summarizeTrialSedtResponses(trials)

if ~exist('use_outliers','var')
    use_outliers = 0;
end

rts = zeros(length(trials),1);
accs = zeros(length(trials),1);
for t = 1:length(trials)
    if use_outliers || ~trials(t).response.is_outlier
        rts(t) = trials(t).response.rt; 
        accs(t) = trials(t).response.acc; 
    end
end


