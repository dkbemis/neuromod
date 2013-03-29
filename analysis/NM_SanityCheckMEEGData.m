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

% Plot the averages for the final word
global GLA_meeg_trial_type;
GLA_meeg_trial_type = 'word_5';

% Save into the analysis folder
curr_dir = pwd;
cd([NM_GetCurrentDataDirectory() '/analysis/' GLA_subject ]);
NM_DisplayMEEGAverages([GLA_subject '_sanity_check']);
cd(curr_dir);


