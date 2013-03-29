%%%%%%%%%%%%%%%%%%%%%%%%%%%
% File: createNeuroModStimLists.m
%
% Creates the stimuli for the experiment. Output is a series of stimulus
%   files: subject_run_#_stim_list.txt that contains the stimuli
%   and parameters for the trials in each run.
% 
% Controls:
%   * Equal number of each condition (1-4 words and extra one-word
%   condition)
%        - Also, equal number of AN, NA // AV, VA phrases
%   * All stimuli used equal amount
%       - +/- 1 if the number of phrases is not an equal multiple of the
%       number of stimuli.
%   * Each stimulus used in all applicable conditions (1-4 words, extra
%   one-word)
%       - N / V used in both 3rd and 4th positions
%   * Probes: Equal match / no-match
%       - Half of the no-match come from the shown categories, half don't
%   * All runs have the same number of trials in each condition
%       - Trials within a run are randomized such that pairwise
%       transitions are equalized
%   * ITIs are determined by the calling programs
%
% Total stimuli: num_reps * 20 (conditions)
%   - 20: 2 (Phrase, list) x 2 (N / V) x 5 (1-4 words, extra one word)
%
% Author: Doug Bemis
% Date: 27/11/12
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function NeuroMod_CreateStimLists

% Set the parameters first
NeuroMod_SetParameters;

% Make the phrases
[phrase_trials all_np_stims all_vp_stims con_strs p_pos] = makeAllPhrases();

% Make the lists matching
list_trials = makeAllLists(all_np_stims, all_vp_stims, con_strs, p_pos);

% Order the trials into runs
runs = createRuns({phrase_trials{:}, list_trials{:}});

% Now, order the trials in each run
for r = 1:length(runs)
    runs{r} = orderTrials(runs{r}, r);
end

% And then write them out
writeStimuli(runs);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Helper to write the stimuli
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function writeStimuli(runs)

% Experiment settings
global GL_subject;
global GL_use_initial_consonants;

% Write each run separately for modularity
for r = 1:length(runs)

    % Randomize order completely here
    i_ctr = 1;
    next_file = [GL_subject '_run_' num2str(r) '_stim_list.txt'];
    fid = NeuroMod_OpenUTF8File(next_file);
    for s = 1:length(runs{r})
        stim = runs{r}{s};

        % Mark the run and item number first
        run_num = r;
        item_num = i_ctr;
        i_ctr = i_ctr+1;
        
        % Add an initial consonant string, if needed
        stims = {};
        condition = stim{5};
        if GL_use_initial_consonants
            stims{1} = NeuroMod_GetInitialConsonantString;
        end
        for i = 1:4
            stims{i+1} = stim{i};
        end
        
        % Make the others readable
        probe = stim{10};
        a_pos = stim{6};
        n_v = stim{7};
        p_l = stim{8};
        answer = stim{9};
        ITI = stim{11};
        
        % Get the triggers
        [stim_trigger critical_trigger delay_trigger probe_trigger]...
            = NeuroMod_GetTrialTriggerValues(p_l, n_v, condition, answer);

        % And print
        NeuroMod_PrintTrial(fid, run_num, item_num, stims, ITI,...
            condition, a_pos, n_v, p_l, answer, probe, ...
            [stim_trigger critical_trigger delay_trigger probe_trigger]);
    end
    fclose(fid);
    
    % Show a test, so we don't have to guess
    NeuroMod_TestFileEncoding(next_file)
end


% Helper to add the probes
function [trials p_pos] = addProbes(trials, stims, p_pos)

% Set for all the conditions
global GL_conditions;
for c = GL_conditions
    [trials p_pos{c}] = addConditionProbes(trials,stims, c, p_pos{c});
end


% Adds matched probes for all trials in condition c
function [trials p_pos] = addConditionProbes(trials,stims, c, p_pos)

% Possible match positions
num_critical_stim = 5;
num_match = c;
if c == num_critical_stim
    num_match = 1;
end

% Set the counters / orders
num_conditions = 5;
ctrs.a_ctr = 1; ords.a_ord = randperm(2);      % match / nomatch (2)
ctrs.m_ctr = 1; ords.m_ord = num_critical_stim-randperm(num_match);      % match position (num_match)
ctrs.nm_ctr = 1; ords.nm_ord = randperm(2);     % nomatch_1 / nomatch_2 (2)
ctrs.nm_in_ctr = 1; ords.nm_in_ord = num_critical_stim-randperm(num_match);  % nomatch_1 position (num_match)
ctrs.nm_out_ctr = 1; ords.nm_out_ord = randperm(num_conditions*2-num_match); % nomatch_2 position (num_conditions*2-num_match)
ctrs.p_pos_ctr = 1; % To tell if we're reading or writing to p_pos

% Set for each trial
for n_v = 1:length(trials)
    for t = 1:length(trials{n_v})
        if trials{n_v}{t,5} == c
            [trials{n_v} ctrs ords p_pos] = ...
                setTrialProbe(t, trials{n_v}, stims, ctrs, ords, num_match, p_pos);
        end
    end
end



function [trials ctrs ords p_pos] = setTrialProbe(t, trials, stims, ctrs, ords, num_match, p_pos)

if ords.a_ord(ctrs.a_ctr) == 1
    [trials ctrs ords p_pos] = setMatchingTrialProbe(t, trials, ctrs, ords, num_match, p_pos);
else
    [trials ctrs ords] = setNonmatchingTrialProbe(t, trials, stims, ctrs, ords, num_match);
end

if mod(ctrs.a_ctr,length(ords.a_ord)) == 0
    ords.a_ord = randperm(2);
    ctrs.a_ctr = 0;
end
ctrs.a_ctr = ctrs.a_ctr+1;


function [trials ctrs ords] = setNonmatchingTrialProbe(t, trials, stims, ctrs, ords, num_match)

% Either from within or without category
if ords.nm_ord(ctrs.nm_ctr) == 1
    [nm_cat matched_word trials ctrs ords] = ...
        setNonmatchingInTrialProbe(t, trials, stims, ctrs, ords, num_match);
else
    [nm_cat matched_word trials ctrs ords] = ...
        setNonmatchingOutTrialProbe(t, trials, stims, ctrs, ords, num_match);
end

% Get a random different word from the non-match category
probe = matched_word;
while strcmp(matched_word,probe)
    probe = stims{nm_cat}{ceil(rand*length(stims{nm_cat}))};
end
trials{t,10} = probe;

if mod(ctrs.nm_ctr,length(ords.nm_ord)) == 0
    ords.nm_ord = randperm(2);
    ctrs.nm_ctr = 0;
end
ctrs.nm_ctr = ctrs.nm_ctr+1;


function [nm_cat matched_word trials ctrs ords] = ...
    setNonmatchingOutTrialProbe(t, trials, stims, ctrs, ords, num_match)

% Here, we first take out the in categories
nm_cats = 1:10;
for i = 5-num_match:4
    cat_ind = getCategoryStimInd(trials{t,i},stims);
    nm_cat_ind = find(nm_cats == cat_ind);
    nm_cats = [nm_cats(1:nm_cat_ind-1) nm_cats(nm_cat_ind+1:end)];
end
matched_word = '';
nm_cat = nm_cats(ords.nm_out_ord(ctrs.nm_out_ctr));
trials{t,9} = 'nomatch_2';

if mod(ctrs.nm_out_ctr,length(ords.nm_out_ord)) == 0
    num_conditions = 5;
    ords.nm_out_ord = randperm(num_conditions*2-num_match);
    ctrs.nm_out_ctr = 0;
end
ctrs.nm_out_ctr = ctrs.nm_out_ctr + 1;


function [nm_cat matched_word trials ctrs ords] = ...
    setNonmatchingInTrialProbe(t, trials, stims, ctrs, ords, num_match)

% Grab from the category of one of the words
% Have to do this every time because of the A pos
% uncertainty
matched_word = trials{t,ords.nm_in_ord(ctrs.nm_in_ctr)};
nm_cat = getCategoryStimInd(matched_word,stims);
trials{t,9} = 'nomatch_1';

if mod(ctrs.nm_in_ctr,length(ords.nm_in_ord)) == 0
    num_critical_stim = 5;
    ords.nm_in_ord = num_critical_stim-randperm(num_match);
    ctrs.nm_in_ctr = 0;
end
ctrs.nm_in_ctr = ctrs.nm_in_ctr + 1;



function [trials ctrs ords p_pos] = ...
    setMatchingTrialProbe(t, trials, ctrs, ords, num_match, p_pos)


% Might need to set, for the phrases
if ctrs.p_pos_ctr > length(p_pos)
    p_pos(ctrs.p_pos_ctr) = ords.m_ord(ctrs.m_ctr);
end


% Set the probe to be correct
trials{t,9} = 'match';
trials{t,10} = trials{t,p_pos(ctrs.p_pos_ctr)};

if mod(ctrs.m_ctr,length(ords.m_ord)) == 0
    num_critical_stim = 5;
    ords.m_ord = num_critical_stim-randperm(num_match);
    ctrs.m_ctr = 0;
end
ctrs.m_ctr = ctrs.m_ctr+1;
ctrs.p_pos_ctr = ctrs.p_pos_ctr+1;


% Helper to order trials in a run
function trials = orderTrials(orig_trials, r)

% Keep trying until the reorder works
limit = 100; tries = 0;
success = 0;
while ~success && tries <= limit
    
    % Use the helper to make the order
    order_file = ['Trial_order_' num2str(r) '.csv'];
    NeuroMod_CreateTrialOrder(order_file);

    % Then read it in and set
    trials = readTrialOrder(orig_trials, order_file);

    % Now, rearrange to avoid repeating words in successive trials
    [success trials] = rearrangeTrials(trials);
    tries = tries+1;
end

% Make sure we didn't reach the limit
if ~success
    error('Did not succeed.');
end


function [success trials] = rearrangeTrials(trials)

success = 1;
used = zeros(0,2);
[to_replace trials] = removeRepeats(trials);
while ~isempty(to_replace) && success    
    [success trials to_replace used] = tryToReplaceTrial(trials, to_replace, used);
end


function [success trials to_replace used] = tryToReplaceTrial(trials, to_replace, used)

% Get the trial index to replace
rep_ind = -1;
for t = 1:length(trials)
    if length(trials{t}) == 3
        rep_ind = t;
        break;
    end    
end

% First, try to fill from the replace trials
for t = 1:length(to_replace)
    if canReplace(rep_ind, trials, to_replace{t})
        disp(['Replaced ' num2str(rep_ind) ' with ' num2str(t) ' from replace.']);
        [trials to_replace] = replaceTrial(rep_ind, trials, t, to_replace);
        success = 1;
        last = [-1 -1];
        return;
    end
end


% Then, try shuffling the trials
for t = 1:length(trials)
    if canReplace(rep_ind, trials, trials{t})
        
        % Don't loop
        good = 1;
        for u = 1:size(used,1)
            if rep_ind == used(u,1) && t == used(u,2)
                good = 0;
                break;
            end
        end
        
        if good
            disp(['Replaced ' num2str(rep_ind) ' with ' num2str(t) ' from trials.']);
            trials = replaceTrial(rep_ind, trials, t, trials);
            trials{t} = getTrialMarkers(trials{t});
            success = 1;
            used(end+1,:) = [rep_ind t];
            return;
        end
    end
end
success = 0;

function [trials to_replace] = replaceTrial(rep_ind, trials, t, to_replace)

% Check
if ~checkTrialMarkers(trials{rep_ind},getTrialMarkers(to_replace{t}))
    error('Wrong markers.');
end

% Transfer the ITI
to_replace{t}{11} = trials{rep_ind}{3};

% Replace the trial
trials{rep_ind} = to_replace{t};

% And remove the trial
to_replace = {to_replace{1:t-1},to_replace{t+1:end}};



function can = canReplace(rep_ind, trials, rep_trial)

can = 0;

% Can't if it's a marker
if length(rep_trial) == 3
    return;
end

% See if it's the right type
if ~checkTrialMarkers(trials{rep_ind}, getTrialMarkers(rep_trial))
    return;
end

% Check before...
if rep_ind > 1 && hasRepeat(trials{rep_ind-1}, rep_trial)
    return;
end

% ...and after
if rep_ind < length(trials) && hasRepeat(trials{rep_ind+1}, rep_trial)
    return;
end
can = 1;

function [repeats trials] = removeRepeats(trials)

% Go through and look for repeated words
repeats = {};
for t = 2:length(trials)
    if length(trials{t-1}) > 3 && hasRepeat(trials{t},trials{t-1})
        repeats{end+1} = trials{t};
        trials{t} = getTrialMarkers(repeats{end});
    end
end


function equal = checkTrialMarkers(m_1, m_2)

equal = 1;

% Condition
if m_1{1} ~= m_2{1}
    equal = 0;
    return;
end

% type
if ~strcmp(m_1{2}, m_2{2})
    equal = 0;
    return;
end

% ITIs do not have to match, we'll replace them
% if m_1{3} ~= m_2{3}
%     equal = 0;
%     return;
% end


% Want to keep the condition, type, and ITI
function markers = getTrialMarkers(trial)
markers = {trial{5},trial{8},trial{11}};


function has = hasRepeat(trial_1, trial_2)
    
% Not repeated if markers
has = 0;
if length(trial_1) == 3 || length(trial_2) == 3
    return; 
end

% NOTE: The initial consonants aren't in yet.
num_critical_stim = 5;
for i = 1:num_critical_stim-1
    
    % Check the stims
    for j = 1:num_critical_stim-1
        if strcmp(trial_1{i},trial_2{j})
            has = 1;
            return;
        end
    end
    
    % Check the probes
    if strcmp(trial_1{10},trial_2{i})
        has = 1;
        return;
    end
    if strcmp(trial_2{10},trial_1{i})
        has = 1;
        return;
    end
end

% And one last check
if strcmp(trial_1{10},trial_2{10})
    has = 1;
end


function trials = readTrialOrder(orig_trials, order_file)

% The settings
global GL_ITI_mean;
global GL_ITI_std;
global GL_use_random_ITI;
global GL_order_SOA;

% Open up the run
trials = {};
fid = fopen(order_file);
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break; 
    end
    [onset cond len] = strread(line,'%d%d%d','delimiter',','); %#ok<*NASGU,*REMFF1,ASGLU>

    % Parse condition
    if cond <= 5
        type = 'phrase';
    elseif cond <= 10
        cond = cond-5;
        type = 'list';

    % Add a blank trial as a longer SOA for fMRI experiments
    else
        if isempty(trials) 
            error(['First trial in run ' num2str(r) ' a blank.']);
        end
        trials{end}{end} = trials{end}{end}+GL_order_SOA;
        continue;
    end
    
    % Set the length
    if GL_use_random_ITI
        len = randn*GL_ITI_std + GL_ITI_mean;

    % Otherwise, we need a full trial length
    else
        len = GL_order_SOA;
    end    

    % And get the trial
    for t = 1:length(orig_trials)
        if ~isempty(orig_trials{t}) && orig_trials{t}{5} == cond &&...
                strcmp(orig_trials{t}{8},type)
            trials{end+1} = {orig_trials{t}{:}, len};
            orig_trials{t} = {};
            break;
        end
    end
end
fclose(fid);


% Helper to create the runs
function runs = createRuns(trials)

% Experiment settings
global GL_run_length;
global GL_num_reps;
global GL_conditions;

% Want each run to have run_length repetitions of each trial type
runs = {};
for b = 1:floor(GL_num_reps / GL_run_length)

    % So grab the right amount randomly for each run
    runs{end+1} = {};
    
    % Grab an equal amount of each type
    for t = 1:length(trials)

        % And each condition
        for c = GL_conditions
            added = 0;
            c_ctr = 1;
            c_ord = randperm(length(trials{t}));
            while added < GL_run_length
                if ~isempty(trials{t}{c_ord(c_ctr)}) && ...
                        trials{t}{c_ord(c_ctr),5} == c 
                    
                    % And add
                    runs{end}{end+1} = {trials{t}{c_ord(c_ctr),:}}; %#ok<*CCAT1>
                    trials{t}{c_ord(c_ctr)} = [];
                    added = added+1;
                end
                c_ctr = c_ctr+1;
            end
        end
    end
end

% Add the rest in the last run
if mod(GL_num_reps, GL_run_length) ~= 0
    runs{end+1} = {};
    for t = 1:length(trials)
        for i = 1:length(trials{t})
            if ~isempty(trials{t}{i})
                    
                % And add
                runs{end}{end+1} = {trials{t}{i,:}};
                trials{t}{i} = [];
            end
        end
    end
end


% Helper to find the category stimuli the given word is from
function stim_cat = getCategoryStimInd(word,stims)

for s = 1:length(stims)
    for w = 1:length(stims{s})
        if strcmp(stims{s}{w},word)
            stim_cat = s;
            return;
        end
    end
end
error('Should have found it.');


function list_trials = makeAllLists(all_np_stims, all_vp_stims, con_strs, p_pos)

% Need to divide these up beforehand to make sure we use them all
[list_stim_1a list_stim_2b] = splitListCategories(all_np_stims);
[list_stim_2a list_stim_1b] = splitListCategories(all_vp_stims);

list_trials{1} = makeLists('noun','list', list_stim_1a, list_stim_1b, con_strs);
list_trials{2} = makeLists('verb','list', list_stim_2a, list_stim_2b, con_strs);

for p = 1:length(p_pos)
    p_pos{p} = p_pos{p}(randperm(length(p_pos{p})));
end
list_trials = addProbes(list_trials, {all_np_stims{:} all_vp_stims{:}}, p_pos); %#ok<*CCAT>


function [list_stim_1 list_stim_2] = splitListCategories(all_stims)

% Just the first two 
list_stim_1 = {{},{},all_stims{3:5}};
list_stim_2 = {{},{},all_stims{3:5}};
for i = 1:2
    r_ord = randperm(length(all_stims{i}));
    for s = 1:length(r_ord)
        if s > floor(length(r_ord)/2)
            list_stim_1{i}{end+1} = all_stims{i}{r_ord(s)};
        else
            list_stim_2{i}{end+1} = all_stims{i}{r_ord(s)};        
        end
    end
end


% Helper to make full phrases
function [trials con_strs] = makeLists(category, structure,...
    phrase_stim_1, phrase_stim_2, con_strs)

% Experiment settings
global GL_num_reps;
global GL_a_positions;

% Get the templates first
trials = getTemplates(category,structure);

% Set up the options
stims = {{phrase_stim_2{1},GL_num_reps/2,[1,1]},...
        {phrase_stim_1{2},GL_num_reps/2,[2,1]},...
        {phrase_stim_2{4},GL_num_reps/length(GL_a_positions),[3,1]},...
        {phrase_stim_1{3},GL_num_reps/length(GL_a_positions),[4,1; 3,2]},...
        {phrase_stim_1{1},GL_num_reps/2,[1,2]},...
        {phrase_stim_2{2},GL_num_reps/2,[2,2]},...
        {phrase_stim_2{5},GL_num_reps/length(GL_a_positions),[4,2]}};
    
% And make the trials
[trials con_strs all_stim used_all] = makeTrials(stims, con_strs, trials); %#ok<ASGLU>
if sum(used_all) ~= length(used_all)
    error('Did not use all phrase stimuli in the lists.');
end


function [phrase_trials all_np_stims all_vp_stims con_strs p_pos] = makeAllPhrases()

con_strs = {};
[phrase_trials{1} con_strs all_np_stims] = makePhrases('noun','phrase', ...
    {'prepositions', 'determiners', 'nouns', 'adj_pre', 'adj_post'},con_strs);
[phrase_trials{2} con_strs all_vp_stims] = makePhrases('verb','phrase', ...
    {'firstnames', 'modals', 'verbs', 'adv_pre', 'adv_post'},con_strs);

p_pos = {};
num_conditions = 5;
for c = 1:num_conditions
    p_pos{c} = [];
end
[phrase_trials p_pos] = addProbes(phrase_trials, {all_np_stims{:} all_vp_stims{:}}, p_pos); %#ok<*CCAT>


% Helper to make full phrases
function [trials con_strs all_stims] = makePhrases(category, structure,...
    stimuli_names, con_strs)

% Experiment settings
global GL_subject;
global GL_num_reps;
global GL_a_positions;

% Get the templates first
trials = getTemplates(category, structure);

% Load
stimuli = {};
for s = 1:length(stimuli_names)
    if strcmp(GL_subject, 'English')
        stimuli{s} = NeuroMod_ReadStimFile(['English_' stimuli_names{s}]); %#ok<*AGROW>
    else
        stimuli{s} = NeuroMod_ReadStimFile(stimuli_names{s}); %#ok<*AGROW>        
    end
end

% Set up the options
stims = {{stimuli{1},GL_num_reps,[1,0]},...
        {stimuli{2},GL_num_reps,[2,0]},...
        {stimuli{3},GL_num_reps/length(GL_a_positions),[4,1; 3,2]},...
        {stimuli{4},GL_num_reps/length(GL_a_positions),[3,1]},...
        {stimuli{5},GL_num_reps/length(GL_a_positions),[4,2]}};
    
    
% And make the trials
[trials con_strs all_stims used_all] = makeTrials(stims, con_strs, trials);

% Let us know at least
if sum(used_all) ~= length(used_all)
    disp('WARNING: Did not use all stimuli.');
end



% General stimuli builder
function [trials con_strs all_stims used_all] = makeTrials(stims, con_strs, trials)

% And add to the trials
used_all = [];
all_stims = {};
for s = 1:length(stims)
    [trials all_stims{end+1} used_all(end+1)] = addAllStimToTrials(stims{s}{1}, trials, ...
        stims{s}{2}, stims{s}{3});
end

% Complete the trials
for t = 1:length(trials)
    
    % Fifth condition is special
    if trials{t,5} == 5
        
        % Flip the last two
        tmp = trials{t,4};
        trials{t,4} = trials{t,3};
        trials{t,3} = tmp;
        
        % And add all consonant strings
        for s = 1:3
            [trials{t,s} con_strs] = NeuroMod_GetConsonantString(trials{t,s}, con_strs); 
        end
    else
       
        % Otherwise more straightforward
        for s = 4-trials{t,5}:-1:1
            [trials{t,s} con_strs] = NeuroMod_GetConsonantString(trials{t,s}, con_strs); 
        end        
    end    
end



% Helper to add all the stimuli of a category to the trials
function [trials all_stims used_all] = addAllStimToTrials(stims, trials, ...
    total_num, placements)

% Make a note if we're not going to use them all. 
%   * For the nouns / verbs in the fMRI experiment, we don't...
used_all = total_num >= length(stims);

% Get all of the nouns to use
s_ctr = 1;
all_stims = cell(total_num,1);
for r = 1:total_num
    if mod(s_ctr,length(stims)) == 1
        s_ord = randperm(length(stims));
        s_ctr = 1;
    end
    all_stims{r} = stims{s_ord(s_ctr)};
    s_ctr = s_ctr+1;
end

% Put them in the stimuli
for p = 1:size(placements,1)
    trials = addStimToTrials(all_stims,trials,...
        placements(p,1),placements(p,2));
end


% Helper to add words to trials
function trials = addStimToTrials(stims,trials,position,a_pos)

% Add evenly, and randomly to each condition
global GL_conditions;
for c = GL_conditions
    s_ctr = 1;
    s_ord = randperm(length(stims));
    for t = 1:length(trials)
        
        % Check the position (5) and the a_pos (6)
        %   0 - signifies doesn't matter
        if trials{t,5} == c && (trials{t,6} == a_pos || a_pos == 0)
            trials{t,position} = stims{s_ord(s_ctr)};
            s_ctr = s_ctr+1;
        end
    end
end

% Make sure
if s_ctr ~= length(stims)+1
    error('Not all stimuli used.');
end


% Helper to fill in the condition, etc. for the trial structs
% category - noun / verb phrase
% structure - phrase / list
function templates = getTemplates(category, structure) 

% Need the experiment settings
global GL_conditions;
global GL_num_reps;
global GL_a_positions;

% First, setup the templates for the number of phrases
% Each template will have:
%   * Four stimuli.
%   * Condition: 1-4 words / extra 1 word
%   * A position (1 - A first)
%   * N / V phrase (1 - N)
%   * Comp / List (1 - Comp)
%   * Answer
%   * Probe
num_cond = length(GL_conditions);
templates = cell(GL_num_reps*num_cond,10);

% Now, set all the nouns first
% NOTE: We want to use each noun in both the 3rd and 4th position, so we
% need an even number of phrases, unless there's a really good reason not
% to (e.g. only one adj/adv position).
num_a_pos = length(GL_a_positions);
if mod(GL_num_reps,num_a_pos) == 1
    error('Use an even number of phrases, please.');
end

% Set the outputs
templates(:,7) = {category}; 
templates(:,8) = {structure};

% Set the conditions
for c = 1:num_cond
    templates(c:num_cond:end,5) = {GL_conditions(c)}; 
end

% Set the adj/adv position
for i = 1:num_a_pos:GL_num_reps
    templates((i-1)*num_cond+1:i*num_cond,6) = {GL_a_positions(1)};
    
    % Add the second condition, if wanted
    if num_a_pos == 2
        templates(i*num_cond+1:(i+1)*num_cond,6) = {GL_a_positions(2)};
    end
end


