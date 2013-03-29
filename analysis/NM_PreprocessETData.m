% Helper to clean up the responses 
%
% For now, just marks as outliers responses
%   that are faster than 200ms or slower than 2500ms

function NM_PreprocessETData()

% Load the checked data
disp('Loading data...');
NM_LoadSubjectData({{'et_triggers_checked',1}});
disp('Done.');

global GLA_subject_data;
if ~GLA_subject_data.parameters.eye_tracker
    disp('No eye tracking data.');
    return;
end

global GLA_subject;
disp(['Preprocessing eye tracking data for ' GLA_subject '...']);

% Grab data for each trial
et_data = [];
for r = 1:length(GLA_subject_data.runs)
    et_data = getRunData(r, et_data);
end

% Resave...
save_file = [NM_GetCurrentDataDirectory() '/eye_tracking_data/'...
    GLA_subject '/' GLA_subject '_et_preprocessed.mat'];
save(save_file,'et_data');
disp('Eye tracking data preprocessed.');
NM_SaveSubjectData({{'et_data_preprocessed',1}});

function et_data = getRunData(r, et_data)

% Load it up
global GLA_subject;
disp(['Parsing run ' num2str(r) '...']);
fid = fopen([NM_GetCurrentDataDirectory() '/eye_tracking_data/' ...
    GLA_subject '/' GLA_subject '_run_' num2str(r) '.asc']);

% Only looking for the MEG trigger lines...
C = textscan(fid,'%s%s%s%s%s');
fclose(fid);

% Get each trial data
global GLA_subject_data;
for t = 1:length(GLA_subject_data.runs(r).trials)
    et_data = NM_AddStructToArray(getData(GLA_subject_data.runs(r).trials(t),C),et_data);
end
disp('Done.');


function et_data = getData(trial, C)

% Get the critical trigger
global GLA_subject_data;
t_time = trial.et_triggers(GLA_subject_data.parameters.num_critical_stim).et_time;

% Find it
baseline = 200;
ind = find(strcmp(C{1},num2str(t_time-baseline)));

% Grab the values
post = 600;
t = t_time-baseline;
et_data.x_pos = []; et_data.y_pos = []; et_data.pupil = [];
while isnan(str2double(C{1}{ind})) || ...
        str2double(C{1}{ind}) < t_time+post

    % Skip the messages...
    if str2double(C{1}{ind}) ~= t
        ind = ind+1;
        continue;
    end
    et_data.x_pos(end+1) = str2double(C{2}{ind});
    et_data.y_pos(end+1) = str2double(C{3}{ind});
    et_data.pupil(end+1) = str2double(C{4}{ind});
    t = t+1;
    ind = ind+1; 
end

% Add the condition
et_data.cond = trial.parameters.cond;
et_data.p_l = trial.parameters.p_l;


