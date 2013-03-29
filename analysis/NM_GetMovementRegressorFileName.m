
% Not sure if the movement regressor file changes name
function file_name = NM_GetMovementRegressorFileName(run_id)
    
global GLA_fmri_type;

% Look for the rp...txt file
global GLA_subject;
data_dir = [NM_GetCurrentDataDirectory() '/fmri_data/'...
    GLA_subject '/' GLA_fmri_type];
files = dir(data_dir);
for f = 1:length(files)
    if length(files(f).name) > 5 && strcmp(files(f).name(1:2),'rp') &&...        
            ((strcmp(GLA_fmri_type,'localizer') && strcmp(files(f).name(end-3:end),'.txt')) ||...
             (strcmp(GLA_fmri_type,'experiment') && strcmp(files(f).name(end-4:end),[num2str(run_id) '.txt'])))
        file_name = [data_dir '/' files(f).name];
        return;
    end
end
error('Movement file not found.');

