%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_PreprocessMEEGData.m
%
% Notes:
%   * Preprocesses the m/eeg data for analysis.
%       - First epochs / filters the data
%       - Repairs eeg channels
%       - Allows rejections of trials
%       - Removes pca/ica components
%   * May want to iterate the last two steps in some way to keep the most
%       amount of data
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_PreprocessMEEGData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_PreprocessMEEGData()

global GLA_rec_type;
if ~strcmp(GLA_rec_type,'meeg')
    return;
end

global GLA_subject;
global GLA_trial_type;
global GLA_meeg_type;
global GLA_subject_data;
disp(['Preprocessing ' GLA_meeg_type ' ' GLA_trial_type ' data for ' GLA_subject '...']);

% Make sure we're ready and have something to do
NM_LoadSubjectData({...
    {[GLA_meeg_type '_data_checked'],1}...
    {['et_' GLA_trial_type '_data_preprocessed'],1}...      % For removing components
    });

% Initialize
NM_InitializeMEEGData();

% Then filter the data, if we need to
if ~GLA_subject_data.settings.meeg_filter_raw
    NM_FilterMEEGData();
end

% Fix the channels
NM_RepairMEEGChannels();

% Remove outlying trials
NM_SetMEEGRejections();

% Then, decompose, reject, and recompose the data
NM_RemoveMEEGComponents();

% Save...
disp([GLA_meeg_type ' ' GLA_trial_type ' data preprocessed for ' GLA_subject '.']);
NM_SaveSubjectData({{[GLA_meeg_type '_' GLA_trial_type '_data_preprocessed'],1}});

