
% Set the experiment-wide parameters
function NeuroMod_SetParameters

% Always set to the stimulus screen
PTBSetScreenNumber(1);

% Need this longer...
PTBSetTriggerLength(0.02);

% NOTE: .... % exp. val [speeded val]

% Usually not changing these
global GL_use_photo_square; GL_use_photo_square = 0;
global GL_vertical_offset; GL_vertical_offset = 0;


% Set this to 0 to test without responses. Can then set the next
%   timing parameters short to run through. For quickest run, set to
%   the bracketed 
global GL_is_speeded; GL_is_speeded = 0;  % 0 [1]
global GL_need_response; GL_need_response = 1; % 1 [0]
global GL_no_response_ITI; GL_no_response_ITI = .5; % .5 [.1]
global GL_no_response_probe_time; GL_no_response_probe_time = 1; % 1 [.1]

% The timing parameters
% A single trial will be the sum of these, with 5*(ISI+stim_time)
%   along with RTs.
global GL_init_cross_time; GL_init_cross_time = 0.6;    % .6 [.1]
global GL_stim_time; GL_stim_time = 0.2;  % .2 [.1]
global GL_ISI; GL_ISI = 0.4;    % 0.4 [.1]
global GL_delay_time; GL_delay_time = 2; % 2 [.1]

% For the practice
% NOTE: Need about 25 to show all the words
global GL_num_practice_trials; GL_num_practice_trials = 30;
global GL_practice_feedback_type; GL_practice_feedback_type = 1;    % 1 [0]  
global GL_use_practice_speed_feedback; GL_use_practice_speed_feedback = 1;  % 1 [0]

global GL_use_English_instructions; GL_use_English_instructions = 0; 

% For syncing the trigger
% Put this here because we're going to trigger the eye-tracker as well.
global GL_trigger_delay ; GL_trigger_delay = 0.000;

% This is to get by the stopped screens (e.g. scan starts)
global GL_advance_key; GL_advance_key = 'n';

% Feedback controls
%   0 - None
%   1 - Written
%   2 - Audio
global GL_feedback_type; GL_feedback_type = 0;  
global GL_use_speed_feedback; GL_use_speed_feedback = 0;
global GL_speed_timeout; GL_speed_timeout = 2;
global GL_speed_feedback_time; GL_speed_feedback_time = 3;

% 1 - Use a cross between stimuli
global GL_bg_color; GL_bg_color = [100 100 100];
global GL_use_cross; GL_use_cross = 1;
global GL_cross_size; GL_cross_size = 15;   % 15
global GL_cross_color ; GL_cross_color = [60 60 200];

global GL_probe_font ; GL_probe_font = 'Georgia'; % Georgia
global GL_probe_case ; GL_probe_case = 1;   % 1
global GL_probe_size ; GL_probe_size = 21;  % 21
global GL_probe_color ; GL_probe_color = [255 255 255];
global GL_probe_proportion ; GL_probe_proportion = 1;

global GL_stim_font; GL_stim_font = 'Verdana';  % Verdana
global GL_stim_case; GL_stim_case = 0;  % 0
global GL_stim_size; GL_stim_size = 22; % 22
global GL_stim_color; GL_stim_color = [255 255 255];


% Allow blocking of type
global GL_block_stimuli; GL_block_stimuli = 0;

% For initial consonant strings
global GL_use_initial_consonants ; GL_use_initial_consonants = 1;
global GL_initial_cons_lengths ; GL_initial_cons_lengths = [3 8];    % The min and max length of the initial consonant string


% The conditions to use
global GL_conditions ; GL_conditions = 1:5;       % The conditions to include (1-4 are the normal four words; 5 is extra one word condition)
global GL_a_positions ; GL_a_positions = 1:2;      % 1 - adj/adv first; 2 - second

% Default response keys 
% For now, make them as compatible as possible...
global GL_collection_type; GL_collection_type = 'Char';

% This CANNOT be 'x' (or the fMRI will exit)
global GL_exit_key; GL_exit_key = 'v';

% For noise recordings
global GL_noise_time ; GL_noise_time = 60;  % 60 [1]

% For the noise recordings
global GL_noise_on_trigger ; GL_noise_on_trigger = 1;

% Blinks
global GL_blink_trigger; GL_blink_trigger = 2;  % 2
global GL_num_blinks; GL_num_blinks = 15;  % 15 [1]
global GL_blink_prep_time_mean; GL_blink_prep_time_mean = 1.2;  % 1.2 [.1]
global GL_blink_prep_time_std; GL_blink_prep_time_std = .4;  % .4 [.1]
global GL_blink_time; GL_blink_time = 1; % 1 [.1]

% Eye movements
global GL_eye_right_trigger; GL_eye_right_trigger = 3;
global GL_eye_left_trigger; GL_eye_left_trigger = 4;
global GL_num_eye_movements; GL_num_eye_movements = 10; % 15 [1]
global GL_eye_move_time_mean; GL_eye_move_time_mean = 1.2; % 1.2 [.1]
global GL_eye_move_time_std; GL_eye_move_time_std = .3;  % .3 [.1]

% Mouth movements
global GL_mouth_trigger; GL_mouth_trigger = 5;
global GL_mouth_time; GL_mouth_time = 1.3;  % 1.3 [.1]
global GL_num_mouth_movements; GL_num_mouth_movements = 10;  % 10 [1]
global GL_mouth_prep_time_mean; GL_mouth_prep_time_mean = 1.2;  % 1.2 [.1]
global GL_mouth_prep_time_std; GL_mouth_prep_time_std = .4;  % .4 [.1]


% Breaths
global GL_breath_trigger; GL_breath_trigger = 6;
global GL_breath_time; GL_breath_time = 2.3;  % 2.3 [.1]
global GL_num_breaths; GL_num_breaths = 10;  % 10 [1]
global GL_breath_prep_time_mean; GL_breath_prep_time_mean = 1.2;  % 1.2 [.1]
global GL_breath_prep_time_std; GL_breath_prep_time_std = 0.4;  % .4 [1.]


