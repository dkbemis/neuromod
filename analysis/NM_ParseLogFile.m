% Helper to check the log and data file of a run
%
% NOTE: Already confirmed that the log accurately reflects what was
%   displayed during the experiment 
%
% NOTE: Expects cleaned log files (i.e. those without any extraneous
%   or practice runs / responses).
%

% TODO: Update to use the GLA_subject_data global in functions
% TODO: Update to use textscan for faster parsing

function NM_ParseLogFile()

% Load / create the data
global GLA_subject;
global GLA_subject_data;
disp(['Parsing log file for ' GLA_subject '...']);
NM_LoadSubjectData();

% Load the runs
GLA_subject_data.runs = parseRuns();

% Then the localizer
GLA_subject_data.localizer = parseLocalizer();

% And the baseline
GLA_subject_data.baseline = parseBaseline();

% Resave...
disp('Done.');
NM_SaveSubjectData({{'log_parsed',1}});


% Any baseline data log
function baseline = parseBaseline()

for b = {'blinks','eye_movements','noise','mouth_movements','breaths'}
    baseline.(b{1}) = parseRun(b{1});
end


% Then the localizer
function localizer = parseLocalizer()
localizer.blocks = parseRun('localizer');



function runs = parseRuns()

% Slow but automatic...
runs = {};
while 1
    next_run.trials = parseRun(length(runs)+1);
    if ~isempty(next_run.trials)
        runs = NM_AddStructToArray(next_run, runs);
    else
        break; 
    end
end



function trials = parseRun(run_id)

% Set the options for the run type
global GLA_subject;
disp(['Parsing run ' num2str(run_id) '...']);
fid = fopen([NM_GetCurrentDataDirectory() '/logs/' ...
    GLA_subject '/' GLA_subject '_log.txt']);
line = findLine(fid,{{{'ANY'},{'ANY'},{'ANY'},{'ANY'},run_id,1}});

% Find the start
trials = {};
while ~isempty(line) && ischar(line)
    [next_trial line] = parseTrial(line, run_id, length(trials)+1, fid);
    if ~isempty(next_trial) && ~isempty(next_trial.log_stims) && ...
            ((ischar(run_id) && strcmp(run_id,next_trial.log_stims(1).run_id)) ||...
            (isnumeric(run_id) && run_id == next_trial.log_stims(1).run_id))
        trials = NM_AddStructToArray(next_trial, trials);
    else
        break;
    end    
end
disp(['Parsed run ' num2str(run_id) ' with '...
    num2str(length(trials)) ' trials.']);
fclose(fid);



function [trial line] = parseTrial(line,r,t, fid)

trial.log_stims = {};
trial.log_triggers = {};
while 1
    
    % Parse to the end of the trial
    item = parseLogLine(line,r,t);
    
    % See if we've reached a log end
    if isempty(item)
        break;
    end

    % See if we're done with the trial
    if item.trial_num ~= t
        break;
    end
    
    % Or the run
    if (ischar(r) && ~strcmp(r,item.run_id)) ||...
            (isnumeric(r) && r ~= item.run_id)
        break;
    end
        
    
    % Add it to the correct list
    switch item.label
        case 'STIM'
            item.order = length(trial.log_stims)+1;
            trial.log_stims = NM_AddStructToArray(item, trial.log_stims); 

        case 'TRIGGER'
            item.value = str2double(item.value);
            item.order = length(trial.log_triggers)+1;
            trial.log_triggers = NM_AddStructToArray(item, trial.log_triggers); 

        case 'ignored_line'
            % Nothing to do with these...
            
        case 'STIM_PREPARE'
            % Nothing to do with these...
            
        otherwise
            error('Unknown log file line.');
    end
    line = fgetl(fid);
end

function item = parseLogLine(line, run, t_num)

% Might be nothing to do
if isempty(line) || ~ischar(line)
    item = [];
    return;
end

% See which we're parsing
if ischar(run)
    if strcmp(run,'localizer')
        item = parseLocalizerLine(line, run, t_num);
    elseif strcmp(run, 'blinks') || strcmp(run, 'eye_movements') ||...
            strcmp(run, 'noise') || strcmp(run, 'mouth_movements') ||...
            strcmp(run, 'breaths') 
        item = parseBaselineLine(line, run, t_num);
    else
        error('Bad run type.');        
    end
else
    if run > 0
        item = parseRunLine(line,run,t_num);
    else
        error('Bad run num.');
    end
end


function item = parseBaselineLine(line,run,t_num)

C = textscan(line,'%s%s%s%f%s%d%d%d');

% Blanks are structured differently for now....
if isIgnored(C)
    item.label = 'ignored_line';
    item.trial_num = t_num;
    item.run_id = run;
    return;
end

% Unfortunately, some of these are "blanks" which 
%   don't parse right
if isempty(C{4})
    C = textscan(line,'%s%s%f%s%d%d%d');
    for i = length(C):-1:4
        C{i} = C{i-1};
    end
    C{3} = {''};
end

item.label = C{1}{1};
item.type = C{2}{1};
item.value = C{3}{1};
item.log_time = C{4};
item.run_id = C{5}{1};
item.trial_num = C{6};
item.stim_type = C{7};



function item = parseLocalizerLine(line,run,t_num)

C = textscan(line,'%s%s%s%f%s%d%s%s');

% Blanks are structured differently for now....
if isIgnored(C)
    item.label = 'ignored_line';
    item.trial_num = t_num;
    item.run_id = run;
    return;
end
item.label = C{1}{1};
item.type = C{2}{1};
item.value = NeuroMod_ConvertToUTF8(C{3}{1});
item.log_time = C{4};
item.run_id = C{5}{1};
item.trial_num = C{6};
item.block_num = C{6};
item.condition = C{7}{1};
item.stim = NeuroMod_ConvertToUTF8(C{8}{1});



function item = parseRunLine(line,run,t_num)

num_critical_stim = 5;
C = textscan(line,'%s%s%s%f%d%d%s%s%d%d%s%s%s%s%s%s%s');

% Blanks are structured differently for now....
if isIgnored(C)
    item.label = 'ignored_line';
    item.run_id = run;
    item.trial_num = t_num;
    return;
end
item.label = C{1}{1};
item.type = C{2}{1};
item.value = NeuroMod_ConvertToUTF8(C{3}{1});
item.log_time = C{4};
item.run_id = C{5};
item.trial_num = C{6};
item.n_v = C{7}{1};
item.p_l = C{8}{1};
item.cond = C{9};
item.a_p = C{10};
item.answer = C{11}{1};
item.trial_stim = {};
for s = 1:num_critical_stim
    item.trial_stim{s} = NeuroMod_ConvertToUTF8(C{11+s}{1});
end
item.probe = NeuroMod_ConvertToUTF8(C{17}{1});


function is = isIgnored(parse)

% Ignoring blanks and cleanup lines
is = (strcmp(parse{2}{1},'Blank')) ||...
    (strcmp(parse{2}{1},'Cleanup')) ||...
    (strcmp(parse{2}{1},'Paragraph'));


function line = findLine(fid,value_sets)

line = '';
while ischar(line)
    line = fgetl(fid);

    % Check each of the sets
    for v = 1:length(value_sets)
        found = testValueSet(line, value_sets{v});
        if found
            return;
        end
    end
end

% Signal failure
line = '';


function found = testValueSet(line, values)

found = 1;
for v = 1:length(values)
    if isempty(line)
        found = 0;
        return;
    end
    [test_val line] = strtok(line); %#ok<STTOK>
    if ischar(values{v})
        if ~strcmp(values{v}, test_val)
            found = 0;
            return;
        end
    elseif isnumeric(values{v})
        if values{v} ~= str2double(test_val)
            found = 0;
            return;
        end
    else
        switch values{v}{1}
            case 'ANY'
                continue;

            otherwise
                error('Unknown value.');
        end
    end
end

