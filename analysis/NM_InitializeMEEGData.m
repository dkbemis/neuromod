
function NM_InitializeMEEGData()

% Initialize the data
global GLA_subject;
global GLA_subject_data;
global GLA_meeg_type;
global GLA_meeg_trial_type;
global GLA_meeg_data;
disp(['Initializing ' GLA_meeg_type ' ' GLA_meeg_trial_type ' data...']);
NM_LoadSubjectData({{[GLA_meeg_type '_triggers_checked'],1}});

% Reset
NM_ClearMEEGData();
GLA_meeg_data = [];
GLA_meeg_data.blinks.trials = {};
GLA_meeg_data.blinks.starts = {};
GLA_meeg_data.blinks.stops = {};
GLA_meeg_data.behavioral.outliers = [];
GLA_meeg_data.behavioral.errors = [];
GLA_meeg_data.behavioral.timeouts = [];
GLA_meeg_data.data = {};
GLA_meeg_data.subject = GLA_subject;
GLA_meeg_data.trial_type = GLA_meeg_trial_type;
GLA_meeg_data.channel = 'MEG';

if strcmp(GLA_meeg_trial_type,'blinks')
    processRun('baseline');
else
    for r = 1:GLA_subject_data.parameters.num_runs
        processRun(['run_' num2str(r)]);
    end
end

% And clear the tmp 
global GL_tmp_data;
clear global GL_tmp_data;

% And save
NM_SaveMEEGData();
disp('Done.');


function processRun(run_id)

% Load up the data
global GLA_meeg_data;
global GL_tmp_data;
global GLA_subject;
cfg = [];
cfg.channel = GLA_meeg_data.channel;
cfg.datafile = [NM_GetCurrentDataDirectory() '/meg_data/' ...
    GLA_subject '/' GLA_subject '_' run_id '_sss.fif'];
GL_tmp_data = ft_preprocessing(cfg);

% Then epoch
epochData(run_id);

% And append
if isempty(GLA_meeg_data.data)
    GLA_meeg_data.data = GL_tmp_data;
else
    GLA_meeg_data.data = ft_appenddata([],GLA_meeg_data.data,GL_tmp_data);
end
clear GL_tmp_data;

% And add the blink data
addRunBlinkData(run_id);

% Add the behavioral data
addRunBehavioralData(run_id);


function addRunBehavioralData(run_id)

disp('Adding behavioral data...');

% Nothing to do if baseline
global GLA_meeg_trial_type;
if strcmp(GLA_meeg_trial_type,'blinks')
    return;
end

% Need to have processed the ressponses
global GLA_subject_data;
if ~isfield(GLA_subject_data.parameters,'responses_preprocessed') ||...
        GLA_subject_data.parameters.responses_preprocessed == 0
    NM_PreprocessResponses(); 
end

global GLA_meeg_data;
trials = getTrials(run_id);
for t = 1:length(trials)
    GLA_meeg_data.behavioral.outliers(end+1) = ...
        trials(t).parameters.is_response_outlier;
    GLA_meeg_data.behavioral.errors(end+1) = ...
        trials(t).parameters.acc == 0;
    GLA_meeg_data.behavioral.timeouts(end+1) = ...
        trials(t).parameters.is_timeout;
end



function addRunBlinkData(run_id)

% Load eyetracking data
disp('Adding blink data...');
global GLA_subject;
global GL_blink_data;
fid = fopen([NM_GetCurrentDataDirectory() '/eye_tracking_data/' ...
    GLA_subject '/' GLA_subject '_' run_id '.asc']);
GL_blink_data = textscan(fid,'%s%s%s%s%s');
fclose(fid);

% Add to each trial
[trials trig_id] = getTrials(run_id);

% Make the data
global GLA_meeg_data;
for t = 1:length(trials)
    
    % Get the trigger time
    trig_time = trials(t).et_triggers(trig_id).et_time;

    % And find any blinks
    [GLA_meeg_data.blinks.trials{end+1} GLA_meeg_data.blinks.starts{end+1} ...
        GLA_meeg_data.blinks.stops{end+1}] = ...
        getBlinkData([trig_time+GLA_meeg_data.pre_stim ...
            trig_time+GLA_meeg_data.post_stim-1]);
end

clear GL_blink_data;
disp('Done.');


function [trials trig_id] = getTrials(run_id)

global GLA_subject_data;
global GLA_meeg_trial_type;
if strcmp(GLA_meeg_trial_type,'blinks')
    trials = GLA_subject_data.baseline.blinks;
    trig_id = 1;
elseif strcmp(GLA_meeg_trial_type,'word_5')
    trials = GLA_subject_data.runs(str2double(run_id(end))).trials;
    trig_id = 5;
elseif strcmp(GLA_meeg_trial_type,'word_4')
    trials = GLA_subject_data.runs(str2double(run_id(end))).trials;
    trig_id = 4;
elseif strcmp(GLA_meeg_trial_type,'word_3')
    trials = GLA_subject_data.runs(str2double(run_id(end))).trials;
    trig_id = 3;
elseif strcmp(GLA_meeg_trial_type,'word_2')
    trials = GLA_subject_data.runs(str2double(run_id(end))).trials;
    trig_id = 2;
elseif strcmp(GLA_meeg_trial_type,'word_1')
    trials = GLA_subject_data.runs(str2double(run_id(end))).trials;
    trig_id = 1;
elseif strcmp(GLA_meeg_trial_type,'delay')
    trials = GLA_subject_data.runs(str2double(run_id(end))).trials;
    trig_id = 6;
elseif strcmp(GLA_meeg_trial_type,'target')
    trials = GLA_subject_data.runs(str2double(run_id(end))).trials;
    trig_id = 7;
else
    error('Unimplemented');
end


function [b_data b_starts b_ends] = getBlinkData(epoch)

global GL_blink_data;
ind = find(strcmp(num2str(epoch(1)),GL_blink_data{1})==1);
curr_time = epoch(1);
b_data = zeros(epoch(2)-epoch(1)+1,1);
while curr_time <= epoch(2)

    if str2double(GL_blink_data{4}{ind}) == 0
        b_data(curr_time-epoch(1)+1) = 1; 
    end
    
    % Advance
    t = 0;
    while t ~= curr_time+1
        ind = ind+1;
        t = str2double(GL_blink_data{1}{ind});
    end
    curr_time = t;
end
b_starts = find(diff(b_data) == 1);
b_ends = find(diff(b_data) == -1);


function epochData(run_id)

% Define the trials
disp('Epoching data...');
cfg = [];
cfg.trialfun = 'NM_DefineMEEGTrial';
cfg.run_id = run_id;

% Apply some filtering now, if filtering on raw data
% NOTE: This will have to cut the data some to let the hpf finish
global GLA_subject_data;
if GLA_subject_data.parameters.meeg_filter_raw
    cfg = filterData(cfg);
else
    cfg = ft_definetrial(cfg);
end

% And cut the data
global GL_tmp_data;
GL_tmp_data = ft_redefinetrial(cfg, GL_tmp_data);


function cfg = filterData(cfg)

global GL_tmp_data;
global GLA_subject_data;
global GLA_meeg_data;
global GLA_meeg_trial_type;
GLA_meeg_data.filter_raw = GLA_subject_data.parameters.meeg_filter_raw;
GLA_meeg_data.hpf = GLA_subject_data.parameters.meeg_hpf;
GLA_meeg_data.lpf = GLA_subject_data.parameters.meeg_lpf;
GLA_meeg_data.bsf = GLA_subject_data.parameters.meeg_bsf;
GLA_meeg_data.bsf_width = GLA_subject_data.parameters.meeg_bsf_width;

% Have to cut it so that it'll finish, but wide enough to let the filter work.
% So, reset this and epoch
filter_buffer = 2000;
GLA_subject_data.parameters.(['meeg_' GLA_meeg_trial_type '_epoch'])(1) = ...
    GLA_subject_data.parameters.(['meeg_' GLA_meeg_trial_type '_epoch'])(1) - filter_buffer;
GLA_subject_data.parameters.(['meeg_' GLA_meeg_trial_type '_epoch'])(2) = ...
    GLA_subject_data.parameters.(['meeg_' GLA_meeg_trial_type '_epoch'])(2) + filter_buffer;
cfg = ft_definetrial(cfg);
GL_tmp_data = ft_redefinetrial(cfg, GL_tmp_data);


% High pass...
if ~isempty(GLA_meeg_data.hpf)
    disp(['Applying high pass filter: ' num2str(GLA_meeg_data.hpf) 'Hz...']);
    cfg = []; 
    cfg.hpfilter = 'yes';
    cfg.hpfreq = GLA_meeg_data.hpf;
    if GLA_meeg_data.hpf < 1
        cfg.hpfilttype = 'fir'; % Necessary to not crash
    end
    GL_tmp_data = ft_preprocessing(cfg, GL_tmp_data);
    disp('Done.');
end

% Low pass...
if ~isempty(GLA_meeg_data.lpf)
    disp(['Applying low pass filter: ' num2str(GLA_meeg_data.lpf) 'Hz...']);
    cfg = []; 
    cfg.lpfilter = 'yes';
    cfg.lpfreq = GLA_meeg_data.lpf;
    GL_tmp_data = ft_preprocessing(cfg, GL_tmp_data);
    disp('Done.');
end

% Notches...
for f = 1:length(GLA_meeg_data.bsf)
    disp(['Applying band stop filter: ' num2str(GLA_meeg_data.bsf(f)) 'Hz...']);
    cfg = [];
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [GLA_meeg_data.bsf(f)-GLA_meeg_data.bsf_width ...
        GLA_meeg_data.bsf(f)+GLA_meeg_data.bsf_width];
    GL_tmp_data = ft_preprocessing(cfg, GL_tmp_data);
    disp('Done.');
end


% Reset these, and set to recut
GLA_subject_data.parameters.(['meeg_' GLA_meeg_trial_type '_epoch'])(1) = ...
    GLA_subject_data.parameters.(['meeg_' GLA_meeg_trial_type '_epoch'])(1) + filter_buffer;
GLA_subject_data.parameters.(['meeg_' GLA_meeg_trial_type '_epoch'])(2) = ...
    GLA_subject_data.parameters.(['meeg_' GLA_meeg_trial_type '_epoch'])(2) - filter_buffer;
GLA_meeg_data.pre_stim = GLA_meeg_data.pre_stim + filter_buffer;
GLA_meeg_data.post_stim = GLA_meeg_data.post_stim - filter_buffer;
cfg = [];
cfg.begsample = filter_buffer + 1;
cfg.endsample = filter_buffer + GLA_meeg_data.post_stim - GLA_meeg_data.pre_stim;




