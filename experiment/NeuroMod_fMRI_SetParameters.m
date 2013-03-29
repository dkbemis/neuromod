
% Set the experiment-wide parameters
function NeuroMod_fMRI_SetParameters

% NOTE: .... % exp. val [speeded val]

% This is the total number of each type of phrase
%   (e.g. 1 -> 1 NP and one VP, and one of each list type)
% So, the number of trials will be:
%   * num_phrases * 2(Comp, List) * 2(Noun, Verb) * 5(1-4 words, N/V one-word)
%       = num_phrases * 20
global GL_num_reps ; GL_num_reps = 16;          % 16 NOTE: This is the number of times through for each subtype (e.g. vp)      
global GL_run_length ; GL_run_length = 4;       % 4  This is in number of reps... So, x20 for number of trials

% For creating the trial ordering
global GL_order_num_conditions; GL_order_num_conditions = 12;
global GL_order_stim_time; GL_order_stim_time = 6;
global GL_order_SOA; GL_order_SOA = 8;

% This controls the distance between trials during the practice
% [B/c the timing is fixed in the experiment...]
global GL_ITI_mean ; GL_ITI_mean = 0.400;  % .5 [.1]
global GL_ITI_std ; GL_ITI_std = .1;  % .1 [0]

% Don't use for the actual experiment
global GL_use_random_ITI; GL_use_random_ITI = 0;

% Sets the number of trials from end of run that blanks can be
global GL_blank_buffer; GL_blank_buffer = 2;

% Make sure we're using these triggers if asked
global GL_use_MEG_triggers; GL_use_MEG_triggers = 0;

% What to show during the structural scan
global GL_structural_stim; GL_structural_stim = '+';

% From the scanner
global GL_fMRI_acq_TTL; GL_fMRI_acq_TTL = 's';

% For the localizer
% Just set to the stimuli default for now.
global GL_num_localizer_catch_trials; GL_num_localizer_catch_trials = 2;
global GL_localizer_catch_stims; GL_localizer_catch_stims = {'cliquez','appuyez'};


% These are just for the eyetracker
global GL_localizer_sentence_trigger; GL_localizer_sentence_trigger = 1;
global GL_localizer_pseudo_trigger; GL_localizer_pseudo_trigger = 2;
global GL_localizer_blank_trigger; GL_localizer_blank_trigger = 3;
global GL_localizer_catch_trigger; GL_localizer_catch_trigger = 4;

% For timing
global GL_localizer_stim_time; GL_localizer_stim_time = .3;     % .3 [.1]
global GL_localizer_ISI; GL_localizer_ISI = .1;     % .1 [.1] Between words
global GL_localizer_blank_time; GL_localizer_blank_time = 2;   % 2 [.1] Between sentences
global GL_localizer_IBI; GL_localizer_IBI = 8;  % 8 [.1] Between blocks





