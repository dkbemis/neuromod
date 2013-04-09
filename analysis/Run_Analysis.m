%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: Run_Analysis.m
%
% Notes:
%   * This function runs the whole analysis. It's primary purpose is to 
%       give the structure of the analysis. 
%   * Almost always it would probably be easier to run the functions 
%       one at a time...
%
% Inputs:
% Outputs:
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Run_Analysis()

% Set the initial globals
NM_InitializeGlobals();


% Note

% These can be run from any directory, but might be best to run from the
%   analysis directory. Then, to force redoing, can load the subject data,
%   reset the appropriate parameter and then save.


% Import the data...

% The first step is to get the data in the right folders and named
% correctly

% This must be done manually for the EEG data and log files:
%   * Logs: Expected to be in the /logs/ subject folder and cleaned of
%       extraneous runs. Should keep the originals as _raw.txt
%           - Both _log.txt and _data.txt files.
%   * EEG: Need to convert these into .raw files using the NetStation
%       software. Then, add to the /eeg_data/ folder named appropriately
%       (e.g. subject_run_# / _baseline). 
%           - NOTE: Rename after conversion to avoid confusing NetStation.
%   * Eyetracking: In theory, this can be converted automatically, however,
%       best to do in the lab a) to check that the transfer was correct and
%       b) because conversion script doesn't work on linux.
%           - .asc files should be in the /eye_tracking_data/ folder and
%           named as usual (subject_run_# / _baseline).
%
% The MEG / fMRI data can be imported by running this funciton. In theory,
%   it will get the raw data from the appropriate acquisition folders and
%   convert it (either through maxfiltering or conversion to nifti).
%       - Only requirement is that the subject_notes.txt file is filled out
%           appropriately.
NM_ImportData()


% Check the output to make sure everything looks good

% This function will check that all of the data is as expected (e.g. the 
%   stimuli, matching, triggers, timing, etc., etc.
NM_CheckData();


% Some preprocessing

NM_PreprocessData();


% Make sure our data is ok(ish)

% This will preprocess the data that needs it and then perform simple
%   sanity checks (e.g. visual responses, fmri localizer...)
NM_PerformSanityChecks();


% Now, should run the analysis functions

NM_AnalyzeData();
