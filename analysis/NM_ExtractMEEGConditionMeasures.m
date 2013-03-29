% Wrapper for extracting data summaries
function measures = NM_ExtractMEEGConditionMeasures(type, interval)

% Make sure we're processed 
disp('Loading subject data...');
NM_LoadSubjectData({{[type '_data_preprocessed'],1}});
disp('Done.');

global GLA_subject;
global GLA_subject_data;
if ~GLA_subject_data.parameters.(type)
    disp(['No ' type ' data.']);
    measures = {};
    return;
end

% Load the data (will be in meeg_data)
disp(['Loading ' type ' data...']);
load([NM_GetCurrentDataDirectory() '/' type '_data/' GLA_subject ...
    '/' GLA_subject '_preproc.mat']);
disp('Loaded.');

% Init
types = {'phrases','lists'};
for t = 1:length(types)
    for c = 1:5
        measures.(types{t}){c} = [];
    end
end

% And get the measures
for t = 1:length(meeg_data.trial)
    m = getMeasure(meeg_data.trial{t}, interval); 
    if meeg_data.trialinfo(t) > 5
        measures.lists{meeg_data.trialinfo(t)-5}(end+1) = m;
    else
        measures.phrases{meeg_data.trialinfo(t)}(end+1) = m;
    end
end

% Expected the other way...
for t = 1:length(types)
    for c = 1:5
        measures.(types{t}){c} = measures.(types{t}){c}';
    end
end


function m = getMeasure(trial_data, interval)

% Baseline correct 
baseline = 200;
trial_data = ft_preproc_baselinecorrect(trial_data,1,baseline);

% And get the 300-500 rms
rms = sqrt(mean(trial_data.*trial_data,1));
interval = interval+baseline;
m = mean(rms(interval(1):interval(2)));


