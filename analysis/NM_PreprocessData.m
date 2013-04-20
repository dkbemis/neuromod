%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_PreprocessData.m
%
% Notes:
%   * A wrapper for preprocessing the data. 
%       - Mostly likely you will run these separately, but this gives all
%           of the functions and settings that are needed to perform the
%           sanity checks.
%
% Inputs:
% Outputs:
% Usage: 
%   * NM_PreprocessData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_PreprocessData()

% The easy stuff
NM_PreprocessBehavioralData();

% Adjust the timing of the triggers with the relative diode timings
NM_AdjustTiming();

% Process these two for now...
trial_types = {'blinks','word_5'};
global GLA_trial_type;
global GLA_meeg_type;
meeg_types = {'meg','eeg'};
for t = 1:length(trial_types)
    GLA_trial_type = trial_types{t};

    % Eye tracking data...
    NM_PreprocessETData();

    % Both meg and eeg
    for m = 1:length(meeg_types)
        GLA_meeg_type = meeg_types{m};
        NM_PreprocessMEEGData();
    end
end

% And both fmri datas
global GLA_fmri_type;
f_types = {'localizer','experiment'};
for t = 1:length(f_types)
    GLA_fmri_type = f_types{t};
    NM_PreprocessfMRIData();
end
    
