
% Helper to unpack the .nii files
function files = NM_GetScanFiles(filter)

% Use the spm command to unpack the .nii list
global GLA_subject;
global GLA_fmri_type;
files = cellstr(spm_select('ExtFPList', ...
    [NM_GetCurrentDataDirectory() '/fmri_data/' GLA_subject ...
        '/' GLA_fmri_type],[filter '.nii'], Inf));

