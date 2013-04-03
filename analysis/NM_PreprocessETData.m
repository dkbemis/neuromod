% Helper to clean up the responses 
%
% For now, just marks as outliers responses
%   that are faster than 200ms or slower than 2500ms

function NM_PreprocessETData()

global GLA_subject;
global GLA_trial_type;
disp(['Preprocessing ' GLA_trial_type ' eye tracking data for ' GLA_subject '...']);

% Make sure we're ready
NM_LoadSubjectData({{'et_data_checked',1}});

% Initialize
NM_InitializeETData()

% Remove blinks, etc
NM_SetETRejections();

% Resave...
disp('Saving...');
NM_SaveSubjectData({{['et_' GLA_trial_type '_data_preprocessed'],1}});
disp(['Eye tracking ' GLA_trial_type ' data preprocessed for ' GLA_subject '.']);


