% Checks the various data...
function NM_CheckData()

% This ensures we showed what we meant to
NM_CheckLog();

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
