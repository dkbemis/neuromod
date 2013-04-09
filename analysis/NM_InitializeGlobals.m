%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_InitializeGlobals.m
%
% This function sets the globals necessary to drive the analysis.
%   This should (and must at least in some form) be run before any analysis
%   is started. 
%
% * Change the values in this file to run a different analysis.
%
% Inputs:
% Outputs:
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_InitializeGlobals()

% These are the folders at the top level of the analysis

% Home
% global GLA_meeg_dir; GLA_meeg_dir = '/Users/Doug/Documents/neurospin/meeg';
% global GLA_fmri_dir; GLA_fmri_dir = '/Users/Doug/Documents/neurospin/fmri';

% WorkNM_Disp
global GLA_meeg_dir; GLA_meeg_dir = '/neurospin/meg/meg_tmp/SimpComp_Doug_2013';
global GLA_fmri_dir; GLA_fmri_dir = '/neurospin/unicog/protocols/IRMf/SimpComp_Bemis_2013';

% The current analysis parameters
global GLA_subject; GLA_subject = 'ap100009';
global GLA_rec_type; GLA_rec_type = 'meeg';
global GLA_meeg_type; GLA_meeg_type = 'meg'; 
global GLA_trial_type; GLA_trial_type = 'blinks'; 
global GLA_fmri_type; GLA_fmri_type = 'localizer';                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          
