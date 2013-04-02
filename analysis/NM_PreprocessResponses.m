% Helper to clean up the responses 
%
% For now, just marks as outliers responses
%   that are faster than 200ms or slower than 2500ms

function NM_PreprocessResponses()

global GLA_subject;
disp(['Preprocessing responses for ' GLA_subject '...']);

% Load the checked data
disp('Loading data...');
NM_LoadSubjectData({{'data_file_checked',1}});
disp('Done.');

% Check the runs
markOutliers();

% No responses in the baseline...

% Resave...
disp('Responses preprocessed.');
NM_SaveSubjectData({{'responses_preprocessed',1}});


% Check then all at once now
function markOutliers()

% Just use a strict cutoff for now
min_resp_time = 200;
max_resp_time = 2500;
global GLA_subject_data;
for r = 1:GLA_subject_data.parameters.num_runs
    for t = 1:length(GLA_subject_data.runs(r).trials)
        
        % Might be a timeout
        if GLA_subject_data.runs(r).trials(t).response.rt == -1
            GLA_subject_data.runs(r).trials(t).parameters.is_timeout = 1;
        else
            GLA_subject_data.runs(r).trials(t).parameters.is_timeout = 0;            
        end
        
        % Or outlier rts
        if ~ GLA_subject_data.runs(r).trials(t).parameters.is_timeout && ...
                (GLA_subject_data.runs(r).trials(t).response.rt < min_resp_time ||...
                 GLA_subject_data.runs(r).trials(t).response.rt > max_resp_time)
            GLA_subject_data.runs(r).trials(t).parameters.is_response_outlier = 1;
        else
            GLA_subject_data.runs(r).trials(t).parameters.is_response_outlier = 0;
        end
    end
end



