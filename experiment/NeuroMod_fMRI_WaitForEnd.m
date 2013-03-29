% Helper to just record volume starts until the end

function NeuroMod_fMRI_WaitForEnd(stim)

global GL_vertical_offset;
global GL_fMRI_acq_TTL;
global PTBLastKeyPress;
global GL_advance_key;
response = GL_fMRI_acq_TTL;
while strcmp(response,GL_fMRI_acq_TTL)

    % Get the next one
    PTBDisplayText(stim, {'center', [0 GL_vertical_offset]},...
        {GL_fMRI_acq_TTL, GL_advance_key});
    
    % See what we got
    PTBDisplayText(stim, {'center', [0 GL_vertical_offset]}, {.1});
    response = PTBLastKeyPress;
end


