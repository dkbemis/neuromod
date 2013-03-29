%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NeuroMod_MEG_Baseline.m
%
% Collects some quick baseline data (c.f. Gross et al., 2012)
%
% Author: Doug Bemis
% Date: 12/23/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NeuroMod_Baseline(environment, et_file_name, tasks,...
    is_debugging, is_speeded, use_eyetracker)

% Set the parameters first
NeuroMod_SetParameters;

% Setup the general parameters
NeuroMod_SetupExperiment(environment,is_debugging,is_speeded);

% Let's try our experiment
global GL_vertical_offset;
global GL_advance_key;
global GL_use_MEG_triggers;
try

    % First, prepare everything to go
    PTBSetupExperiment('NeuroMod_Baseline');
	
    % This gives time to get the program up and going
	init_blank_time = 1;
	PTBDisplayBlank({init_blank_time},'');

    % Time to start the recording
    % NOTE: Remember, this can only be 8 characters...
    if use_eyetracker
        PTBInitEyeTracker();
        PTBStartEyeTrackerRecording(et_file_name);
    end
    
    % Start the triggers
    if GL_use_MEG_triggers
        PTBInitTriggerPort;
    end
    
    % Run the tasks
    for t = 1:length(tasks)
    
        switch tasks{t}
            case 'Noise'
                recordNoise;

            case 'Blinks'
                recordBlinks;
            
            case 'EyeMove'
                recordEyeMovements;
            
            case 'Mouth'
                recordMouthMovements;
            
            case 'Breath'
                recordBreaths;
            
            otherwise
                error('Unknown task');
        end

    end

    % And we're done
    PTBDisplayParagraph(NeuroMod_GetInstructions('scan_end'),...
        {'center', 30, GL_vertical_offset}, {GL_advance_key});
    
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


% Helper to record blinks
function recordEyeMovements

global GL_vertical_offset;
global GL_eye_right_trigger;
global GL_eye_left_trigger;
global GL_num_eye_movements;
global GL_eye_move_time_mean;
global GL_eye_move_time_std;
global GL_advance_key;

PTBDisplayParagraph(NeuroMod_GetInstructions('eye_move'),...
    {'center', 30, GL_vertical_offset}, {GL_advance_key});


% Show the cross
for b = 1:GL_num_eye_movements

    % Left and right...
    for d = randperm(2)

        % Center...
        PTBSetLogAppend(1,'clear',{'eye_movements',num2str(b),'1'});
        eye_move_time = randn*GL_eye_move_time_std + GL_eye_move_time_mean;
        NeuroMod_DisplayFormattedText('+', 0, {eye_move_time,GL_advance_key});

        % Move...
        eye_move_time = randn*GL_eye_move_time_std + GL_eye_move_time_mean;
        if d == 1
            PTBSetLogAppend(1,'clear',{'eye_movements',num2str(b),'2'});
            NeuroMod_DisplayFormattedText('                         +', 0, ...
                {eye_move_time,GL_advance_key},'', '', '', GL_eye_right_trigger);
        else
            PTBSetLogAppend(1,'clear',{'eye_movements',num2str(b),'3'});
            NeuroMod_DisplayFormattedText('+                         ', 0, ...
                {eye_move_time,GL_advance_key},'', '', '', GL_eye_left_trigger);
        end
    end
end



% Helper to record eye movements
function recordBlinks

global GL_vertical_offset;
global GL_blink_trigger;
global GL_blink_time;
global GL_num_blinks;
global GL_blink_prep_time_mean;
global GL_advance_key;
global GL_blink_prep_time_std;

PTBDisplayParagraph(NeuroMod_GetInstructions('blinks'),...
    {'center', 30, GL_vertical_offset}, {GL_advance_key});

% Show the cross
for b = 1:GL_num_blinks
    blink_prep_time = randn*GL_blink_prep_time_std + GL_blink_prep_time_mean;
    PTBSetLogAppend(1,'clear',{'blinks',num2str(b),'1'});
    NeuroMod_DisplayFormattedText('+', 0, {blink_prep_time, GL_advance_key});
    PTBSetLogAppend(1,'clear',{'blinks',num2str(b),'2'});
    NeuroMod_DisplayFormattedText(' ', 0, {GL_advance_key, GL_blink_time}, '', '', '',GL_blink_trigger);
end

% Helper to record eye movements
function recordBreaths

global GL_vertical_offset;
global GL_breath_trigger;
global GL_breath_time;
global GL_num_breaths;
global GL_breath_prep_time_mean;
global GL_breath_prep_time_std;
global GL_advance_key;

PTBDisplayParagraph(NeuroMod_GetInstructions('breaths'),...
    {'center', 30, GL_vertical_offset}, {GL_advance_key});

% Show the cross
for b = 1:GL_num_breaths
    breath_prep_time = randn*GL_breath_prep_time_std + GL_breath_prep_time_mean;
    PTBSetLogAppend(1,'clear',{'breaths',num2str(b),'1'});
    NeuroMod_DisplayFormattedText('+', 0, {breath_prep_time,GL_advance_key});
    PTBSetLogAppend(1,'clear',{'breaths',num2str(b),'2'});
    NeuroMod_DisplayFormattedText(' ', 0, {GL_breath_time,GL_advance_key}, '', '', '',GL_breath_trigger);
end



% Helper to record eye movements
function recordMouthMovements

global GL_vertical_offset;
global GL_mouth_trigger;
global GL_mouth_time;
global GL_num_mouth_movements;
global GL_mouth_prep_time_mean;
global GL_mouth_prep_time_std;
global GL_advance_key;

PTBDisplayParagraph(NeuroMod_GetInstructions('mouth_move'),...
    {'center', 30, GL_vertical_offset}, {GL_advance_key});

% Show the cross
for b = 1:GL_num_mouth_movements
    mouth_prep_time = randn*GL_mouth_prep_time_std + GL_mouth_prep_time_mean;
    PTBSetLogAppend(1,'clear',{'mouth_movements',num2str(b),'1'});
    NeuroMod_DisplayFormattedText('+', 0, {mouth_prep_time,GL_advance_key});
    PTBSetLogAppend(1,'clear',{'mouth_movements',num2str(b),'2'});
    NeuroMod_DisplayFormattedText(' ', 0, {GL_mouth_time,GL_advance_key}, '', '', '',GL_mouth_trigger);
end


% Helper to record a noise reading
function recordNoise

global GL_vertical_offset;
global GL_noise_time;
global GL_noise_on_trigger;
global GL_advance_key;

PTBDisplayParagraph(NeuroMod_GetInstructions('noise'),...
    {'center', 30, GL_vertical_offset}, {GL_advance_key});

% Show a blank
PTBSetLogAppend(1,'clear',{'noise','1','1'});
NeuroMod_DisplayFormattedText(' ', 0, {GL_noise_time,GL_advance_key}, '', '', '',GL_noise_on_trigger);

