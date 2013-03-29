% Helper to make sure we're keeping good time

function NM_CheckLogTiming()

% Load the data
NM_LoadSubjectData({{'log_checked',1}});

% Gather data for each run
global GLA_subject_data;
for r = 1:GLA_subject_data.parameters.num_runs
    GLA_subject_data.runs(r).log_timing.intervals = getRunIntervals(r);
    checkRunTiming(r);
end

% And save
NM_SaveSubjectData({{'log_timing_checked',1}});
disp('Log timing checked.');


function checkRunTiming(r)

global GLA_subject_data;
disp(['Checking log timing for run ' num2str(r) '...']);

% Store some summaries
GLA_subject_data.runs(r).log_timing.interval_means = ...
    mean(GLA_subject_data.runs(r).log_timing.intervals);
GLA_subject_data.runs(r).log_timing.interval_stds = ...
    std(GLA_subject_data.runs(r).log_timing.intervals);

% And check the stimuli and the delay
fix_time = 0.6;
checkStimulusTiming(GLA_subject_data.runs(r).log_timing.interval_means(1),...
    GLA_subject_data.runs(r).log_timing.interval_stds(1),fix_time,'fixation');

stim_time = 0.2; ISI = 0.4;
for s = 1:GLA_subject_data.parameters.num_critical_stim
    checkStimulusTiming(GLA_subject_data.runs(r).log_timing.interval_means(s*2),...
        GLA_subject_data.runs(r).log_timing.interval_stds(s*2),stim_time,['stim ' num2str(s)]);
    checkStimulusTiming(GLA_subject_data.runs(r).log_timing.interval_means(s*2+1),...
        GLA_subject_data.runs(r).log_timing.interval_stds(s*2+1),ISI,['ISI ' num2str(s)]);     
end

% And the delay
delay_time = 2;
checkStimulusTiming(GLA_subject_data.runs(r).log_timing.interval_means(12),...
    GLA_subject_data.runs(r).log_timing.interval_stds(12),delay_time,'delay');

disp('Timing is good.');
disp(' ');


function checkStimulusTiming(observed, deviation, ideal, label)

tolerance = .005;
if abs(observed - ideal) > tolerance
    disp('WARNING: Timing is bad.');
end
disp([label ' timing error: ' num2str(1000*abs(observed-ideal)) 'ms ['...
    num2str(1000*deviation) 'ms std.]']);


function intervals = getRunIntervals(num)

global GLA_subject_data;
for t = 1:length(GLA_subject_data.runs(num).trials)
    ints = getTrialIntervals(GLA_subject_data.runs(num).trials(t));
    
    % Timeouts have fewer intervals
    if strcmp(GLA_subject_data.runs(num).trials(t).response.key,'TIMEOUT')
        ints = [ints; 0];
    end
    
    % Final trial can have many more
    if t == length(GLA_subject_data.runs(num).trials)
        ints = ints(1:size(intervals,2));
    end
    intervals(t,:) = ints;
    
    % And the ITI
    if t < length(GLA_subject_data.runs(num).trials)
        intervals(t,end) = GLA_subject_data.runs(num).trials(t+1).log_stims(1).log_time -...
            GLA_subject_data.runs(num).trials(t).log_stims(end).log_time;

    % Just set to the mean if there is no ITI
    else
        intervals(t,end) = mean(intervals(1:end-1,end));
    end
end


function intervals = getTrialIntervals(trial)

intervals = zeros(length(trial.log_stims),1);
for s = 1:length(trial.log_stims)-1
    intervals(s) = trial.log_stims(s+1).log_time -...
        trial.log_stims(s).log_time;
end

