% Quick helper to get the current directory

function curr_data_dir = NM_GetCurrentDataDirectory()

global GLA_rec_type;
global GLA_meeg_dir;
global GLA_fmri_dir;
switch GLA_rec_type
    case 'meeg'
        curr_data_dir = GLA_meeg_dir;
        if isempty(GLA_meeg_dir) 
            error('Globals not set.');
        end
        
    case 'fmri'
        curr_data_dir = GLA_fmri_dir;
        if isempty(GLA_fmri_dir)
            error('Globals not set.');
        end
    otherwise
        error('Unknown case');
end
