function instructions = NeuroMod_GetInstructions(type)

fid = findInstructionLine(type);
instructions = {};
line = fgetl(fid);
while ischar(line) && ~strcmp(line(1),'*')
    instructions{end+1} = NeuroMod_ConvertToUTF8(line); %#ok<*AGROW>
    line = fgetl(fid);
end
fclose(fid);

instructions = replaceFunctionLines(instructions);


function instructions = replaceFunctionLines(instructions)

for i = 1:length(instructions)
    
    ind = strfind(instructions{i},'getContinueStr()');
    if ~isempty(ind)
        instructions{i} = [instructions{i}(1:ind-1) ...
            getContinueStr() instructions{i}(ind+16:end)];
    end
    
    ind = strfind(instructions{i},'getCorrectResponseStr()');
    if ~isempty(ind)
        instructions{i} = [instructions{i}(1:ind-1) ...
            getCorrectResponseStr() instructions{i}(ind+23:end)];
    end
    
    ind = strfind(instructions{i},'getIncorrectResponseStr()');
    if ~isempty(ind)
        instructions{i} = [instructions{i}(1:ind-1) ...
            getIncorrectResponseStr() instructions{i}(ind+25:end)];
    end
end


function fid = findInstructionLine(type)

global GL_use_English_instructions;
if GL_use_English_instructions
    fid = fopen('English_Instructions.txt');
else
    fid = fopen('Instructions.txt');
end

found = 0;
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    if strcmp(line(1),'*')
        [a t] = strread(line,'%s%s'); %#ok<*ASGLU,*REMFF1>
        if strcmp(type,t{1})
            found = 1;
            break;
        end
    end
end
if ~found
    error(['Unknown type ' type '.']);
end


function str = getContinueStr()

if isUsingKeyboard()
    str = NeuroMod_GetInstructions('keyboard_continue');
else
    str = NeuroMod_GetInstructions('machine_continue');
end
str = str{1};


function str = getIncorrectResponseStr()

global GL_keyboard_no_match_key;
global GL_response_type;
if isUsingKeyboard()
    str = NeuroMod_GetInstructions('keyboard_press');
    str = [str{1} ' ''' GL_keyboard_no_match_key ''''];
else
    if strcmp(GL_response_type,'right')
        str = NeuroMod_GetInstructions('left_response');
    else
        str = NeuroMod_GetInstructions('right_response');
    end
    str = str{1};
end


function str = getCorrectResponseStr()

global GL_keyboard_match_key;
global GL_response_type;
if isUsingKeyboard()
    str = NeuroMod_GetInstructions('keyboard_press');
    str = [str{1} ' ''' GL_keyboard_match_key ''''];
else
    if strcmp(GL_response_type,'right')
        str = NeuroMod_GetInstructions('right_response');
    else
        str = NeuroMod_GetInstructions('left_response');
    end
    str = str{1};
end


function use = isUsingKeyboard()
    
global GL_match_key;
global GL_keyboard_match_key;
use = strcmp(GL_match_key, GL_keyboard_match_key);

