% Helper to clean up the responses 
%
% For now, just marks as outliers responses
%   that are faster than 200ms or slower than 2500ms

function NM_PreprocessBehavioralData()

global GLA_subject;
disp(['Preprocessing behavioral data for ' GLA_subject '...']);

% Make sure we're ready
NM_LoadSubjectData({{'behavioral_data_checked',1}});

% Initialize
NM_InitializeBehavioralData()

% Remove outliers, etc.
NM_SetBehavioralRejections();

% Resave...
NM_SaveSubjectData({{'behavioral_data_preprocessed',1}});
disp(['Behavioral data preprocessed for ' GLA_subject '.']);

