% Convert the localizer stim files for the experiment

function NeuroMod_fMRI_CreateLocalizerStimList(localizer_stim_file)

% Get the parameters
NeuroMod_SetParameters;
NeuroMod_fMRI_SetParameters;

global GL_subject;

% Load them up
mini_blocks = createMiniBlocks(localizer_stim_file);

% Now, print them out
file_name = [GL_subject '_localizer_stim_list.txt'];
fid = NeuroMod_OpenUTF8File(file_name);
for b = 1:length(mini_blocks)
    printMiniBlock(fid,mini_blocks{b});
end
fclose(fid);
NeuroMod_TestFileEncoding(file_name)


% Helper to print
function printMiniBlock(fid,mini_block)

% First the setings
fprintf(fid,[num2str(mini_block{1}) '\t' num2str(mini_block{2}) '\t' ...
    mini_block{3} '\t' mini_block{7} '\t' num2str(mini_block{8}) '\n']);

% Then, each sentence
for s = 1:3
    sentence = mini_block{3+s};
    for w = 1:length(sentence)
        fprintf(fid,[sentence{w} '\t']);
    end
    fprintf(fid,'\n');
end


% Helper to do the initial loading
function mini_blocks = createMiniBlocks(localizer_stim_file)

% Load them
mini_blocks = loadMiniBlocks(localizer_stim_file);

% Set the catch trials
mini_blocks = setCatchTrials(mini_blocks);

% Set the block lengths
mini_blocks = setBlockLength(mini_blocks);



% Helper to set the block length
function mini_blocks = setBlockLength(mini_blocks)

global GL_localizer_IBI;

% Set the length instead of the offset
for b = 1:length(mini_blocks)-1
    mini_blocks{b}{2} = (mini_blocks{b+1}{2}-mini_blocks{b}{2})/1000 + GL_localizer_IBI;
end
mini_blocks{length(mini_blocks)}{2} = -1;



% Helper to set the catch trials
function mini_blocks = setCatchTrials(mini_blocks)

global GL_num_localizer_catch_trials;
global GL_localizer_catch_stims;

% For now, let's not put these randomly. 
% Instead, let's put one in the second block, and then in the middle
if GL_num_localizer_catch_trials ~= 2 || length(GL_localizer_catch_stims) ~= 2
    error('Settings changed.');
end

% Put the first on on 2
mini_blocks{2}{7} = GL_localizer_catch_stims{1};
mini_blocks{2}{8} = 1;

% Put the second on in the middle...
catch_block = round(length(mini_blocks)/2);

% ...unless it's the same condition
if mod(catch_block,2) == 0
    catch_block = catch_block-1;
end
mini_blocks{catch_block}{7} = GL_localizer_catch_stims{2};
mini_blocks{catch_block}{8} = 2;

% % We'll put the catch trials randomly in the stims
% s_ctr = 1;
% b_ord = randperm(length(mini_blocks));
% for c = 1:GL_num_localizer_catch_trials
%     
%     if mod(s_ctr,length(GL_localizer_catch_stims)) == 1
%         s_ord = randperm(length(GL_localizer_catch_stims));
%         s_ctr = 1;
%     end
%     
%     % Set the catch trial word
%     mini_blocks{b_ord(c)}{7} = GL_localizer_catch_stims{s_ord(s_ctr)};
%     s_ctr = s_ctr+1;
%     
%     % And it's placement
%     mini_blocks{b_ord(c)}{8} = ceil(rand*3);
% end


% Helper to load
function mini_blocks = loadMiniBlocks(localizer_stim_file)

mini_blocks = {};
fid = fopen(localizer_stim_file);
header = fgetl(fid); %#ok<*NASGU>
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    mini_blocks{end+1} = parseLocalizerBlock(line); %#ok<*AGROW>
end
fclose(fid);


% Helper to read in another block
function block = parseLocalizerBlock(line)

% The settings for the block
[b_num line] = strtok(line,','); block{1} = str2num(b_num(2:end-1)); %#ok<*ST2NM>
[onset line] = strtok(line,','); block{2} = str2num(onset);
[condition line] = strtok(line,','); block{3} = condition(2:end-1);

s_ctr = 3;
while ~isempty(line)

    % Get the next word (and strip the "")
    [word line] = strtok(line, ','); word = word(2:end-1); %#ok<*STTOK>

    % Might be starting a new sentence / list
    if isempty(word)

        % Check if we've already started a new stim
        if length(block) == s_ctr && ~isempty(block{s_ctr})
            s_ctr = s_ctr+1;
            block{s_ctr} = {};
        end
        continue;
    end
    
    % Add the word
    block{s_ctr}{end+1} = NeuroMod_ConvertToUTF8(word);
end

% Default to no catch trial
block{7} = 'no_catch';
block{8} = 0;





