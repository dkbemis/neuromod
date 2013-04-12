%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: NM_CheckData.m
%
% Notes:
%   * In theory, this function runs the whole analysis, however, it's 
%       primary purpose is to give the structure of the analysis. 
%       - Almost always it would probably be easier to run the functions 
%           one at a time...
%
% Inputs:
% Outputs:
%
% Usage: NM_CheckData()
%
% Author: Douglas K. Bemis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NM_CheckData()

% Make sure all of the files are there
NM_CheckFileStructure();

% This ensures we showed what we meant to
NM_CheckLogFile();

% This checks and adds the responses from the data file
NM_CheckBehavioralData();

% This checks and adds the eye tracking triggers
NM_CheckETData();

% Check the M/EEG triggers 
global GLA_meeg_type;
meeg_types = {'meg','eeg'};
for t = 1:length(meeg_types)
    GLA_meeg_type = meeg_types{t};
    NM_CheckMEEGData();
end
