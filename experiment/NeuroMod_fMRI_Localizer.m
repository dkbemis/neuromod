%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NeuroMod_fMRI_Localizer.m
%
% Runs the fMRI localizer
%
% Author: Doug Bemis
% Date: 12/27/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NeuroMod_fMRI_Localizer(environment, et_file_name, ...
    is_debugging, is_speeded, use_eyetracker)

% Set the options first
NeuroMod_SetParameters;
NeuroMod_fMRI_SetParameters;

% Setup the general parameters
NeuroMod_SetupExperiment(environment, is_debugging, is_speeded);

% Let's try our experiment
global GL_vertical_offset;
global GL_fMRI_acq_TTL;
global GL_advance_key;
global GL_subject;
global GL_stim_size;
global GL_stim_color;
global GL_stim_font;
global PTBLastKeyPressTime;
try

    % First, prepare everything to go
    PTBSetupExperiment('NeuroMod_fMRI_Localizer');
	
    % This gives time to get the program up and going
	init_blank_time = 1;
	PTBDisplayBlank({init_blank_time},'');

    % Time to start the recording
    % NOTE: Remember, this can only be 8 characters...
    if use_eyetracker
        PTBInitEyeTracker();
        PTBStartEyeTrackerRecording(et_file_name);
    end
    
    % Start screen
    PTBDisplayParagraph(NeuroMod_GetInstructions('localizer_start'),...
        {'center', 30}, {'any'});
    PTBDisplayBlank({.5},'');
    
    % Wait for the first volume
    PTBDisplayParagraph({'Le scan va commencer.'}, ...
        {'center', 30, GL_vertical_offset}, {GL_fMRI_acq_TTL});
    PTBDisplayBlank({.05},'');
    start_time = PTBLastKeyPressTime-0.05;
    
    % Show each mini-block
    fid = fopen([GL_subject '_localizer_stim_list.txt']);
    while 1
        line = fgetl(fid);
        if ~ischar(line);
            break;
        end
        start_time = showMiniBlock(line, fid, start_time);
    end
    fclose(fid);

    % Wait and record any ending volumes
    NeuroMod_fMRI_WaitForEnd('+');
    
    % The end screens 
    PTBSetTextSize(GL_stim_size);
    PTBSetTextColor(GL_stim_color);
    PTBSetTextFont(GL_stim_font);
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


% Helper to show each miniblock
function start_time = showMiniBlock(line, fid, start_time)

% Add to the logfile
[i_num length condition catch_stim catch_point] = strread(line,'%d%f%s%s%d'); %#ok<*REMFF1>

% Set the end
end_time = start_time+length;

% Set the trigger
global GL_localizer_sentence_trigger;
global GL_localizer_pseudo_trigger;
global GL_localizer_blank_trigger;
global GL_localizer_catch_trigger;
switch condition{1}
    case 'sentence'
        stim_trigger = GL_localizer_sentence_trigger;
        
    case 'pseudo'
        stim_trigger = GL_localizer_pseudo_trigger;

end

% Should be three sentences
global GL_localizer_blank_time;
global GL_cross_size;
global GL_cross_color;
global GL_stim_size;
global GL_stim_color;
global GL_stim_font;
for s = 1:3
    
    % Show the stimulus
    start_time = showStim(fgetl(fid), start_time, stim_trigger, i_num, condition{1});
    
    % Then the blank, or the catch
    if s ~= catch_point
        start_time = NeuroMod_DisplayFormattedText('+', start_time, GL_localizer_blank_time,...
            GL_cross_size,GL_cross_color,'',GL_localizer_blank_trigger);
    else
        
        % Despite the instructions, we're putting 'any' as the resonse here
        % so that we don't miss it...
        start_time = NeuroMod_fMRI_GetTimedResponse(catch_stim{1}, ...
            GL_localizer_catch_trigger, '+', ...
            {'any'}, start_time, GL_localizer_blank_time,...
            GL_stim_size, GL_stim_color, GL_stim_font,...
            GL_cross_size, GL_cross_color);
    end
end

% And wait until we're done
global GL_is_speeded;
if ~GL_is_speeded
    start_time = NeuroMod_DisplayFormattedText('+', 0, end_time,...
        GL_cross_size,GL_cross_color,'',GL_localizer_blank_trigger);
else    
    start_time = NeuroMod_DisplayFormattedText('+', start_time, .1,...
        GL_cross_size,GL_cross_color,'',GL_localizer_blank_trigger);
end



function start_time = showStim(line, start_time, stim_trigger, i_num, condition)

global GL_stim_font;
global GL_stim_size;
global GL_stim_color;
global GL_localizer_ISI;
global GL_localizer_stim_time;
global GL_advance_key;

% Parse the stim
[stim line] = strtok(line);
while ~isempty(stim)
    stim = lower(NeuroMod_ConvertToUTF8(stim));
    PTBSetLogAppend(1,'clear',{'localizer',num2str(i_num), condition, stim});
    start_time = NeuroMod_DisplayFormattedText(stim, start_time, GL_localizer_stim_time, ...
        GL_stim_size, GL_stim_color, GL_stim_font, stim_trigger);
    
    start_time = start_time + GL_localizer_ISI;
    PTBDisplayBlank({start_time,GL_advance_key},'Localizer_ISI');
    [stim line] = strtok(line); %#ok<*STTOK>
end
    



