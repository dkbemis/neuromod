% Make the practice list for the MEG experiment
function NeuroMod_CreatePracticeList

% Set the parameters first
NeuroMod_SetParameters;

global GL_num_practice_trials;
global GL_subject;

% Load the words
words{1} = loadWords({'prepositions','determiners','adj_pre','nouns','adj_post'});
words{2} = loadWords({'firstnames','modals','adv_pre','verbs','adv_post'});

% Want to make sure we use all words first
trials = orderTrials(words);

% Use them evenly, so set the initial orders
orders = {};
for i = 1:2
    for w = 1:length(words{i})
        orders{i,w} = randperm(length(words{i}{w}));
    end
end

% Now write them out
ctr = 1;
practice_file = [GL_subject '_practice_stim_list.txt'];
fid = NeuroMod_OpenUTF8File(practice_file);
for t = randperm(GL_num_practice_trials)
    orders = printTrial(fid,ctr,trials{t},words,orders);
    ctr = ctr+1;
end
fclose(fid);
NeuroMod_TestFileEncoding(practice_file)


% Helper to write
function orders = printTrial(fid,ind, trial,words,orders)

global GL_use_initial_consonants;
global GL_ITI_std;
global GL_ITI_mean;

% Set all the parameters
run_num = 0;
item_num = ind;

stims = {};
if GL_use_initial_consonants
    stims{1} = NeuroMod_GetInitialConsonantString;
end

% Each word
matches = {};
for i = 2:5
    if ~isempty(trial{i})
        [stims{end+1} orders] = getWord(trial{i}(1),trial{i}(2),words,orders);
        matches{end+1} = stims{end};
    else
        % Grab a random consonant string
        stims{end+1} = NeuroMod_GetConsonantString(words{1}{i-1},{});
    end
end

% The ITI
ITI = randn*GL_ITI_std + GL_ITI_mean;

% Condition, etc.
condition = trial{6};
a_pos = trial{7};
n_v = trial{8};
p_l = trial{9};

% Set a random probe
if rand < 0.5
    answer = 'match';
    probe = matches{ceil(rand*length(matches))};
else    
    answer = 'nomatch';
    probe = matches{1};
    while 1
        good = 1;
        for m = 1:length(matches)
            if strcmp(matches{m},probe)
                good = 0;
                break;
            end
        end
        if good
            break;
        end
        type = ceil(rand*length(words));
        w = ceil(rand*length(words{type}));
        ind = ceil(rand*length(words{type}{w}));
        probe = words{type}{w}{ind};
    end
end

% And the 'triggers'
triggers = [0 0 0 0];
NeuroMod_PrintTrial(fid, run_num, item_num, stims, ITI, ...
    condition, a_pos,n_v, p_l, answer, probe, triggers);



% Helper to set a word
function [word orders] = getWord(type,ind,words,orders)

% Might need to reorder
if isempty(orders{type,ind})
    orders{type,ind} = randperm(length(words{type}{ind}));
end

% Get the next
word = words{type}{ind}{orders{type,ind}(1)};
orders{type,ind} = orders{type,ind}(2:end);


function trials = orderTrials(words)

global GL_num_practice_trials;

% Need to figure out how many reps first
num_reps = getRepNum(words);

% Get the trials
trials = {};
for r = 1:num_reps
    trials = addTrialSet(r, trials);
end

% Set the counters
ctrs = zeros(2,length(words));
for i = 1:2
    for w = 1:length(words{i})
        ctrs(i,w) = length(words{i}{w});
    end
end

% Move the necessary trials all up front
to_use = {};
for w = 1:length(words{i})
    for i = 1:2

        % Move until we have enough spaces
        to_find = ctrs(i,w);    % This is adjusted in the loop...
        for c = 1:to_find
            [trials to_use ctrs] = findUseableTrial([i,w],trials,to_use,ctrs,num_reps);
        end
        
        % Make sure we found enough
        if ctrs(i,w) > 0
            error('Should have found enough to use.');
        end
    end
end

% Add up front and return
trials = {to_use{:}, trials{1:GL_num_practice_trials-length(to_use)}}; %#ok<*CCAT>



% Helper - finds a trial to use
function [trials to_use ctrs] = findUseableTrial(w_ind,trials,to_use,ctrs,num_reps)

% Search by reps to avoid duplication of trials
for r = 1:num_reps
    for t = randperm(length(trials))  % 40 trials per rep...

        % Stay in the run
        if trials{t}{1} ~= r
            continue;
        end
        
        % Check the trial
        for i = 2:5
            if ~isempty(trials{t}{i}) && trials{t}{i}(1) == w_ind(1) && ...
                trials{t}{i}(2) == w_ind(2)
                
                % Update the counters
                for j = 2:5
                    if ~isempty(trials{t}{j})
                        ctrs(trials{t}{j}(1),trials{t}{j}(2)) = ...
                            ctrs(trials{t}{j}(1),trials{t}{j}(2))-1;
                    end
                end
            
                % And move
                to_use{end+1} = trials{t};
                trials = {trials{1:t-1}, trials{t+1:end}};
                return;
            end
        end
    end
end
error('Should have found one.');


% Add a set of trials to be filled
function trials = addTrialSet(run_num, trials)

% Not so elegant...
types = [1 2 1];
labels = {'noun','verb'};
for i = 1:2
    trials{end+1} = {run_num, [types(i),1], [types(i),2], [types(i),3], [types(i),4],4,1,labels{i},'phrase'};
    trials{end+1} = {run_num, [], [types(i),2], [types(i),3], [types(i),4],3,1,labels{i},'phrase'};
    trials{end+1} = {run_num, [], [], [types(i),3], [types(i),4],2,1,labels{i},'phrase'};
    trials{end+1} = {run_num, [], [], [], [types(i),4],1,1,labels{i},'phrase'};
    trials{end+1} = {run_num, [], [], [], [types(i),3],5,1,labels{i},'phrase'};

    trials{end+1} = {run_num, [types(i),1], [types(i),2], [types(i),4], [types(i),5],4,2,labels{i},'phrase'};
    trials{end+1} = {run_num, [], [types(i),2], [types(i),4], [types(i),5],3,2,labels{i},'phrase'};
    trials{end+1} = {run_num, [], [], [types(i),4], [types(i),5],2,2,labels{i},'phrase'};
    trials{end+1} = {run_num, [], [], [], [types(i),5],1,2,labels{i},'phrase'};
    trials{end+1} = {run_num, [], [], [], [types(i),4],5,2,labels{i},'phrase'};
    
    trials{end+1} = {run_num, [types(i+1),1], [types(i),2], [types(i+1),3], [types(i),4],4,1,labels{i},'list'};
    trials{end+1} = {run_num, [], [types(i),2], [types(i+1),3], [types(i),4],3,1,labels{i},'list'};
    trials{end+1} = {run_num, [], [], [types(i+1),3], [types(i),4],2,1,labels{i},'list'};
    trials{end+1} = {run_num, [], [], [], [types(i),4],1,1,labels{i},'list'};
    trials{end+1} = {run_num, [], [], [], [types(i+1),3],5,1,labels{i},'list'};
    
    trials{end+1} = {run_num, [types(i),1], [types(i+1),2], [types(i),4], [types(i+1),5],4,2,labels{i},'list'};
    trials{end+1} = {run_num, [], [types(i+1),2], [types(i),4], [types(i+1),5],3,2,labels{i},'list'};
    trials{end+1} = {run_num, [], [], [types(i),4], [types(i+1),5],2,2,labels{i},'list'};
    trials{end+1} = {run_num, [], [], [], [types(i+1),5],1,2,labels{i},'list'};
    trials{end+1} = {run_num, [], [], [], [types(i),4],5,2,labels{i},'list'};
end


function num_reps = getRepNum(words)

% Need at least one appearance of each word
% NOTE: Assuming same number of trials in nouns and verbs
num_reps = ceil(length(words{1}{1}) / 4);   % Four places per set...
num_reps = max(num_reps, ceil(length(words{1}{2}) / 6));   % Four places per set...
num_reps = max(num_reps, ceil(length(words{1}{3}) / 8));   % Eight places per set...
num_reps = max(num_reps, ceil(length(words{1}{4}) / 16));   % 16 places per set...
num_reps = max(num_reps, ceil(length(words{1}{5}) / 8));   % 16 places per set...

% Make sure we have enough trials
% Each set has 5 (conditions) x 2 (A-N / N-A) x 2 (phrase / list) x 2 (noun / verb)
global GL_num_practice_trials;
num_reps = max(num_reps, ceil(GL_num_practice_trials/40));



% Helper to load
function words = loadWords(types)

global GL_subject;
for t = 1:length(types)
    if strcmp(GL_subject, 'English')
        words{t} = NeuroMod_ReadStimFile(['English_' types{t}]); %#ok<*AGROW>
    else
        words{t} = NeuroMod_ReadStimFile(types{t}); %#ok<*AGROW>        
    end
end

