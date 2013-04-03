
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Helper to read in the stimuli
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function values = NeuroMod_ReadStimFile(name, col)

if ~exist('col','var')
    col = 1; 
end
if col == 1 || col == 7
    values = {};
else
    values = [];
end
fid = fopen([name '_matched.txt']);
if fid < 0
    error('Unable to open file.');
end
header = fgetl(fid); %#ok<NASGU>
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    
    % Columns:
    %   1 - Words
    %   2 - letters
    %   3 - syllables
    %   4 - freq (lex)
    %   5 - log freq (lex)
    %   6 - phonemes
    %   7 - type
    %   8 - freq (google)
    %   9 - log freq (google)
    for c = 1:col
        [val line] = strtok(line); %#ok<STTOK>
    end
    if col == 1 || col == 7
        values{end+1} = NeuroMod_ConvertToUTF8(val); %#ok<AGROW>
    else
        values(end+1) = str2double(val);  %#ok<AGROW>
    end
end
