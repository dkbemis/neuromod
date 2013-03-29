% Check the visual responses to the critical words

function NM_SanityCheckEEGData()

global GLA_subject;
disp(['Sanity checking EEG data for ' GLA_subject '...']);

% Make sure we're processed 
disp('Loading subject data...');
NM_LoadSubjectData({{'eeg_data_preprocessed',1}});
disp('Done.');

