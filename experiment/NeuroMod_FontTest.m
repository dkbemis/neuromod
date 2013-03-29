function NeuroMod_FontTest(environment, stims, bg_color, size, color,...
    font, upper_case, wait_for_key, is_debugging)

% Set the options first
NeuroMod_SetParameters;
NeuroMod_fMRI_SetParameters;
NeuroMod_SetEnvironment(environment);

global GL_exit_key;
global GL_collection_type;

% Make sure we're compatible
PTBVersionCheck(1,1,16,'at least');

% Set to debug, if we want to.
PTBSetIsDebugging(is_debugging);

% TODO: Need to debug input on linux, perhaps...
PTBSetInputCollection(GL_collection_type);
PTBSetExitKey(GL_exit_key);

% Don't use the start screen for now
PTBSetUseStartScreen(1);

% Set the stimuli colors
PTBSetBackgroundColor(bg_color);

% NOTE: Might need this, if you run from the
% debugger (i.e. Fn+F5)
if is_debugging
	Screen('Preference', 'SkipSyncTests', 1);
end

% Set the logfiles
PTBSetLogFiles('FontTest_log.txt', 'FontTest_data.txt');

global GL_init_cross_time;
global GL_cross_size;
global GL_cross_color;
global GL_ISI;
global GL_stim_time;
if wait_for_key
    stim_duration = {'any'};
else
    stim_duration = GL_stim_time;    
end
try

    % First, prepare everything to go
    PTBSetupExperiment('NeuroMod_FontTest');
	
    % This gives time to get the program up and going
	init_blank_time = 1;
	PTBDisplayBlank({init_blank_time},'');


    % Show a cross first
    if GL_init_cross_time > 0
        NeuroMod_DisplayFormattedText('+', 0, ...
            GL_init_cross_time, GL_cross_size, GL_cross_color, font);
    end

    % Then, show them all
    for s = 1:length(stims)
        
        if upper_case
            stims{s} = upper(stims{s});
        end
        NeuroMod_DisplayFormattedText(stims{s}, 0, stim_duration, ...
            size, color, font);

        % Then a blank
        NeuroMod_DisplayFormattedText('+', 0, GL_ISI, ...
            GL_cross_size, GL_cross_color, font);
    end    
    
    
	% Quick blank to make sure the last screen stays on
	PTBDisplayBlank({.1},'');
    
	% And finish up
    PTBCleanupExperiment;

catch %#ok<CTCH>
	PTBHandleError;
end



