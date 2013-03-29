
% Set the experiment-wide parameters
function NeuroMod_MEG_SetParameters

% This is the total number of each type of phrase
%   (e.g. 1 -> 1 NP and one VP, and one of each list type)
% So, the number of trials will be:
%   * num_phrases * 2(Comp, List) * 2(Noun, Verb) * 5(1-4 words, N/V one-word)
%       = num_phrases * 20
global GL_num_reps ; GL_num_reps = 20;          % NOTE: This is the number of times through for each subtype (e.g. vp)      
global GL_run_length ; GL_run_length = 4;       % This is in number of reps... So, x20 for number of trials

% For creating the trial ordering
global GL_order_num_conditions; GL_order_num_conditions = 10;
global GL_order_stim_time; GL_order_stim_time = 6;
global GL_order_SOA; GL_order_SOA = 8;

% This controls the distance between trials
global GL_ITI_mean ; GL_ITI_mean = 0.500;
global GL_ITI_std ; GL_ITI_std = 0.100;

% Set to use in the actual experiment
global GL_use_random_ITI; GL_use_random_ITI = 1;

% Make sure we're using these triggers if asked
global GL_use_MEG_triggers; GL_use_MEG_triggers = 1;



% For the experiment

% NOTE: With 40 conditions and 7 events per trial, we have too many, 
%   with the EGI. So, we'll have to recode...
% As of now, these are simply set using the NeuroMod_GetMEGTriggers function


