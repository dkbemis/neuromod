function et_subject_id = NeuroMod_SetupSubject(subj, rsp_type)

% Setup the subject 
global GL_subject; GL_subject = subj;
et_subject_id = GL_subject(1:min(6,length(GL_subject)));
NeuroMod_SetResponseKeys(rsp_type);

% Randomize the counter for older versions of matlab
rand('twister',sum(100*clock)); %#ok<RAND>
