
function NM_InitializeBehavioralData()

% Initialize the data
disp('Initializing behavioral data...');
NM_LoadSubjectData({{'behavioral_data_checked',1},...
    {'log_checked',1},...
    });

% Reset first
NM_ClearBehavioralData();

% Then setup the data structure
global GLA_subject;
global GLA_behavioral_data;
GLA_behavioral_data.settings.subject = GLA_subject;
GLA_behavioral_data.data.acc = {};
GLA_behavioral_data.data.rt = {};
GLA_behavioral_data.data.cond = [];
GLA_behavioral_data.data.outliers = [];
GLA_behavioral_data.data.timeouts = [];
GLA_behavioral_data.data.errors = [];

% Set parameters
global GLA_subject_data;
GLA_behavioral_data.settings.min_resp_time = ...
    GLA_subject_data.parameters.min_resp_time;
GLA_behavioral_data.settings.max_resp_time = ...
    GLA_subject_data.parameters.max_resp_time;

% Set each trial
for r = 1:GLA_subject_data.parameters.num_runs
    for t = 1:length(GLA_subject_data.runs(r).trials)
        [GLA_behavioral_data.data.acc{end+1}...
            GLA_behavioral_data.data.rt{end+1}...
            GLA_behavioral_data.data.cond(end+1)] = getTrialData(t,r);
        
        % Set timeouts, outliers, and errors
        if isempty(GLA_behavioral_data.data.acc{end})
            GLA_behavioral_data.data.timeouts(end+1) = ...
                length(GLA_behavioral_data.data.acc);
        else
            if GLA_behavioral_data.data.acc{end} == 0
                GLA_behavioral_data.data.errors(end+1) = ...
                    length(GLA_behavioral_data.data.acc);
            end
            if GLA_behavioral_data.data.rt{t} < GLA_behavioral_data.settings.min_resp_time ||...
                    GLA_behavioral_data.data.rt{t} > GLA_behavioral_data.settings.max_resp_time 
                GLA_behavioral_data.data.outliers(end+1) = t;
            end
        end
    end
end


% And save
NM_SaveBehavioralData();
disp('Done.');


function [acc rt cond] = getTrialData(t,r)
       
% Might be a timeout
global GLA_subject_data;
if GLA_subject_data.runs(r).trials(t).response.rt == -1
    acc{end+1} = [];
    rt{end+1} = [];

% Otherwise, set the rt and accuracy
else
    acc = GLA_subject_data.runs(r).trials(t).response.acc;
    rt = GLA_subject_data.runs(r).trials(t).response.rt;
end

% And set the condition
cond = GLA_subject_data.runs(r).trials(t).parameters.cond;
if strcmp(GLA_subject_data.runs(1).trials(1).parameters.p_l,'list')
    cond = cond + 5;
end
