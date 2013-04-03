% This function creates averages per condition for the MEG data after
% appropriate preprocessing

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
NM_LoadSubjectData({{[GLA_meeg_type '_data_checked'],1}});
if ~GLA_subject_data.parameters.(GLA_meeg_type)
    disp(['No ' GLA_meeg_type ' data.']);
    NM_SaveSubjectData({{[GLA_meeg_type '_' GLA_trial_type '_data_preprocessed'],1}});
    return;
end

% Initialize
NM_InitializeMEEGData();

% Then filter the data, if we need to
if ~GLA_subject_data.parameters.meeg_filter_raw
    NM_FilterMEEGData();
end

% Remove outlying trials
NM_SetMEEGRejections();

% Then, decompose, reject, and recompose the data
NM_RemoveMEEGComponents();

% Save...
disp('Saving...');
NM_SaveSubjectData({{[GLA_meeg_type '_' GLA_trial_type '_data_preprocessed'],1}});
disp([GLA_meeg_type ' ' GLA_trial_type ' data preprocessed for ' GLA_subject '.']);

