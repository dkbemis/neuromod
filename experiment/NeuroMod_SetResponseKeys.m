% Helper to set our response keys
function NeuroMod_SetResponseKeys(type)

global GL_response_type; GL_response_type = type; 
global GL_keyboard_match_key;
global GL_keyboard_no_match_key;
global GL_fMRI_match_key;
global GL_fMRI_no_match_key;
global GL_MEG_match_key;
global GL_MEG_no_match_key;


% Type: Which hand is match
switch type
    case 'right'
        GL_keyboard_match_key = 'o';
        GL_keyboard_no_match_key = 't';
        GL_fMRI_match_key = 'y';
        GL_fMRI_no_match_key = 'p';
        GL_MEG_match_key = '6';
        GL_MEG_no_match_key = '1';
        
    case 'left'
        GL_keyboard_match_key = 't';
        GL_keyboard_no_match_key = 'o';
        GL_fMRI_match_key = 'p';
        GL_fMRI_no_match_key = 'y';
        GL_MEG_match_key = '1';
        GL_MEG_no_match_key = '6';
        
    otherwise
        error('Unknown type');
end



