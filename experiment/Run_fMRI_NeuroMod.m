%%
%%%%%%%%%%%%%%%%%%%%%%%%
% 
% Setup (1): Run this first AND WHENEVER THERE IS A CRASH
%
% REMEMBER: 
%   * Switch between 'left' and 'right'
%   * Increment the localizer run
%   * SET ALL THE DEBUGGING VARIABLES
%
%%%%%%%%%%%%%%%%%%%%%%%

et_subject_id = NeuroMod_SetupSubject('Test','right');
localizer_stim_file = 'lists_miniblocks/run01.csv';
disp('Subject setup.');


%% 

%%%%%%%%%%%%%%%%%%%%%%%%
% 
% PRACTICE (2): Create the practice list
%
%%%%%%%%%%%%%%%%%%%%%%%


% For the trial / onset sequencing
NeuroMod_fMRI_SetParameters();
NeuroMod_CreatePracticeList();
disp('Practice lists created.');


%% 

%%%%%%%%%%%%%%%%%%%%%%%%
% 
% PRACTICE (3): Run the practice
%
%%%%%%%%%%%%%%%%%%%%%%%


is_speeded = 0;     % 0 to run the experiment
is_debugging = 0;     % 0 to run the experiment
environment = 'fMRI';   % 'fMRI' when subject is in the scanner, 'fMRI_computer' when outside
NeuroMod_fMRI_Practice(environment,is_debugging, is_speeded); 


%% 


%%%%%%%%%%%%%%%%%%%%%%%%
% 
% EYETRACKER (4): Calibration
%
%%%%%%%%%%%%%%%%%%%%%%%


is_debugging = 0;     % 0 to run the experiment
environment = 'fMRI';   % 'fMRI' when subject is in the scanner, 'fMRI_computer' when outside
NeuroMod_fMRI_SetParameters();
NeuroMod_ETCalibration(environment, is_debugging)

%% 

%%%%%%%%%%%%%%%%%%%%%%%%
% 
% STRUCTURAL (5)
%
%%%%%%%%%%%%%%%%%%%%%%%


is_debugging = 0;     % 0 to run the experiment
environment = 'fMRI';   % 'fMRI' when subject is in the scanner, 'fMRI_computer' when outside
NeuroMod_fMRI_Structural(environment, is_debugging); 



%% 


%%%%%%%%%%%%%%%%%%%%%%%%
% 
% EXPERIMENT (6): Set the experiment lists
%
%%%%%%%%%%%%%%%%%%%%%%%


% For the trial / onset sequencing
NeuroMod_fMRI_SetParameters();
NeuroMod_CreateStimLists();
disp('Stim lists created');



%% 


%%%%%%%%%%%%%%%%%%%%%%%%
% 
% EXPERIMENT (7): Run the experiment
%
% REMEMBER: 
%   * Set the run_num to 1 first
%   * Increment run_num from 1 to 4
%
%%%%%%%%%%%%%%%%%%%%%%%



run_num = 1;        % Increment from 1 to 4
is_speeded = 0;     % 0 to run the experiment
is_debugging = 0;     % 0 to run the experiment
use_eyetracker = 0;     % 1 if using the eye tracker
environment = 'fMRI';   % 'fMRI' when subject is in the scanner, 'fMRI_computer' when outside
run_ET_file_names{run_num} = [et_subject_id '_' num2str(run_num)];
NeuroMod_fMRI_Run(environment,run_ET_file_names{run_num}, run_num,...
    is_debugging, is_speeded, use_eyetracker); 


%% 


%%%%%%%%%%%%%%%%%%%%%%%%
% 
% LOCALIZER (8): Create the localizer list
%
%%%%%%%%%%%%%%%%%%%%%%%


% Increment this each time.
NeuroMod_fMRI_CreateLocalizerStimList(localizer_stim_file);
disp('Localizer list created.');


%% 

%%%%%%%%%%%%%%%%%%%%%%%%
% 
% LOCALIZER (9): Run the localizer
%
%%%%%%%%%%%%%%%%%%%%%%%



is_debugging = 0;     % 0 to run the experiment
is_speeded = 0;     % 0 to run the experiment
use_eyetracker = 0;     % 1 if using the eye tracker
environment = 'fMRI';   % 'fMRI' when subject is in the scanner, 'fMRI_computer' when outside
localizer_ET_file_name = [et_subject_id '_L'];
NeuroMod_fMRI_Localizer(environment, localizer_ET_file_name,...
    is_debugging, is_speeded, use_eyetracker);


%% 


%%%%%%%%%%%%%%%%%%%%%%%%
% 
% BASELINE (10): For making sure the eyetracker was working 
%
%%%%%%%%%%%%%%%%%%%%%%%


tasks = {'Blinks','EyeMove'};   % Other options: 'Noise','Mouth','Breath'
is_debugging = 0;     % 0 to run the experiment
is_speeded = 0;     % 0 to run the experiment
use_eyetracker = 0;     % 1 if using the eye tracker
environment = 'fMRI';   % 'fMRI' when subject is in the scanner, 'fMRI_computer' when outside
NeuroMod_fMRI_SetParameters();
baseline_ET_file_name = [et_subject_id '_B'];
NeuroMod_Baseline(environment, baseline_ET_file_name, tasks, ...
    is_debugging, is_speeded, use_eyetracker)


%%

%%%%%%%%%%%%%%%%%%%%%%%%
% 
% CLEANUP (11)
%
%%%%%%%%%%%%%%%%%%%%%%%

% To get the et_files, repeatedly run NeuroMod_GetETFile for each of the
%   files until it works. Then, run the edf2asc converter and make sure
%   the output works and gives no warnings (e.g. downsampling)
%
% 4 run files: [et_subject_id '_#']
% baseline file: [et_subject_id '_B']



PTBCloseEyeTracker;
clear all;

