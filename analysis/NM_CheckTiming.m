% Checks and adjusts all of the timing

function NM_CheckTiming()

% Load the data
loadData();

% Try to set the diode timing, if we haven't
global GLA_subject_data;
if ~isfield(GLA_subject_data.parameters,'diodes_set') || ...
        ~GLA_subject_data.parameters.diodes_set
    NM_GetDiodeTiming();
end

% What we'll be checking / adjusting
trigger_types = {};
if GLA_subject_data.parameters.meg
    trigger_types{end+1} = 'meg';
end
if GLA_subject_data.parameters.eeg
    trigger_types{end+1} = 'eeg';
end
if GLA_subject_data.parameters.eye_tracker
    trigger_types{end+1} = 'et';
end


global GLA_subject;
disp('Checking timing...');
fid = fopen([NM_GetCurrentDataDirectory() '/analysis/'...
    GLA_subject '/' GLA_subject '_timing_report.txt'],'w');

% assess the intervals for each measurement
for r = 1:GLA_subject_data.parameters.num_runs
    checkRunTiming(r, trigger_types, fid);
end

% Now, readjust to the diodes
readjustTriggers(trigger_types, fid)

% And save
fclose(fid);
disp('Done.');
NM_SaveSubjectData({{'timing_checked',1}});
disp('Log timing checked.');


function readjustTriggers(trigger_types, fid)

% Might be nothing to do
global GLA_subject_data;
if ~isfield(GLA_subject_data.parameters,'diodes_set') || ...
        ~GLA_subject_data.parameters.diodes_set
    return;
end

% The run triggers...
all_adjusts = [];
disp('Adjusting trigger timing...');
for r = 1:GLA_subject_data.parameters.num_runs
    for t = 1:length(GLA_subject_data.runs(r).trials)
        [GLA_subject_data.runs(r).trials(t) all_adjusts(end+1:end+length(GLA_subject_data.runs(r).trials(t).meg_triggers))] = ...
            readjustTrialTriggers(GLA_subject_data.runs(r).trials(t), trigger_types);
    end
end

adj_str = ['Adjusted run triggers by ' num2str(mean(all_adjusts)) ' ms avg. [' ...
    num2str(std(all_adjusts)) ' ms std.]'];
disp(adj_str);
fprintf(fid,[adj_str '\n']);


% And the baseline triggers...
all_adjusts = [];
b_types = {'blinks','eye_movements','noise'};
for b = 1:length(b_types)
    for t = 1:length(GLA_subject_data.baseline.(b_types{b}))
        [GLA_subject_data.baseline.(b_types{b})(t) all_adjusts(end+1:end+length(GLA_subject_data.baseline.(b_types{b})(t).meg_triggers))] = ...
            readjustTrialTriggers(GLA_subject_data.baseline.(b_types{b})(t), trigger_types);
    end
end
adj_str = ['Adjusted baseline triggers by ' num2str(mean(all_adjusts)) ' ms avg. [' ...
    num2str(std(all_adjusts)) ' ms std.]'];
disp(adj_str);
fprintf(fid,[adj_str '\n']);


function [trial adjusts] = readjustTrialTriggers(trial, trigger_types)

adjusts = zeros(length(trial.meg_triggers),1);
max_adjust = 150;
for t = 1:length(trial.meg_triggers)
        
    % Find the closest diode and set
    t_time = trial.meg_triggers(t).meg_time;
    adjusts(t) = max_adjust+1;
    for d = 1:length(trial.diode_times)
        if abs(trial.diode_times(d) - t_time) < abs(adjusts(t))
            adjusts(t) = trial.diode_times(d) - t_time;
        end
    end

    % Check
    if abs(adjusts(t)) > max_adjust
        
        % Might be the delay, so just use the average so far...
        if t == 6
             adjusts(t) = round(mean(adjusts(1:t-1)));
        else
            error('Adjustment too big.');
        end
    end
    
    % Set them all
    for i = 1:length(trigger_types)
        trial.([trigger_types{i} '_triggers'])(t).([trigger_types{i} '_unadjusted_time']) = ...
            trial.([trigger_types{i} '_triggers'])(t).([trigger_types{i} '_time']);
        trial.([trigger_types{i} '_triggers'])(t).([trigger_types{i} '_time']) = ...
            trial.([trigger_types{i} '_triggers'])(t).([trigger_types{i} '_time']) + adjusts(t);
    end
end


        
function checkRunTiming(r, trigger_types, fid)

global GLA_subject_data;

% Get the intervals
types = {'log'};
if GLA_subject_data.parameters.meg
    types{end+1} = 'meg';
end
if GLA_subject_data.parameters.eeg
    types{end+1} = 'eeg';
end
if GLA_subject_data.parameters.eye_tracker
    types{end+1} = 'et';
end
if GLA_subject_data.parameters.meg
    types{end+1} = 'diode';
end
for t = 1:length(types)
    GLA_subject_data.runs(r).timing.([types{t} '_intervals']) = getRunIntervals(types{t},r);

    % Store some summaries
    GLA_subject_data.runs(r).timing.([types{t} '_interval_means']) = ...
        mean(GLA_subject_data.runs(r).timing.([types{t} '_intervals']));
    GLA_subject_data.runs(r).timing.([types{t} '_interval_stds']) = ...
        std(GLA_subject_data.runs(r).timing.([types{t} '_intervals']));

    % These are the times we expect, in ms
    switch types{t}
    
        % Log has them all
        case 'log'
            exp_labels = {'fixation','stim_1','ISI_1','stim_2','ISI_2','stim_3','ISI_3',...
                'stim_4','ISI_4','stim_5','ISI_5','delay'};
            exp_times = [600 200 400 200 400 200 400 200 400 200 400 2000];
    
        % Diode has most of them
        case 'diode'
            exp_labels = {'stim_1','ISI_1','stim_2','ISI_2','stim_3','ISI_3',...
                'stim_4','ISI_4','stim_5','ISI_5+delay'};
            exp_times = [200 400 200 400 200 400 200 400 200 2400];
    
        % All of the other triggers have one per stim
        otherwise
            exp_labels = {'stim_1+ISI_1','stim_2+ISI_2','stim_3+ISI_3',...
                'stim_4+ISI_4','stim_5+ISI_5','delay'};
            exp_times = [600 600 600 600 600 2000];
    
    end            
    tolerance = 5;
    
    % And check them
    for s = 1:length(exp_times)
        checkStimulusTiming(GLA_subject_data.runs(r).timing.([types{t} '_interval_means'])(s),...
            GLA_subject_data.runs(r).timing.([types{t} '_interval_stds'])(s),...
            exp_times(s),exp_labels{s},types{t}, tolerance, fid);
    end
end

% Now, check different trigger computers
for t = 1:length(trigger_types)
    for t2 = t+1:length(trigger_types)
        total_diff = 0;
        
        % See if there's a systematic difference
        for i = 1:size(GLA_subject_data.runs(r).timing.([trigger_types{t} '_intervals']),1)
            
            % NOTE: Last one is ITI, so will even out...
            for j = 1:size(GLA_subject_data.runs(r).timing.([trigger_types{t} '_intervals']),2)-1
                total_diff = total_diff + GLA_subject_data.runs(r).timing.([trigger_types{t} '_intervals'])(i,j) -...
                    GLA_subject_data.runs(r).timing.([trigger_types{t2} '_intervals'])(i,j);
            end
        end
        diff_str = [trigger_types{t} ' samples minus ' trigger_types{t2} ' samples: ' num2str(total_diff) '.'];
        fprintf(fid, [diff_str '\n']);
        disp(diff_str);
    end
end

done_str = ['Run ' num2str(r) ' timing checked.'];
fprintf(fid, [done_str '\n\n']);
disp(done_str);
disp(' ');


function checkStimulusTiming(observed, deviation, ideal, ...
    label, type, tolerance, fid)

% Convert for log times...
if strcmp(type,'log')
    observed = 1000*observed;
    deviation = 1000*deviation;
end

if abs(observed - ideal) > tolerance
    warn_str = ['WARNING: ' type ' timing is bad for ' label '. Got ' ...
        num2str(observed) ' and expected ' num2str(ideal) '.'];
    disp(warn_str);
    fprintf(fid,[warn_str '\n']);
end

rep_str = [type ': ' label ' timing error: ' num2str((observed-ideal)) 'ms ['...
    num2str(deviation) 'ms std.]'];
disp(rep_str);
fprintf(fid,[rep_str '\n']);



function intervals = getRunIntervals(type, num)

global GLA_subject_data;
for t = 1:length(GLA_subject_data.runs(num).trials)
    ints = getTrialIntervals(type, GLA_subject_data.runs(num).trials(t));
    
    % Timeouts have fewer intervals
    if strcmp(GLA_subject_data.runs(num).trials(t).response.key,'TIMEOUT')
        ints = [ints 0];
    end
    
    % Final trial can have many more
    if t == length(GLA_subject_data.runs(num).trials)
        ints = ints(1:size(intervals,2));
    end
    intervals(t,:) = ints;
    
    % And the ITI
    if t < length(GLA_subject_data.runs(num).trials)
        intervals(t,end) = getTime(type, GLA_subject_data.runs(num).trials(t+1), 1) -...
            getTime(type, GLA_subject_data.runs(num).trials(t), size(intervals,2));

    % Just set to the mean if there is no ITI
    else
        intervals(t,end) = mean(intervals(1:end-1,end));
    end
end


function intervals = getTrialIntervals(type, trial)

ctr = 1;
intervals = [];
while getTime(type,trial,ctr+1) > 0
    intervals(end+1) = getTime(type, trial, ctr+1) -...
        getTime(type, trial, ctr);
    ctr = ctr+1;
end

% For the ITI
intervals(end+1) = 0;


function time = getTime(type, trial, pos)

switch type
    case 'log'
        measures = trial.log_stims;
        
    case 'meg'
        measures = trial.meg_triggers;
        
    case 'eeg'
        measures = trial.eeg_triggers;
        
    case 'et'
        measures = trial.et_triggers;
        
    case 'diode'
        measures = trial.diode_times;
        
    otherwise
        error('Unknown type');
end    

if pos > length(measures)
    time = -1;
    
% This one is different...
elseif strcmp(type,'diode')
    time = measures(pos);
else
    time = measures(pos).([type '_time']);
end



% Make sure we've done all that we can do
function loadData()

NM_LoadSubjectData({{'log_checked',1}});

% Make sure we've processed everything we can
global GLA_subject_data;
if GLA_subject_data.parameters.eye_tracker && ...
        (~isfield(GLA_subject_data.parameters,'et_triggers_checked') ||...
        ~GLA_subject_data.parameters.et_triggers_checked)
    NM_CheckETTriggers(); 
end
if GLA_subject_data.parameters.meg && ...
        ~GLA_subject_data.parameters.meg_triggers_checked
    NM_CheckMEGTriggers(); 
end
if GLA_subject_data.parameters.eeg && ...
        ~GLA_subject_data.parameters.eeg_triggers_checked
    NM_CheckEEGTriggers(); 
end
if ~GLA_subject_data.parameters.data_file_checked
    NM_CheckDataFile();
end

