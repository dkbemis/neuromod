% Quick helper to setup the general experiment parameters
function NeuroMod_SetupExperiment(environment, is_debugging, is_speeded)

% Experiment settings
global GL_bg_color;
global GL_stim_font;
global GL_stim_size;
global GL_stim_color;
global GL_subject;
global GL_exit_key;
global GL_collection_type;

% Set to speeded if necessary
if exist('is_speeded','var') && is_speeded
    NeuroMod_SetSpeeded();
end

% Set the environment
NeuroMod_SetEnvironment(environment);

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
PTBSetBackgroundColor(GL_bg_color);
    
% Set the font parameters
PTBSetTextFont(GL_stim_font);
PTBSetTextSize(GL_stim_size);
PTBSetTextColor(GL_stim_color);

% NOTE: Might need this, if you run from the
% debugger (i.e. Fn+F5)
if is_debugging
	Screen('Preference', 'SkipSyncTests', 1);
end

% Set the logfiles
PTBSetLogFiles([GL_subject '_log.txt'], [GL_subject '_data.txt']);
