function NeuroMod_SetSpeeded

global GL_is_speeded; GL_is_speeded = 1;  % 0 [1]
global GL_need_response; GL_need_response = 0; % 1 [0]
global GL_no_response_ITI; GL_no_response_ITI = .1; % .5 [.1]
global GL_no_response_probe_time; GL_no_response_probe_time = .1; % 1 [.1]
global GL_init_cross_time; GL_init_cross_time = 0.1;    % .6 [.1]
global GL_stim_time; GL_stim_time = 0.1;  % .2 [.1]
global GL_ISI; GL_ISI = 0.1;    % 0.4 [.1]
global GL_delay_time; GL_delay_time = .1; % 2 [.1]
global GL_practice_feedback_type; GL_practice_feedback_type = 0;    % 1 [0]  
global GL_use_practice_speed_feedback; GL_use_practice_speed_feedback = 0;  % 1 [0]
global GL_noise_time ; GL_noise_time = 1;   % 60 [1]
global GL_num_blinks; GL_num_blinks = 1;  % 15 [1]
global GL_blink_prep_time_mean; GL_blink_prep_time_mean = .1;  % 1.2 [.1]
global GL_blink_prep_time_std; GL_blink_prep_time_std = .1;  % .4 [.1]
global GL_blink_time; GL_blink_time = .1; % 1 [.1]
global GL_num_eye_movements; GL_num_eye_movements = 1; % 15 [1]
global GL_eye_move_time_mean; GL_eye_move_time_mean = 0.1; % 1.2 [.1]
global GL_eye_move_time_std; GL_eye_move_time_std = .1;  % .3 [.1]
global GL_mouth_time; GL_mouth_time = .1;  % 1.3 [.1]
global GL_num_mouth_movements; GL_num_mouth_movements = 1;  % 10 [1]
global GL_mouth_prep_time_mean; GL_mouth_prep_time_mean = .1;  % 1.2 [.1]
global GL_mouth_prep_time_std; GL_mouth_prep_time_std = .1;  % .4 [.1]
global GL_breath_time; GL_breath_time = .1;  % 2.3 [.1]
global GL_num_breaths; GL_num_breaths = 1;  % 10 [1]
global GL_breath_prep_time_mean; GL_breath_prep_time_mean = .1;  % 1.2 [.1]
global GL_breath_prep_time_std; GL_breath_prep_time_std = 0.1;  % .4 [1.]
global GL_ITI_mean ; GL_ITI_mean = 0.100;  % .5 [.1]
global GL_ITI_std ; GL_ITI_std = 0;  % .1 [0]
global GL_localizer_stim_time; GL_localizer_stim_time = .1;     % .3 [.1]
global GL_localizer_ISI; GL_localizer_ISI = .1;     % .1 [.1] Between words
global GL_localizer_blank_time; GL_localizer_blank_time = .1;   % 2 [.1] Between sentences
global GL_localizer_IBI; GL_localizer_IBI = .1;  % 8 [.1] Between blocks





