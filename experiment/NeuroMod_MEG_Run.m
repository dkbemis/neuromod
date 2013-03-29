%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NeuroMod_MEG_Run.m
%
% Runs one run of the MEG NeuroMod experiment
%
% Args:
%	- subject: The subject id, can be any string.
%		* This will be prepended to the log and data files.
%
% NOTE: This will recreate the stimulus lists every time.
%
% Usage: NeuroMod('Subj_Label')
%
% Author: Doug Bemis
% Date: 11/9/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NeuroMod_MEG_Run(environment, et_file_name, run_num,...
    is_debugging, is_speeded, use_eyetracker)

% Set the options first
NeuroMod_SetParameters;
NeuroMod_MEG_SetParameters;

% Setup the general parameters
NeuroMod_SetupExperiment(environment, is_debugging, is_speeded);

% Let's try our experiment
global GL_subject;
global GL_vertical_offset;
global PTBLastKeyPressTime;
global GL_advance_key;
try

    % First, prepare everything to go
    PTBSetupExperiment('NeuroMod_MEG');
	
    % This gives time to get the program up and going
	init_blank_time = 1;
	PTBDisplayBlank({init_blank_time},'');
    
    % Start the triggers
    PTBInitTriggerPort;
    
    % And the response ports
    if strcmp(environment,'MEG')
        PTBSetPortInput(1);
    end


    % Time to start the recording
    % NOTE: Remember, this can only be 8 characters...
    if use_eyetracker
        PTBInitEyeTracker();
        PTBStartEyeTrackerRecording(et_file_name);
    end
    
    % Screen to allow everything to get set
    PTBDisplayParagraph(NeuroMod_GetInstructions('scan_start'),...
        {'center', 30, GL_vertical_offset}, {GL_advance_key});

    % NOTE: Need at least a screen here before switching
	PTBDisplayBlank({.5},'');
    
    % Start screen
    instructions = NeuroMod_GetInstructions('general');
    instructions{end+1} = ' '; instructions{end+1} = ['(' num2str(run_num) ')'];
    PTBDisplayParagraph(instructions, {'center', 30, GL_vertical_offset}, {'any'}); ;
    PTBDisplayBlank({.5},'');

    % Run through the stimuli
    NeuroMod_ShowTrials(PTBLastKeyPressTime + .5, ...
        [GL_subject '_run_' num2str(run_num) '_stim_list.txt']);

    % The end screens 
    PTBDisplayParagraph(NeuroMod_GetInstructions('scan_end'),...
        {'center', 30}, {GL_advance_key});

    % NOTE: Until the crashing is fixed, just stop and retrieve after
    if use_eyetracker
        PTBStopEyeTrackerRecording;
    end
    
	% Quick blank to make sure the last screen stays on
	PTBDisplayBlank({.1},'');
    
	% And finish up
    PTBCleanupExperiment;

catch %#ok<CTCH>
	PTBHandleError;
end

