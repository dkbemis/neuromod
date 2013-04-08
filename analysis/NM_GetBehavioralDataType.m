function type = NM_GetBehavioralDataType()
global GLA_rec_type;
global GLA_fmri_type;
if strcmp(GLA_rec_type,'meeg')
    type = 'experiment';
else
    type = GLA_fmri_type;
end
