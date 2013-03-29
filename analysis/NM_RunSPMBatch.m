% Helper to set SPM running...
function NM_RunSPMBatch(mat_file)

% Initialize the jobman
disp(['Running batch: ' mat_file '...']);
spm('defaults', 'FMRI');
spm_jobman('initcfg');

% And run the preprocessing job
spm_jobman('run', mat_file);
disp('Done.');
