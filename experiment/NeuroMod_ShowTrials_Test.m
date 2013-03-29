
% Show all the trials in a file
function NeuroMod_ShowTrials_Test(start_time, file_name)

% TTest
global GL_vertical_offset;
global PTBLastKeyPressTime;
for o = randperm(2)
    
    if o == 1
%         PTBDisplayParagraph({'The next set of trials will be phrases.',...
%         'Press any key to continue.'}, {'center', 30, GL_vertical_offset}, {'any'});
        PTBDisplayParagraph({'Les prochains essais seront des phrases.',...
        'Appuyez sur une touche quelconque pour continuer.'}, {'center', 30, GL_vertical_offset}, {'any'});
    else
        PTBDisplayParagraph({'Les prochains essais seront des listes.',...
        'Appuyez sur une touche quelconque pour continuer.'}, {'center', 30, GL_vertical_offset}, {'any'});
    end
    PTBDisplayBlank({.5},'');

    % Run through the stimuli
    start_time = PTBLastKeyPressTime + .5;

% Go until we reach the end of the file
fid = fopen(file_name);
while 1

    % Get the next stim
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    [stims probe ITI answer stim_trigger critical_trigger...
        delay_trigger probe_trigger] = parseNextStim(line,o);
    
    if isempty(stims)
        continue;
    end
    
    % And run the trial
    [response start_time] = performTrial(start_time, stims, probe, ITI,...
        stim_trigger, critical_trigger, delay_trigger, probe_trigger);

    % Some feedback
    start_time = showFeedback(answer, response, start_time);        
end
fclose(fid);

end

% Show a trial

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
        stims{s} = upper(native2unicode(stims{s}-0,'UTF-8')); 
    end
else
    for s = 1:length(stims)
        stims{s} = lower(native2unicode(stims{s}-0,'UTF-8')); 
    end
end

if GL_probe_case == 1
    probe = upper(native2unicode(probe-0,'UTF-8')); 
else
    probe = lower(native2unicode(probe-0,'UTF-8'));     
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

% TTest
if (type == 1 && strcmp(p_l,'list')) || ...
    (type == 2 && strcmp(p_l,'phrase')) 
    stims = [];
    return;
end

% Add them all to the log and the list
stims{end+1} = stim_1{1}; stims{end+1} = stim_2{1}; ...
    stims{end+1} = stim_3{1}; stims{end+1} = stim_4{1};  %#ok<*AGROW>
PTBSetLogAppend(1,'clear',{num2str(b_num), num2str(i_num), ...
    n_v{1}, p_l{1}, num2str(condition), num2str(a_place), answer{1}});

for i = 1:length(stims)
    PTBSetLogAppend('end','',{stims{i}});
end
PTBSetLogAppend('end','', {probe{1}});

% Make these more friendly
answer = answer{1};
probe = probe{1};



% Helper to show some feedback
function start_time = showFeedback(answer, response, start_time)

% Might need to tell them to be faster
global GL_use_speed_feedback;
global GL_speed_feedback_time;
if GL_use_speed_feedback && strcmp(response,'TIMEOUT')
    start_time = start_time + GL_speed_feedback_time;
%     PTBDisplayText('Please respond faster.', {'center'},{GL_speed_feedback_time});
    PTBDisplayText('Merci de répondre plus vite.', {'center'},{GL_speed_feedback_time});
    return;
end

% Might not need it
global GL_feedback_type;
if GL_feedback_type == 0
    return;
end

% Might have been right
global GL_match_key;
global GL_no_match_key;
if (strcmp('match',answer) && strcmp(response,GL_match_key)) ||...
        (~isempty(strfind(answer,'nomatch')) && strcmp(response,GL_no_match_key))
   return;
end

% Otherwise, give the feedback
if GL_feedback_type == 1
    start_time = start_time + 1;
%     PTBDisplayText('WRONG', {'center'},{.9});
    PTBDisplayText('FAUX', {'center'},{.9});
else
    start_time = start_time + 2;
    PTBPlaySoundFile('BUZZER.wav',{'end'});
end



