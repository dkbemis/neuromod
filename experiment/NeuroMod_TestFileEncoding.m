% Tests the encoding by printing the converted words with accents in the
%   input file
%
% To make encodings work:
%   * Write: Use NeuroMod_OpenUTF8File.
%       - Then, just use fprintf on a word that has been read and converted. 
%   % Read: Use NeuroMod_ConvertToUTF8

function testers = NeuroMod_TestFileEncoding(file)

testers = {};

% Open it
fid = fopen(file);
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break; 
    end
    
    % Store all words with non-ASCII encoding
    while ~isempty(line)
        [test line] = strtok(line);  %#ok<STTOK>
        if find(test-0 > 128)
            testers{end+1} = NeuroMod_ConvertToUTF8(test); %#ok<AGROW>
        end
    end
end
