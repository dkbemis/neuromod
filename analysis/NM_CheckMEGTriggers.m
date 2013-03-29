% Helper to parse and check the triggers from the eye tracker file
%
% NOTE: Already confirmed that the log accurately reflects what was
%   displayed during the experiment. 
%
% This will then add the triggers to the trial structures

function NM_CheckMEGTriggers()

% Load / create the data
NM_LoadSubjectData({{'log_parsed',1}});

global GLA_subject_data;
if ~GLA_subject_data.parameters.meg
    return;
end

global GLA_subject;
disp(['Checking MEG triggers for ' GLA_subject '...']);

% Check the runs
for r = 1:GLA_subject_data.parameters.num_runs
    meg_triggers = parseRun(['run_' num2str(r)]);
    GLA_subject_data.runs(r).trials = NM_CheckMEEGRunTriggers('meg',...
        GLA_subject_data.runs(r).trials,meg_triggers);
end 

% Check the baseline
meg_triggers = parseRun('baseline');

% NOTE: Will need to generalize if order of baseline tasks changes or are
% not parsed in order
last_t_ind = 0;
b_tasks = fieldnames(GLA_subject_data.baseline);
for b = 1:length(b_tasks)
    if ~isempty(GLA_subject_data.baseline.(b_tasks{b}))
        [GLA_subject_data.baseline.(b_tasks{b}) last_t_ind] = ...
            NM_CheckMEEGRunTriggers('meg', GLA_subject_data.baseline.(b_tasks{b}), ...
            meg_triggers(last_t_ind+1:end));
    end
end

% Resave...
NM_SaveSubjectData({{'meg_triggers_checked',1}});
disp('All MEG triggers accounted for.');


% This function obtains all of the relevant trigger values from the .fif files.
function triggers = parseRun(run_id)

% Load it up
disp(['Parsing ' run_id '...']);

% Reads the data for all of the separate on triggers
%   * num_trig_line cells, each with an array of onsets
t_times = readTriggerLines(run_id);

% Orders them into a single array with values
%   * 2xnum_onsets: [time decimal_val_of_line]
t_times = orderTriggers(t_times);

% Condenses the ordered array into triggers
%   * Adds the values that occurred at the same time
t_times = condenseTriggers(t_times);

% And convert them to useable structs
triggers = {};
for t = 1:length(t_times)
    triggers = NM_AddStructToArray(createTriggerStruct(t_times(t,1), t_times(t,2)), triggers);
end
disp(['Found ' num2str(length(triggers)) ' triggers in ' run_id '.']);


function trigger = createTriggerStruct(time, val)

trigger.meg_time = time;
trigger.value = val;


function t_times = condenseTriggers(all_t_times)

% Give some leeway, so a new trigger has to be at least 30ms away
min_trig_dist = 30;

% Group and add all times that are the same
curr_time = all_t_times(1,1);
curr_val = all_t_times(1,2);
used = [];
t_times = zeros(0,2);
for t = 2:length(all_t_times)
    
    % Might be starting a new one
    if abs(all_t_times(t) - curr_time) > min_trig_dist
        
        % Store the old one
        t_times(end+1,:) = [curr_time curr_val]; %#ok<AGROW>
        
        % And restart
        curr_time = all_t_times(t,1);
        curr_val = all_t_times(t,2);
        used = curr_val;
        
    % Or continuing an old one
    else
        if isempty(find(used == all_t_times(t,2),1))
            curr_val = curr_val + all_t_times(t,2);   
            used(end+1) = all_t_times(t,2); %#ok<AGROW>
        end
    end
end

% And store the last one
t_times(end+1,:) = [curr_time curr_val]; 


function t_times = orderTriggers(line_t_times)

t_times = zeros(0,2);
for line = 1:length(line_t_times)
    for t = 1:length(line_t_times{line})
        t_times(end+1,:) = [line_t_times{line}(t) 2^(line-1)]; %#ok<AGROW>
    end
end

% And order them
[val ord] = sort(t_times(:,1)); %#ok<ASGLU>
t_times = t_times(ord,:);


function t_times = readTriggerLines(run_id)

% Load the info
global GLA_subject;
file_name = [NM_GetCurrentDataDirectory() '/meg_data/' GLA_subject '/'...    
    GLA_subject '_' run_id '_sss.fif'];
hdr = ft_read_header(file_name);

% Get the line indices
num_trigger_lines = 8;
line_inds = zeros(num_trigger_lines,1);
for l = 1:num_trigger_lines
    line_inds(l) = find(strcmp(hdr.label,['STI00' num2str(l)]));
end

% Load all at once, unless we start hitting space issues
disp('Loading trigger line data...');
dat = ft_read_data(file_name,'chanindx',line_inds);
disp('Done.');

% Check all of the trigger lines
t_times = {};
trigger_threshold = 2.5;
for l = 1:num_trigger_lines
    
    % For now, we take them all, and then later filter out extraneous
    % values...
    on_ind = find(dat(l,:) > trigger_threshold);
    if ~isempty(on_ind)
        t_times{l} = on_ind([1, find(diff(on_ind) > 1)+1]); %#ok<AGROW>
    else
        t_times{l} = []; 
    end
end

% And add extraneous where they were on already
for l = 1:num_trigger_lines
    for l2 = l+1:num_trigger_lines
        t_times{l2}  = unique([t_times{l2} ...
            t_times{l}(dat(l2,t_times{l})>trigger_threshold)]); %#ok<AGROW>
    end
end



