% Checks the various data...
function NM_PerformSanityChecks()

% This looks for high accuracy 
NM_SanityCheckResponses();

% Checks the baselines
NM_SanityCheckETData();

% Checks the visual response in the M/EEG data
global GLA_meeg_type;
m_types = {'meg','eeg'};
for t = 1:length(m_types)
    GLA_meeg_type = m_types{t};
    NM_SanityCheckMEEGData();
end

% Analyzes the localizer
NM_SanityCheckfMRIData();

