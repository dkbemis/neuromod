function NM_ClearMEEGData()

global GLA_meeg_data;
GLA_meeg_data = [];
if exist(NM_GetCurrentMEEGDataFilename(),'file')
    delete(NM_GetCurrentMEEGDataFilename());
end

% Clear any rejections as well
global GLA_subject_data;
global GLA_meeg_trial_type;
global GLA_meeg_type;
if isfield(GLA_subject_data.parameters,[GLA_meeg_type '_' GLA_meeg_trial_type '_rejected'])
    GLA_subject_data.parameters = ...
        rmfield(GLA_subject_data.parameters,...
        [GLA_meeg_type '_' GLA_meeg_trial_type '_rejected']);
    GLA_subject_data.parameters = ...
        rmfield(GLA_subject_data.parameters,...
        [GLA_meeg_type '_' GLA_meeg_trial_type '_rejections']);
end
global GLA_subject;
disp(['Cleared ' GLA_meeg_type ' ' GLA_meeg_trial_type ' data for ' GLA_subject '.']);
NM_SaveSubjectData({});