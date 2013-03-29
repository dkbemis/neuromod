% Helper to parse and check the triggers from the eye tracker file
%
% NOTE: Already confirmed that the log accurately reflects what was
%   displayed during the experiment. 
%
% This will then add the triggers to the trial structures

function NM_CheckEEGTriggers()

% Load / create the data
NM_LoadSubjectData({{'log_parsed',1}});

% If necessary
global GLA_subject_data;
if ~GLA_subject_data.parameters.eeg 
    return;    
end

global GLA_subject;
disp(['Checking EEG triggers for ' GLA_subject '...']);

% Check the runs
for r = 1:GLA_subject_data.parameters.num_runs
	eeg_triggers = parseRun(r);
    GLA_subject_data.runs(r).trials = NM_CheckMEEGRunTriggers('eeg',...
        GLA_subject_data.runs(r).trials,eeg_triggers);
end

% Resave...
NM_SaveSubjectData({{'eeg_triggers_checked',1}});
disp('All EEG triggers accounted for.');

        

% This function obtains all of the relevant trigger values from the .fif files.
function triggers = parseRun(run_id)

% Load it up
disp(['Parsing run ' num2str(run_id) '...']);

% Load the data
global GLA_subject
file_name = [NM_GetCurrentDataDirectory() '/eeg_data/' GLA_subject '/'...    
    GLA_subject '_run_' num2str(run_id) '.raw'];
[data.head data.event_data] = NM_ReadEGITriggers(file_name);

min_trig_dist = 30;
t_times = [];
for i = 1:length(data.head.eventcode)

    % This is how to identify the trigger lines...
    if strcmp(data.head.eventcode(i,2),'1') || ...
          strcmp(data.head.eventcode(i,2),'2')
        
        % Find and add to the times
        code = str2double(data.head.eventcode(i,2:end))-128;
        onsets = find(data.event_data(i,:)>0)';
        
        % Don't take those that are too close
        last_time = 0;
        for o = 1:length(onsets)
            if onsets(o) > last_time+min_trig_dist
                t_times(end+1,:) = [onsets(o) code]; %#ok<AGROW>
                last_time = onsets(o);
            end
        end
    end
end

% And order them

[val ord] = sort(t_times(:,1)); %#ok<ASGLU>
t_times = t_times(ord,:);


% And convert them to useable structs
triggers = {};
for t = 1:length(t_times)
    triggers = NM_AddStructToArray(createTriggerStruct(t_times(t,1), t_times(t,2)), triggers);
end
disp(['Found ' num2str(length(triggers)) ' triggers in run ' num2str(run_id) '.']);


function trigger = createTriggerStruct(time, val)

trigger.eeg_time = time;
trigger.value = val;



function createVirtualTriggers(run_id, last_eeg_trig_time)

% Just get the first trigger time and go from there
global GLA_subject_data;
last_log_trig_time = GLA_subject_data.runs(run_id).trials(1).log_triggers(1).log_time;
for t = 1:length(GLA_subject_data.runs(run_id).trials)
    trial_triggers = {};
    for trig = 1:length(GLA_subject_data.runs(run_id).trials(t).log_triggers)
        if strcmp(GLA_subject_data.runs(run_id).trials(t).log_triggers(trig).type,'ParallelPort')
            t_time = round(1000*(GLA_subject_data.runs(run_id).trials(t).log_triggers(trig).log_time...
                - last_log_trig_time) + last_eeg_trig_time);
            t_val = mod(GLA_subject_data.runs(run_id).trials(t).log_triggers(trig).value,128);
            trial_triggers = NM_AddStructToArray(createTriggerStruct(t_time, t_val),trial_triggers);
            last_log_trig_time = GLA_subject_data.runs(run_id).trials(t).log_triggers(trig).log_time;
            last_eeg_trig_time = t_time;
        end
    end
    GLA_subject_data.runs(run_id).trials(t).eeg_triggers = trial_triggers;
end



