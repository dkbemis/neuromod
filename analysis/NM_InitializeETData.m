
function NM_InitializeETData()

% Initialize the data
global GLA_trial_type;
global GLA_subject;
disp(['Initializing ' GLA_trial_type ' eye tracking data for ' GLA_subject '...']);
NM_LoadSubjectData({{'et_data_checked',1},...
    {'log_checked',1},...
    {'timing_adjusted',1},...   % Make sure the triggers are in the right place
    });

% Reset first
NM_ClearETData();

% Then setup the data structure
global GLA_et_data;
global GLA_subject_data;
GLA_et_data.settings.subject = GLA_subject;
GLA_et_data.settings.trial_type = GLA_trial_type;
GLA_et_data.data.epoch = ...
    GLA_subject_data.parameters.([GLA_trial_type '_epoch']);
GLA_et_data.data.x_pos = {};
GLA_et_data.data.y_pos = {};
GLA_et_data.data.pupil = {};
GLA_et_data.data.blink_starts = {};
GLA_et_data.data.blink_ends = {};
GLA_et_data.data.saccade_starts = {};
GLA_et_data.data.saccade_ends = {};
GLA_et_data.data.cond = [];

% Grab data for each trial
switch GLA_trial_type
    case 'blinks'
        setRunData('baseline');
        
    case 'left_eye_movements'
        setRunData('baseline');
        
    case 'right_eye_movements'
        setRunData('baseline');
        
    case 'word_5'
        for r = 1:length(GLA_subject_data.runs)
            setRunData(['run_' num2str(r)]);
        end
        
    otherwise
        error('Unknown type');
end

% And save
NM_SaveETData();
disp('Done.');


function setRunData(run_id)

% Load up the data
global GLA_subject;
global GL_et_run_data;
disp(['Parsing ' run_id '...']);
fid = fopen([NM_GetCurrentDataDirectory() '/eye_tracking_data/' ...
    GLA_subject '/' GLA_subject '_' run_id '.asc']);
GL_et_run_data = textscan(fid,'%s%s%s%s%s%s%s%s%s%s%s');
fclose(fid);

% Get each trial data
trials = NM_GetTrials(str2double(run_id(end)));

global GLA_et_data;
for t = 1:length(trials)
    
    % Parse the data
    [GLA_et_data.data.x_pos{end+1} GLA_et_data.data.y_pos{end+1} ...
        GLA_et_data.data.pupil{end+1} GLA_et_data.data.blink_starts{end+1}...
        GLA_et_data.data.blink_ends{end+1} GLA_et_data.data.saccade_starts{end+1}...
        GLA_et_data.data.saccade_ends{end+1} GLA_et_data.data.cond(end+1)] = getTrialData(trials(t));
end

% And clear
clear global GL_et_run_data;


function [x_pos y_pos pupil b_starts b_ends s_starts s_ends cond] = getTrialData(trial)

% Get the trigger time
t_time = NM_GetTrialTriggerTime(trial,'et');

% Find the start of the trial in the data
global GLA_subject_data;
global GLA_trial_type;
global GL_et_run_data;
t_epoch = GLA_subject_data.parameters.([GLA_trial_type '_epoch']);
ind = find(strcmp(GL_et_run_data{1},num2str(t_time+t_epoch(1))));

% Grab the values
curr_t = t_time+t_epoch(1);
x_pos = []; y_pos = []; pupil = [];
b_starts = {}; b_ends = {}; s_starts = {}; s_ends = {};
while isnan(str2double(GL_et_run_data{1}{ind})) || ...
        str2double(GL_et_run_data{1}{ind}) < t_time+t_epoch(2)

    % Add the messages...
    if str2double(GL_et_run_data{1}{ind}) ~= curr_t
        switch GL_et_run_data{1}{ind}
            case 'MSG'
                % Noting to do with the triggers...
                
            case 'EFIX'
                % Nothing to do with fixation ends...
                
            case 'SFIX'
                % Nothing to do with fixation starts...
                
            % Record saccade starts
            case 'SSACC'
                s_starts(end+1).time = str2double(GL_et_run_data{3}{ind})-t_time; %#ok<AGROW>
                
            % Record the saccade ends, and stats
            case 'ESACC'
                s_ends(end+1).time = str2double(GL_et_run_data{4}{ind})-t_time; %#ok<AGROW>
                s_ends(end).length = str2double(GL_et_run_data{5}{ind}); 
                s_ends(end).x_start = str2double(GL_et_run_data{6}{ind});
                s_ends(end).y_start = str2double(GL_et_run_data{7}{ind});
                s_ends(end).x_end = str2double(GL_et_run_data{8}{ind});
                s_ends(end).y_end = str2double(GL_et_run_data{9}{ind});
                s_ends(end).unsure = [str2double(GL_et_run_data{10}{ind}) ...
                    str2double(GL_et_run_data{11}{ind})];

            % Record blink starts
            case 'SBLINK'
                b_starts(end+1).time = str2double(GL_et_run_data{3}{ind})-t_time; %#ok<AGROW>

            % Record blink ends
            case 'EBLINK'
                b_ends(end+1).time = str2double(GL_et_run_data{4}{ind})-t_time; %#ok<AGROW>
                b_ends(end).length = str2double(GL_et_run_data{5}{ind});

            otherwise
                error('Unimplemented.');
        end
        ind = ind+1;
        continue;
    end
    x_pos(end+1) = str2double(GL_et_run_data{2}{ind}); %#ok<AGROW>
    y_pos(end+1) = str2double(GL_et_run_data{3}{ind}); %#ok<AGROW>
    pupil(end+1) = str2double(GL_et_run_data{4}{ind}); %#ok<AGROW>
    curr_t = curr_t+1;
    ind = ind+1; 
end

% Check for unexpected nans...
nan_starts = find(diff(isnan(x_pos)) == 1) + t_epoch(1);
nan_ends = find(diff(isnan(x_pos)) == -1) + (t_epoch(1)-1);
for b = 1:length(nan_starts)
    if b_starts(b).time ~= nan_starts(b)
        error('Unexpected blink');
    end
end
for b = 1:length(nan_ends)
    if b_ends(b).time ~= nan_ends(b)
        error('Unexpected blink');
    end
end

% Set the condition
cond = NM_GetTrialCondition(trial);





