%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NeuroMod_fMRI_Structural.m
%
% Shows a screen and tracks TTLs during a structural scan
%
% Author: Doug Bemis
% Date: 12/25/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NeuroMod_fMRI_Structural(environment, is_debugging)

% Set the options first
NeuroMod_SetParameters;
NeuroMod_fMRI_SetParameters;

% Setup the general parameters
NeuroMod_SetupExperiment(environment,is_debugging);

% Let's try our experiment
global GL_vertical_offset;
global GL_structural_stim;
global GL_advance_key;
global GL_fMRI_acq_TTL;
try

    % First, prepare everything to go
    PTBSetupExperiment('NeuroMod_fMRI_Structural');
	
    % This gives time to get the program up and going
	init_blank_time = 1;
	PTBDisplayBlank({init_blank_time},'');
    
    % Start screen
    PTBDisplayParagraph(NeuroMod_GetInstructions('scan_start'),...
        {'center', 30, GL_vertical_offset}, {GL_fMRI_acq_TTL});
    PTBDisplayBlank({.5},'');
    
    % Then just wait for the end...
    NeuroMod_fMRI_WaitForEnd(GL_structural_stim);

    % The end screens 
    PTBDisplayParagraph(NeuroMod_GetInstructions('scan_end'),...
        {'center', 30, GL_vertical_offset}, {GL_advance_key});

	% Quick blank to make sure the last screen stays on
	PTBDisplayBlank({.1},'');
    
	% And finish up
    PTBCleanupExperiment;

catch %#ok<CTCH>
	PTBHandleError;
end

