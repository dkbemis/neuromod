
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Helper to create the phrases
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [c_str con_strs] = NeuroMod_GetConsonantString(word, con_strs)

% See if we already made it
for c = 1:length(con_strs)
    if strcmp(word,con_strs{c}{1})
        c_str = con_strs{c}{2};
        return;
    end
end

% Otherwise, make one
cs = {'q','w','r','t','p','s','d','f','g','h','j','k','l','z','x','c','v','b','n','m'};
c_str = '';
for i = 1:length(word)
    
    % Randomize the list if needed
    if mod(i,length(cs)) == 1
        c_ind = randperm(length(cs));
    end

    % Add to the string
    c_str = [c_str cs{c_ind(i)}]; 
end

% And add so we don't remake it
con_strs{end+1} = {word,c_str};

