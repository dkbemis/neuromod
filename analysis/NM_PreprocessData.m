function NM_PreprocessData()

% The easy stuff
NM_PreprocessBehavioralData();

% Process these for now...
global GLA_trial_type;
global GLA_meeg_type;
meeg_types = {'meg','eeg'};
trial_types = {'blinks','word_5'};
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

global GLA_fmri_type;
f_types = {'localizer','experiment'};
for t = 1:length(f_types)
    GLA_fmri_type = f_types{t};
    NM_PreprocessfMRIData();
end
    
