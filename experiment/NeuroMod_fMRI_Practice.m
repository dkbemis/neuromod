%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NeuroMod_MEG_Practice.m
%
% Runs the practice for the MEG NeuroMod experiment
%
% Author: Doug Bemis
% Date: 12/25/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NeuroMod_fMRI_Practice(environment, is_debugging, is_speeded)

% Set the options first
NeuroMod_SetParameters;
NeuroMod_fMRI_SetParameters;

% Setup the general parameters
NeuroMod_SetupExperiment(environment, is_debugging, is_speeded);

% Set to use feedback
global GL_feedback_type; global GL_practice_feedback_type;   
global GL_use_speed_feedback; global GL_use_practice_speed_feedback; 
GL_feedback_type = GL_practice_feedback_type;   
GL_use_speed_feedback = GL_use_practice_speed_feedback; 

% Let's try our experiment
global GL_subject;
global GL_vertical_offset;
global PTBLastKeyPressTime;
try
    
    % First, prepare everything to go
    PTBSetupExperiment('NeuroMod_fMRI_Practice');
	
    % This gives time to get the program up and going
	init_blank_time = 1;
	PTBDisplayBlank({init_blank_time},'');
    
    % Start screen
    PTBDisplayParagraph(NeuroMod_GetInstructions('general'),...
        {'center', 30, GL_vertical_offset}, {'any'});
    PTBDisplayBlank({.5},'');

    % Run through the stimuli
    NeuroMod_ShowTrials(PTBLastKeyPressTime + .5, ...
        [GL_subject '_practice_stim_list.txt']);

    % The end screens 
    PTBDisplayParagraph(NeuroMod_GetInstructions('practice_end'),...
        {'center', 30}, {'any'});

	% Quick blank to make sure the last screen stays on
	PTBDisplayBlank({.1},'');
    
	% And finish up
    PTBCleanupExperiment;

catch %#ok<CTCH>
	PTBHandleError;
end

