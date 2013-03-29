%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NeuroMod_MEG_Noise.m
%
% Collects a quick noise sample from the MEG room.
%
% Args:
%	- subject: The subject id, can be any string.
%		* This will be prepended to the log and data files.
%
% Usage: NeuroMod_MEG_Noise('Subj_Label')
%
% Author: Doug Bemis
% Date: 12/23/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NeuroMod_MEG_Noise(is_debugging)

% Set the parameters first
NeuroMod_SetParameters;
NeuroMod_MEG_SetParameters;

% Experiment settings
global GL_vertical_offset;
global GL_trigger_delay;
global GL_noise_on_trigger;
global GL_noise_off_trigger;
global GL_noise_time;

% Setup the general parameters
NeuroMod_Setup_Experiment(is_debugging);

% Let's try our experiment
try

    % First, prepare everything to go
    PTBSetupExperiment('NeuroMod_MEG_Noise');
	
    % This gives time to get the program up and going
	init_blank_time = 1;
	PTBDisplayBlank({init_blank_time},'');
    
    % Start the triggers
    PTBInitTriggerPort;
    
    % Screen to allow everything to get set
    PTBDisplayParagraph({'We will now record two minutes of baseline data.',...
        'Please lie still and close your eyes.'},{'center', 30, GL_vertical_offset}, {'a'});

    % Show a blank
    NeuroMod_displayFormattedText(' ', 0, GL_noise_time, '', '', '',GL_noise_on_trigger);

    % And we're done
    PTBDisplayParagraph({'The noise recording is over.',...
        'Please lie still as we save the data.'},{'center', 30, GL_vertical_offset}, {'a'}, ...
        GL_noise_off_trigger, GL_trigger_delay);

	% Quick blank to make sure the last screen stays on
	PTBDisplayBlank({.1},'');
    
	% And finish up
    PTBCleanupExperiment;

catch %#ok<CTCH>
	PTBHandleError;
end

