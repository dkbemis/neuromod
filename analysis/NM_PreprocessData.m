% Checks the various data...
function NM_PreprocessData()

NM_PreprocessResponses();
NM_PreprocessETData();

% For this global function, just do the blinks and then the final word
global GLA_meeg_type;
global GLA_meeg_trial_type;
m_types = {'meg','eeg'};
for t = 1:length(m_types)
    GLA_meeg_type = m_types{t};
    
    % This gives us the component to reject
    GLA_meeg_trial_type = 'blinks'; %#ok<NASGU>
    NM_PreprocessMEEGData();

    % And then the basic epoch
    GLA_meeg_trial_type = 'word_5';
    NM_PreprocessMEEGData();
end

global GLA_fmri_type;
f_types = {'localizer','experiment'};
for t = 1:length(f_types)
    GLA_fmri_type = f_types{t};
    NM_PreprocessfMRIData();
end
    
