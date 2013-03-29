% Wrapper for extracting data summaries
function measures = NM_ExtractETConditionMeasures(type)

global GLA_subject_data;
if ~GLA_subject_data.parameters.eye_tracker
    measures = [];
    return;
end

% Load the checked data
disp('Loading data...');
NM_LoadSubjectData({{'et_data_preprocessed',1}});
disp('Done.');

% Load the data (will be in et_data)
global GLA_subject;
disp(['Loading ' type ' data...']);
load([NM_GetCurrentDataDirectory() '/eye_tracking_data/' GLA_subject ...
    '/' GLA_subject '_et_preprocessed.mat']);
disp('Loaded.');

% Init
types = {'phrases','lists'};
for t = 1:length(types)
    for c = 1:5
        measures.(types{t}){c} = [];
    end
end

% And get the measures
% TODO: Function here...
for t = 1:length(et_data)
    m = getMeasure(et_data(t)); 
    
    % Might be a blink
    if m < 0
        continue;
    end
    if strcmp(et_data(t).p_l,'list')
        measures.lists{et_data(t).cond}(end+1) = m;
    else
        measures.phrases{et_data(t).cond}(end+1) = m;
    end
end

% Expected the other way...
for t = 1:length(types)
    for c = 1:5
        measures.(types{t}){c} = measures.(types{t}){c}';
    end
end


function m = getMeasure(et_data)

% 200-500;
data = et_data.pupil(400:700);
if sum(isnan(data)) > 0
    m = -1;
else
    m = mean(data);
end



