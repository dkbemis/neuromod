
function NM_InitializeBehavioralData()

% Initialize the data
disp('Initializing behavioral data...');
NM_LoadSubjectData({{'behavioral_data_checked',1},...
    {'log_checked',1},...
    });

% Reset
NM_ClearBehavioralData();
global GLA_subject;
global GLA_behavioral_data;
GLA_behavioral_data.settings.subject = GLA_subject;
GLA_behavioral_data.data.acc = {};
GLA_behavioral_data.data.rt = {};

% Set each trial
t_ctr = 1;
global GLA_subject_data;
for r = 1:GLA_subject_data.parameters.num_runs
    for t = 1:length(GLA_subject_data.runs(r).trials)
        
        % Might be a timeout
        if GLA_subject_data.runs(r).trials(t).response.rt == -1
            GLA_behavioral_data.data.acc{t_ctr} = [];
            GLA_behavioral_data.data.rt{t_ctr} = [];

        % Otherwise, set the rt and accuracy
        else
            GLA_behavioral_data.data.acc{t_ctr} = ...
                GLA_subject_data.runs(r).trials(t).response.acc;
            GLA_behavioral_data.data.rt{t_ctr} = ...
                GLA_subject_data.runs(r).trials(t).response.rt;
        end
        
        % And set the condition
        GLA_behavioral_data.data.cond{t_ctr} = ...
            GLA_subject_data.runs(r).trials(t).parameters.cond;
        if strcmp(GLA_subject_data.runs(1).trials(1).parameters.p_l,'list')
            GLA_behavioral_data.data.cond{t_ctr} = ...
                GLA_behavioral_data.data.cond{t_ctr} + 5;
        end
        t_ctr = t_ctr+1;
    end
end


% And save
NM_SaveBehavioralData();
disp('Done.');
