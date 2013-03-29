%%

%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Setup (1): Run this first
%
% REMEMBER: 
%   * Switch between 'left' and 'right'
%   * Increment the localizer run
%   * SET ALL THE DEBUGGING VARIABLES
%
%%%%%%%%%%%%%%%%%%%%%%%

% NOTE: Can set subject to 'English' to get english phrases.
%   * Should probably also change a_positions to 1 then as well...
et_subject_id = NeuroMod_SetupSubject('Test','right');
disp('Set to go.');


%% 

%%%%%%%%%%%%%%%%%%%%%%%%
% 
% PRACTICE (2): Create the practice list
%
%%%%%%%%%%%%%%%%%%%%%%%


% For the trial / onset sequencing
NeuroMod_MEG_SetParameters();
NeuroMod_CreatePracticeList();
disp('Practice lists created.');



%% 

%%%%%%%%%%%%%%%%%%%%%%%%
% 
% PRACTICE (3): Run the practice
%
%%%%%%%%%%%%%%%%%%%%%%%


is_debugging = 0;
is_speeded = 0;
environment = 'MEG';
NeuroMod_MEG_Practice(environment, is_debugging, is_speeded); 



%% 

%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Eyetracker (4): Calibration
%
%%%%%%%%%%%%%%%%%%%%%%%


is_debugging = 0;
environment = 'MEG';
NeuroMod_MEG_SetParameters();
NeuroMod_ETCalibration(environment, is_debugging);



%% 

%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Experiment (5): Setup the lists
%
%%%%%%%%%%%%%%%%%%%%%%%


% For the trial / onset sequencing
NeuroMod_MEG_SetParameters();
NeuroMod_CreateStimLists();
disp('Stim lists created.');


%% 


%%%%%%%%%%%%%%%%%%%%%%%%
% 
% EXPERIMENT (6): Run the experiment
%
% REMEMBER: 
%   * Set the run_num to 1 first
%   * Increment run_num from 1 to 5
%
%%%%%%%%%%%%%%%%%%%%%%%


run_num = 5;
is_speeded = 0;
is_debugging = 0;
use_eyetracker = 1;
environment = 'MEG';
run_ET_file_name = [et_subject_id '_' num2str(run_num)];
NeuroMod_MEG_Run(environment, run_ET_file_name, run_num,...
    is_debugging, is_speeded, use_eyetracker); 


%% 


%%%%%%%%%%%%%%%%%%%%%%%%
% 
% BASELINE (7): For making sure the eyetracker was working 
%
%%%%%%%%%%%%%%%%%%%%%%%

% tasks = {'Noise','Blinks','EyeMove','Mouth','Breath'};
tasks = {'Blinks','EyeMove','Noise'};
is_debugging = 0;
is_speeded = 0;
use_eyetracker = 1;
environment = 'MEG';
NeuroMod_MEG_SetParameters;
baseline_ET_file_name = [et_subject_id '_B'];
NeuroMod_Baseline(environment, baseline_ET_file_name,...
    tasks, is_debugging, is_speeded, use_eyetracker)


%% 


%%%%%%%%%%%%%%%%%%%%%%%%
% 
% CLEANUP (8)
%
%%%%%%%%%%%%%%%%%%%%%%%

% To get the et_files, repeatedly run NeuroMod_GetETFile for each of the
%   files until it works. Then, run the edf2asc converter and make sure
%   the output works and gives no warnings (e.g. downsampling)
%
% 5 run files: [et_subject_id '_#']
% baseline file: [et_subject_id '_B']

PTBCloseEyeTracker;
clear all;


