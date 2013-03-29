
% Helper to get the first consonant string
function c_str = NeuroMod_GetInitialConsonantString

global GL_initial_cons_lengths;

% For now, make a random string from all the letters
%    of a random length
len = floor(rand*diff(GL_initial_cons_lengths)) + GL_initial_cons_lengths(1);
dummy = '';
for i = 1:len
    dummy = [dummy 'X']; 
end
c_str = NeuroMod_GetConsonantString(dummy,{});


