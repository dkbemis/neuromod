% This function creates averages per condition for the MEG data after
% appropriate preprocessing

function NM_PreprocessMEEGData()

global GLA_rec_type;
if ~strcmp(GLA_rec_type,'meeg')
    return;
end

% Load up the data
global GLA_meeg_type;
disp('Loading data...');
NM_LoadSubjectData({{[GLA_meeg_type '_triggers_checked'],1}});
disp('Done.');

global GLA_subject_data;
if ~GLA_subject_data.parameters.(GLA_meeg_type)
    return;
end

% Start from scratch
NM_ClearMEEGData();

% First, filter the data
NM_FilterMEEGData();

% Then reject trials
NM_RejectMEEGTrials();

% Then, decompose, reject, and recompose the data
NM_RemoveMEEGComponents();

global GLA_meeg_trial_type;
NM_SaveSubjectData({{[GLA_meeg_type '_' GLA_meeg_trial_type '_data_preprocessed'],1}});
disp('Done.');

