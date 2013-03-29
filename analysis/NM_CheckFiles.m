% Checks the various data...
function NM_CheckFiles()

% First parse the log files
NM_ParseLogFile();

% This ensures we showed what we meant to
NM_CheckLogFile();

% This checks and adds the responses from the data file
NM_CheckDataFile();

% This checks and adds the eye tracking triggers
NM_CheckETTriggers();

% Check the M/EEG triggers 
global GLA_meeg_type;
meeg_types = {'meg','eeg'};
for t = 1:length(meeg_types)
    GLA_meeg_type = meeg_types{t};
    NM_CheckMEEGTriggers();
end

% Timing check
NM_CheckTiming();
