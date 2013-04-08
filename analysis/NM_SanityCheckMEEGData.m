% Check the visual responses to the critical words

function NM_SanityCheckMEEGData()

% Might be nothing to do
global GLA_rec_type;
if ~strcmp(GLA_rec_type,'meeg')
    return;
end

global GLA_subject;
global GLA_meeg_type;
disp(['Sanity checking ' GLA_meeg_type ' data for ' GLA_subject '...']);
NM_LoadSubjectData({...
    {[GLA_meeg_type '_blinks_data_preprocessed'],1},...
    {[GLA_meeg_type '_word_5_data_preprocessed'],1},...
    });

% Plot the averages for the blinks and the final word
global GLA_trial_type;
types = {'blinks','word_5'};
for t = 1:length(types)
    GLA_trial_type = types{t};

    % Save into the analysis folder
    curr_dir = pwd;
    cd([NM_GetCurrentDataDirectory() '/analysis/' GLA_subject ]);
    NM_DisplayMEEGAverages([GLA_subject '_' types{t} '_' GLA_meeg_type '_averages']);
    cd(curr_dir);
end

