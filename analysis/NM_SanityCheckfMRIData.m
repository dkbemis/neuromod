% Check the localizer contrast

function NM_SanityCheckfMRIData()

% Keep these separate for now
global GLA_rec_type;
if ~strcmp(GLA_rec_type,'fmri')
    return;
end

global GLA_subject;
disp(['Sanity checking fMRI data for ' GLA_subject '...']);

% Check movment for both
global GLA_fmri_type; GLA_fmri_type = 'localizer';
NM_CheckfMRIMovement();
GLA_fmri_type = 'experiment';
NM_CheckfMRIMovement();


% Analyze the localizer data
GLA_fmri_type = 'localizer';
NM_AnalyzefMRIData();

% And save
NM_SaveSubjectData({{'fmri_sanity_check',1}});
disp(['Sanity check for fMRI data for ' GLA_subject ' done.']);


