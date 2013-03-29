%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NeuroMod_ET_Calibration.m
%
% Calibrates the eyetracker.
%
% Args:
%	- subject: The subject id, can be any string.
%		* This will be prepended to the log and data files.
%
% Author: Doug Bemis
% Date: 11/9/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NeuroMod_ETCalibration(environment, is_debugging)

% Set the parameters first
NeuroMod_SetParameters;

% Experimental settings
global GL_vertical_offset;
global GL_advance_key;

% Setup the general parameters
NeuroMod_SetupExperiment(environment,is_debugging);

% Let's try our experiment
try

    % First, prepare everything to go
    PTBSetupExperiment('NeuroMod_ET_Calibration');
	
    % This gives time to get the program up and going
	init_blank_time = 1;
	PTBDisplayBlank({init_blank_time},'');

    % Initialize the eyetracker
    PTBInitEyeTracker();
 
    % Run the calibration
    PTBDisplayParagraph(NeuroMod_GetInstructions('eyetracker_calibration'),...
        {'center', 30, GL_vertical_offset}, {GL_advance_key});
 	PTBDisplayBlank({.5},'');
    PTBCalibrateEyeTracker;

    % Some blanks to try to wait...
    % TODO: Figure out why this goes forward so quickly...
 	PTBDisplayBlank({.5},'');
 	PTBDisplayBlank({GL_advance_key},'');
    
    % Final screen
    PTBDisplayParagraph(NeuroMod_GetInstructions('eyetracker_calibration_end'),...
        {'center', 30, GL_vertical_offset}, {GL_advance_key});

	% Quick blank to make sure the last screen stays on
	PTBDisplayBlank({.1},'');
    
	% And finish up
    PTBCleanupExperiment;

catch %#ok<CTCH>
	PTBHandleError;
end


