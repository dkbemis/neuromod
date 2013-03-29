% Helper to make sure we're keeping good time

function NM_GetDiodeTiming()

% Load the data
disp('Finding diode timing...');
NM_LoadSubjectData({{'log_checked',1}});

% Only applicable for meg data
global GLA_subject_data;
if ~GLA_subject_data.parameters.meg
    disp('Cannot check diode timing, because no MEG data recorded.');
    return;
end

% Find for each run
for r = 1:GLA_subject_data.parameters.num_runs
    GLA_subject_data.runs(r).trials = setRunDiodes(...
        ['run_' num2str(r)], GLA_subject_data.runs(r).trials);
end

b_types = {'blinks','eye_movements','noise'};
for t = 1:length(b_types)
    GLA_subject_data.baseline.(b_types{t}) = setRunDiodes(...
        'baseline', GLA_subject_data.baseline.(b_types{t}));
end

% And save
NM_SaveSubjectData({{'diodes_set',1}});
disp('Diodes found.');


function trials = setRunDiodes(run_id, trials)

% Get the diode times
global TTest_d_times;
TTest_d_times = readDiodeTimes(run_id);
d_times = TTest_d_times;

% Find the first trigger diode
for d = 1:length(d_times)
    if abs(d_times(d) - trials(1).meg_triggers(1).meg_time) < 200
        d_times = d_times(d:end);
        break;
    end
end


% Check and set
for t = 1:length(trials)
    [trials(t).diode_times d_times] = setTrialDiodes(trials(t), d_times);
end


function [trial_diodes d_times] = setTrialDiodes(trial, d_times)

% Check against each meg trigger
max_delay = 100;     
trial_diodes = [];
for t = 1:length(trial.meg_triggers)

    % Could do this automatically, but faster and more secure to make sure
    % we have all of them and they occur in order
    % NOTE: Always expecting the diode after the trigger.
    next_d_time = d_times(1); 
    if (next_d_time - trial.meg_triggers(t).meg_time) > max_delay ||...
            (next_d_time < trial.meg_triggers(t).meg_time)
        
        % No diode for the delay start
        if t == 6
            continue;
        end
        error('Bad diode time.');
    end
    d_times = d_times(2:end);    
    trial_diodes(end+1) = next_d_time; %#ok<AGROW>

    % Nothing to check the offsets against...
    next_d_time = d_times(1); d_times = d_times(2:end);
    trial_diodes(end+1) = next_d_time; %#ok<AGROW>
end


    

function d_times = readDiodeTimes(run_id)

% Load the info
global GLA_subject;
file_name = [NM_GetCurrentDataDirectory() '/meg_data/' GLA_subject '/'...    
    GLA_subject '_' run_id '_sss.fif'];
hdr = ft_read_header(file_name);

% Get the diode index
d_ind = find(strcmp(hdr.label,'MISC004'));

% Load all at once, unless we start hitting space issues
disp('Loading trigger line data...');
dat = ft_read_data(file_name,'chanindx',d_ind);
disp('Done.');

% Get all of the onsets and offsets
diode_threshold = 0.1;
on_ind = find(dat > diode_threshold);
d_times = sort(on_ind([1,find(diff(on_ind) > 1)+1, find(diff(on_ind) > 1)-1, end]));



