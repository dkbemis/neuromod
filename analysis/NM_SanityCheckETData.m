% Check blinks at the blink triggers and eye position at the eye movements

function NM_SanityCheckETData()

% If we have it
global GLA_subject_data;
if ~GLA_subject_data.parameters.eye_tracker
    return;
end

global GLA_subject;
disp(['Sanity checking eye tracking data for ' GLA_subject '...']);

% Make sure we're processed 
disp('Loading data...');
NM_LoadSubjectData({{'et_triggers_checked',1}});
disp('Done.');

% Load the baseline data
loadETBaselineData();

% Tally the blinks
[b_rt b_length b_missing] = checkBlinks(); %#ok<NASGU,ASGLU>

% Get the eye movement saccades
[m_pos m_rt m_missing] = checkEyeMovements(); %#ok<NASGU>


% Plot and save the results
figure;
scatter(m_pos.left(:,1), -m_pos.left(:,2));
hold on;
scatter(m_pos.right(:,1), -m_pos.right(:,2));
title(['Eye tracker Sanity Check (' GLA_subject ')']);
xlabel('x pos'); ylabel('y pos'); 
a = axis(); axis([0 a(2)+a(1) a(3)+a(4) 0]); a = axis();
legend('left','right');
num_move = GLA_subject_data.parameters.num_eye_movements;
text(mean(m_pos.left(:,1))-50, -(mean(m_pos.left(:,2))+50), ...
    [num2str(mean(m_rt.left)) 'ms (' num2str(100*length(m_pos.left)/num_move) '%)']);
text(mean(m_pos.right(:,1))-50, -(mean(m_pos.right(:,2))+50), ...
    [num2str(mean(m_rt.right)) 'ms (' num2str(100*length(m_pos.right)/num_move) '%)']);
text(.5*a(2)-100, .75*a(3), ['Blinks: ' num2str(mean(b_rt)) 'ms (' ...
    num2str(100*length(b_rt)/GLA_subject_data.parameters.num_blinks) '%)']);
saveas(gcf,[NM_GetCurrentDataDirectory() '/analysis/' GLA_subject '/' GLA_subject '_ET_Sanity_Check.jpg'],'jpg');
NM_SaveSubjectData({{'et_sanity_check',1}});



function [pos rt missing] = checkEyeMovements()

global GLA_subject_data;
% For now, give 2 seconds to move their eyes...
time_out = 2000;
pos.left = []; pos.right = []; 
rt.left = []; rt.right = []; 
missing.left = []; missing.right = []; 
t_values = {{},{},'right','left'};  % Mapping from triggers to types
for m = 1:GLA_subject_data.parameters.num_eye_movements
        
    % Look for a saccades after the trigger
    for t = 1:length(GLA_subject_data.baseline.eye_movements(m).et_triggers)
        
        % NOTE: The trigger values should be 3 and 4...
        t_val = GLA_subject_data.baseline.eye_movements(m).et_triggers(t).value;
        t_time = GLA_subject_data.baseline.eye_movements(m).et_triggers(t).et_time;
        [s_start s_end] = findEvent('SACC', t_time, time_out);

        % Record
        if ~isempty(s_start) && ~isempty(s_end)
            pos.(t_values{t_val})(end+1,:) = s_end(2:3);
            rt.(t_values{t_val})(end+1) = s_start(1)-t_time;
        else
            missing.(t_values{t_val})(end+1) = m;
        end
    end
end

function [b_rts b_lengths missing] = checkBlinks()

global GLA_subject_data;
time_out = 2000;
missing = []; b_rts = []; b_lengths = [];
for b = 1:GLA_subject_data.parameters.num_blinks
    
    % Look for a blink in the trial
    t_time = GLA_subject_data.baseline.blinks(b).et_triggers(1).et_time;
    [b_start b_end] = findEvent('BLINK', t_time, time_out);
    if ~isempty(b_start)
        b_lengths(end+1) = b_end(1)-b_start(1);  %#ok<AGROW>
        b_rts(end+1) = b_start(1) - t_time;  %#ok<AGROW>
    else
        missing(end+1) = b;   %#ok<AGROW>
    end
end


% Retursn the start and end parameters for the event, or [] if not found
function [s_vals e_vals] = findEvent(type,et_time, time_out)

% Get the start and end data points
global GL_et_check_data;
t_start = find(strcmp(num2str(et_time),GL_et_check_data{1}));
t_end = t_start+time_out;

% Find a start and end of the first one in the interval
s_ind = find(strcmp(['S' type],{GL_et_check_data{1}{t_start:t_end-1}}),1); %#ok<*CCAT1>
e_ind = find(strcmp(['E' type],{GL_et_check_data{1}{t_start:t_end-1}}),1);

if ~isempty(s_ind) && ~isempty(e_ind)

    % Get the stats before and after event
    s_vals = getETVals(t_start+s_ind);
    e_vals = getETVals(t_start+e_ind-2);
else
    disp(['No ' type ' found from ' num2str(et_time) ' to '...
        num2str(et_time+time_out) '.']);
    s_vals = []; e_vals = [];
end

function vals = getETVals(ind)
global GL_et_check_data;
for v = 1:4
    vals(v) = str2double(GL_et_check_data{v}{ind}); %#ok<AGROW>
end

function loadETBaselineData()

global GL_et_check_data;
global GLA_subject;
disp('Loading baseline data...');
fid = fopen([NM_GetCurrentDataDirectory() '/eye_tracking_data/' ...
    GLA_subject '/' GLA_subject '_baseline.asc']);
GL_et_check_data = textscan(fid,'%s%s%s%s%s');
fclose(fid);
disp('Done.');


