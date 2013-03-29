function NeuroMod_SetEnvironment(environment)

global GL_environment; GL_environment = environment; 
global GL_MEG_match_key; 
global GL_MEG_no_match_key;     
global GL_fMRI_match_key; 
global GL_fMRI_no_match_key;     
global GL_keyboard_match_key; 
global GL_keyboard_no_match_key;     
global GL_match_key;
global GL_no_match_key;
global GL_use_photo_square;
global GL_vertical_offset;
switch environment
    case 'MEG'
        GL_match_key = GL_MEG_match_key;
        GL_no_match_key = GL_MEG_no_match_key;

        % Change some parameters for recording
        GL_use_photo_square = 1;
        GL_vertical_offset = -100;
        
    case 'fMRI'
        GL_match_key = GL_fMRI_match_key;
        GL_no_match_key = GL_fMRI_no_match_key;
        
    case 'fMRI_computer'
        GL_match_key = GL_keyboard_match_key;
        GL_no_match_key = GL_keyboard_no_match_key;
        
    case 'work_computer'
        GL_match_key = GL_keyboard_match_key;
        GL_no_match_key = GL_keyboard_no_match_key;

    case 'home_computer'
        GL_match_key = GL_keyboard_match_key;
        GL_no_match_key = GL_keyboard_no_match_key;

    case 'MEG_computer'
        GL_match_key = GL_keyboard_match_key;
        GL_no_match_key = GL_keyboard_no_match_key;
        
    otherwise
        error('Unknown environment');
end

% Adjust the size
size_adjust = getSizeAdjust(environment);
global GL_probe_size; GL_probe_size = floor(GL_probe_size*size_adjust);
global GL_stim_size; GL_stim_size = floor(GL_stim_size*size_adjust);
global GL_cross_size; GL_cross_size = floor(GL_cross_size*size_adjust);


% Adjust to make all of the text sizes the same
function size_adjust = getSizeAdjust(environment)

% This is the (somewhat arbitrary) standard based on how big
%   'humongou' is in Verdana 22
standard_width = 31;
standard_screen_dist = 460;
standard_angle = calculateVisualAngle(standard_width, standard_screen_dist);

switch environment
    case 'fMRI'
        env_width = 60;
        env_screen_dist = 890;

    case 'fMRI_computer'
        env_width = 35;
        env_screen_dist = 450;

    case 'work_computer'
        env_width = 31;
        env_screen_dist = 460;

    case 'home_computer'
        env_width = 25;
        env_screen_dist = 480;
        
    case 'MEG_computer'
        env_width = 44;
        env_screen_dist = 435;
        
    case 'MEG'
        env_width = 63;
        env_screen_dist = 890;

    otherwise
        error('Unknown environment');
end
env_angle = calculateVisualAngle(env_width, env_screen_dist);
size_adjust = standard_angle / env_angle;
        
        
        