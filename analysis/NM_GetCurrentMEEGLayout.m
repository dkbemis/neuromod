function layout = NM_GetCurrentMEEGLayout()

global GLA_meeg_type;
switch GLA_meeg_type
    case 'meg'
        layout = 'neuromag306all.lay';
        
    case 'eeg'
        layout = 'GSN-HydroCel-256.sfp';
        
    otherwise
        error('Unknown type.');
end
