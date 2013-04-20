%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_PreprocessETData.m
%
% Notes:
%   * Preprocesses the eye tracking data so that it can be analyzed.
%       - First initializes the data, then finds any potential rejections
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_PreprocessETData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
disp(['Eye tracking ' GLA_trial_type ' data preprocessed for ' GLA_subject '.']);
NM_SaveSubjectData({{['et_' GLA_trial_type '_data_preprocessed'],1}});


