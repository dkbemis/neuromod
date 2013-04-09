
function NM_AnalyzeData()

% Behavioral data
NM_AnalyzeBehavioralData();

% Eye tracking data
NM_AnalyzeETData();

% Both M/EEG data types
global GLA_meeg_type;
m_types = {'meg','eeg'};
for m = 1:length(m_types)
    GLA_meeg_type = m_types{m};
    NM_AnalyzeMEEGData();
end
