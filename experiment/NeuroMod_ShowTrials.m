
% Show all the trials in a file
function NeuroMod_ShowTrials(start_time, file_name)

% Keep a running total
%   - Total, Correct, Timeout
accuracies = zeros(3,1);

global GL_vertical_offset;
global GL_block_stimuli;
global PTBLastKeyPressTime;

if GL_block_stimuli
    types = randperm(2);
else
    types = 0;
end

for t = types

    % Show a screen if we're blocking
    if t > 0
        if t == 1
            PTBDisplayParagraph(NeuroMod_GetInstructions('phrase_trials'),...
                {'center', 30, GL_vertical_offset}, {'any'});
        else            
            PTBDisplayParagraph(NeuroMod_GetInstructions('list_trials'),...
                {'center', 30, GL_vertical_offset}, {'any'});
        end
        PTBDisplayBlank({.5},'');

        % Run through the stimuli
        start_time = PTBLastKeyPressTime + .5;
    end
    
    % Go until we reach the end of the file
    t_ctr = 1;
    fid = fopen(file_name);
    while 1

        % Get the next stim
        line = fgetl(fid);
        if ~ischar(line)
            break;
        end
        [stims probe ITI answer stim_trigger critical_trigger...
            delay_trigger probe_trigger] = parseNextStim(line, t);

        if isempty(stims)
            continue;
        end
        
        % And run the trial
        [response start_time] = performTrial(start_time, stims, probe, ITI,...
            stim_trigger, critical_trigger, delay_trigger, probe_trigger);

        % Some feedback
        [start_time accuracies] = showFeedback(answer, response, start_time, accuracies);        
        disp([num2str(t_ctr) ' - Correct: ' num2str(100*accuracies(2)/accuracies(1))...
            '%; ' num2str(accuracies(3)) ' timeouts.']);
        t_ctr = t_ctr+1;
    end
    fclose(fid);

end


% Show one trial
function [response end_time] = performTrial(start_time, stims, probe, ITI,...
    stim_trigger, critical_trigger, delay_trigger, probe_trigger)

% Trial parameters
global GL_stim_time;
global GL_ISI;
global GL_delay_time;
global GL_use_cross;
global GL_cross_size;
global GL_cross_color;
global GL_probe_case; 
global GL_stim_font; 
global GL_stim_case; 
global GL_stim_size; 
global GL_stim_color; 
global GL_init_cross_time;
global GL_need_response;

% Convert everything here
if GL_stim_case == 1;
    for s = 1:length(stims)
        stims{s} = upper(stims{s}); 
    end
else
    for s = 1:length(stims)
        stims{s} = lower(stims{s}); 
    end
end

if GL_probe_case == 1
    probe = upper(probe); 
else
    probe = lower(probe);     
end

if GL_use_cross
    blank_stim = '+';
else
    blank_stim = ' '; 
end

% Show a cross first
if GL_init_cross_time > 0
    end_time = NeuroMod_DisplayFormattedText('+', start_time, ...
        GL_init_cross_time, GL_cross_size, GL_cross_color, GL_stim_font);
else
    end_time = start_time;
end

% Then, show them all
for s = 1:length(stims)
    if ~isempty(stims{s})
        
        % Set the last one to be "critical" for now
        if s == length(stims)
            trigger = critical_trigger;
        else
            trigger = stim_trigger; 
        end

        % First the stimuli
        end_time = NeuroMod_DisplayFormattedText(stims{s}, end_time, GL_stim_time, ...
            GL_stim_size, GL_stim_color, GL_stim_font, trigger);

        % Then a blank
        end_time = NeuroMod_DisplayFormattedText(blank_stim, end_time, GL_ISI, ...
            GL_cross_size, GL_cross_color, GL_stim_font);
    end
end

% Then the delay period
% Divide up to be able to record the photo square
end_time = NeuroMod_DisplayFormattedText(blank_stim, end_time, GL_delay_time, ...
    GL_cross_size, GL_cross_color, GL_stim_font, delay_trigger, 0);

% Then the probe
% For now, if the ITI is long we'll assume we're in fMRI (or absolute
% timing).
max_ITI = 5;
if ITI > max_ITI && GL_need_response
    [end_time response] = performTimedResponse(probe, probe_trigger,...
        start_time, ITI, blank_stim);
   
% Otherwise, add the ITI at the end
else
    [end_time response] = performUntimedResponse(probe, probe_trigger,...
        end_time, ITI, blank_stim);
end

% Make sure we're back to normal
PTBSetTextFont(GL_stim_font);
PTBSetTextSize(GL_stim_size);
PTBSetTextColor(GL_stim_color);




% Helper for an untimed response

function [end_time response] = performUntimedResponse(probe, probe_trigger,...
    end_time, ITI, blank_stim)

global PTBLastKeyPress;
global PTBLastKeyPressTime;
global GL_probe_proportion;
global GL_match_key;
global GL_no_match_key;
global GL_probe_font;
global GL_probe_size;
global GL_probe_color;
global GL_stim_font;
global GL_cross_size;
global GL_cross_color;
global GL_use_speed_feedback;
global GL_speed_timeout;
global GL_need_response;
global GL_no_response_ITI;
global GL_no_response_probe_time;

response = [];
if GL_need_response && rand < GL_probe_proportion
    
    % Might need to add a timeout
    if GL_use_speed_feedback
        duration = {GL_match_key, GL_no_match_key, end_time+GL_speed_timeout};
    else
        duration = {GL_match_key, GL_no_match_key};
    end
    
    NeuroMod_DisplayFormattedText(probe, -1, duration, ...
        GL_probe_size, GL_probe_color, GL_probe_font, probe_trigger);
        
    % Quick screen to get the response time
    PTBDisplayBlank({.1},'Response_Catcher');
    response = PTBLastKeyPress;

    % Either set to after the response
    if strcmp(response,'TIMEOUT')
        end_time = end_time + GL_speed_timeout + .1;
    else
        end_time = PTBLastKeyPressTime + .1;
    end
    
    % Take away the response catchter time
    ITI = ITI-.1;

% For testing, just show the probe and move on
elseif ~GL_need_response
    ITI = GL_no_response_ITI;
    end_time = end_time + GL_no_response_probe_time;
    NeuroMod_DisplayFormattedText(probe, 0, {'any',end_time}, ...
        GL_probe_size, GL_probe_color, GL_probe_font, probe_trigger);
end

% ITI...
end_time = NeuroMod_DisplayFormattedText(blank_stim, end_time, ITI, ...
    GL_cross_size, GL_cross_color, GL_stim_font);



% Helper for an timed response

function [end_time response] = performTimedResponse(probe, probe_trigger,...
    start_time, time_limit, blank_stim)

global GL_probe_proportion;
global GL_match_key;
global GL_no_match_key;
global GL_probe_font;
global GL_probe_size;
global GL_probe_color;
global GL_stim_font;
global GL_cross_size;
global GL_cross_color;

response = [];
if rand < GL_probe_proportion

    [end_time response] = NeuroMod_fMRI_GetTimedResponse(probe, probe_trigger,...
        blank_stim, {GL_match_key, GL_no_match_key}, start_time, time_limit,...
        GL_probe_size, GL_probe_color, GL_probe_font, ...
        GL_cross_size, GL_cross_color, GL_stim_font);
    
else
    end_time = NeuroMod_DisplayFormattedText(blank_stim, 0, start_time + time_limit, ...
        GL_cross_size, GL_cross_color, GL_stim_font);
end


% Helper to parse the stims

function [stims probe ITI answer stim_trigger critical_trigger...
    delay_trigger probe_trigger] = parseNextStim(line, type)

% Experiment settings
global GL_use_initial_consonants;

% Get the block and item numbers
[b_num line] = strtok(line); 
[i_num line] = strtok(line);

% Parse the initial consonant string
stims = {''};
if GL_use_initial_consonants
    [stims{1} line] = strtok(line); 
end

% Get the rest
[stim_1 stim_2 stim_3 stim_4 ITI condition a_place n_v p_l answer probe...
    stim_trigger critical_trigger delay_trigger probe_trigger] = ...
    strread(line,'%s%s%s%s%f%d%d%s%s%s%s%d%d%d%d'); %#ok<*REMFF1>

% Check that  we want it
if (type == 1 && strcmp(p_l,'list')) || ...
    (type == 2 && strcmp(p_l,'phrase')) 
    stims = [];
    return;
end

% Add them all to the log and the list
stims{end+1} = NeuroMod_ConvertToUTF8(stim_1{1}); 
stims{end+1} = NeuroMod_ConvertToUTF8(stim_2{1}); 
stims{end+1} = NeuroMod_ConvertToUTF8(stim_3{1}); 
stims{end+1} = NeuroMod_ConvertToUTF8(stim_4{1});  %#ok<*AGROW>
probe = NeuroMod_ConvertToUTF8(probe{1});
PTBSetLogAppend(1,'clear',{num2str(b_num), num2str(i_num), ...
    n_v{1}, p_l{1}, num2str(condition), num2str(a_place), answer{1}});

for i = 1:length(stims)
    PTBSetLogAppend('end','',{stims{i}});
end
PTBSetLogAppend('end','', {probe});

% Make more friendly
answer = answer{1};



% Helper to show some feedback
function [start_time accuracies] = showFeedback(answer, response, start_time, accuracies)

% The total
accuracies(1) = accuracies(1)+1;

% Might need to tell them to be faster
global GL_use_speed_feedback;
global GL_speed_feedback_time;
if GL_use_speed_feedback && strcmp(response,'TIMEOUT')
    start_time = start_time + GL_speed_feedback_time;
    PTBDisplayParagraph(NeuroMod_GetInstructions('speed_feedback'),...
        {'center', 30}, {GL_speed_feedback_time});
    accuracies(3) = accuracies(3)+1;
    return;
end

% Might have been right
global GL_match_key;
global GL_no_match_key;
global GL_vertical_offset;
if (strcmp('match',answer) && strcmp(response,GL_match_key)) ||...
        (~isempty(strfind(answer,'nomatch')) && strcmp(response,GL_no_match_key))
    accuracies(2) = accuracies(2)+1;
    return;
elseif strcmp(response,'TIMEOUT')
    accuracies(3) = accuracies(3)+1;
end

% Might not need it
global GL_feedback_type;
if GL_feedback_type == 0
    return;
end

% Otherwise, give the feedback
if GL_feedback_type == 1
    start_time = start_time + GL_speed_feedback_time;
    PTBDisplayParagraph(NeuroMod_GetInstructions('wrong_response'),...
        {'center', 30, GL_vertical_offset}, {GL_speed_feedback_time});
else
    start_time = start_time + 2;
    PTBPlaySoundFile('BUZZER.wav',{'end'});
end



