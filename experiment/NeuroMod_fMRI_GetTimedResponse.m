
% Helper to get a timed response.
% If the response comes in time, then we'll show the delay stim for the
% rest of the time.
% If not, then we'll just move on
% NOTE: time_limit is the limit to respond. start_time expected as the
% absolute time to start the response at.
function [start_time response] = NeuroMod_fMRI_GetTimedResponse(response_stim, response_trigger,...
    delay_stim, response_keys, start_time, time_limit, resp_size, resp_color, resp_font,...
    blank_size, blank_color, blank_font)

% Default the formatting
if ~exist('resp_size','var')
    resp_size = '';
end
if ~exist('resp_color','var')
    resp_color = '';
end
if ~exist('resp_font','var')
    resp_font = '';
end
if ~exist('blank_size','var')
    blank_size = '';
end
if ~exist('blank_color','var')
    blank_color = '';
end
if ~exist('blank_font','var')
    blank_font = '';
end


global PTBLastKeyPress;
check_time = 0.05;

% First, set for a time-out and response
duration = {start_time+time_limit-check_time};
for r = 1:length(response_keys)
    duration{end+1} = response_keys{r};  %#ok<*AGROW>
end
NeuroMod_DisplayFormattedText(response_stim, 0, ...
    duration,resp_size,resp_color,resp_font,response_trigger);

% See what happened
PTBDisplayBlank({check_time},'');

% Might be done
if strcmp(PTBLastKeyPress,'TIMEOUT')
    response = 'TIMEOUT';
    start_time = start_time+time_limit;
    return;
end

% Otherwise, display until we're done
start_time = NeuroMod_DisplayFormattedText(delay_stim, 0, ...
    start_time+time_limit-check_time, blank_size, blank_color, blank_font);

% Get the response
PTBDisplayBlank({check_time},'');
response = PTBLastKeyPress;


