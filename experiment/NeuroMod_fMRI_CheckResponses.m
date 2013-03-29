% Helper to check the log and data file of a run
%
% To check:
%   * Behavioral Results
%       - Sanity
%           - High accuracy overall
%           - Localizer responses
%           - Low timeouts
%       - Effects
%           - By answer type [Match / syntactic cat / pos. in list]
%           - By condition [Phrase / Length]
%   * Trial balancing
%   * Timing
%
% Expects cleaned subject_log.txt and subject_data.txt files
%   (i.e. no bad runs / previous subject runs left in)

function responses = NeuroMod_fMRI_CheckResponses(subject)


% Read in the responses from the data_ file
responses = parseDataFile(subject);

% Check the non-experimental responses
responses = checkPracticeResponses(responses);
responses = checkLocalizerResponses(responses);
responses = markOutliers(responses);

% Check validity
return;
checkStimuli(responses);

% Check trial balancing

function checkStimuli(responses)

prep = NeuroMod_ReadStimFile('prepositions');
det = NeuroMod_ReadStimFile('determiners');
adj_pre = NeuroMod_ReadStimFile('adj_pre');
nouns = NeuroMod_ReadStimFile('nouns');
adj_post = NeuroMod_ReadStimFile('adj_post');
names = NeuroMod_ReadStimFile('firstnames');
modals = NeuroMod_ReadStimFile('modals');
adv_pre = NeuroMod_ReadStimFile('adv_pre');
verbs = NeuroMod_ReadStimFile('verbs');
adv_post = NeuroMod_ReadStimFile('adv_post');

for r = 1:length(responses)
    checkStimulus(responses(r),prep,det,adj_pre,nouns,adj_post,...
        names,modals,adv_pre,verbs,adv_post);
end
disp('All stimuli as expected.');


function checkStimulus(resp,prep,det,adj_pre,nouns,adj_post,...
    names,modals,adv_pre,verbs,adv_post)

exp = setExpectations(resp.n_v, resp.p_l, resp.a_p,...
    resp.cond, prep,det,adj_pre,nouns,adj_post,...
    names,modals,adv_pre,verbs,adv_post);

probe_exp = setProbeExpectations(resp.stim,resp.cond,resp.ans,...
    resp.n_v, resp.p_l, resp.a_p, prep,det,adj_pre,nouns,adj_post,...
    names,modals,adv_pre,verbs,adv_post);

for i = 1:length(exp)
    if isempty(exp{i})
        if ~isConsonant(resp.stim{i},...
            prep,det,adj_pre,nouns,adj_post,...
            names,modals,adv_pre,verbs,adv_post)
            error('Bad stim');
        end
    else
        if ~checkArray(resp.stim{i},exp{i})
            error('Bad stim');
        end
    end
end

if ~checkArray(resp.probe,probe_exp)
    error('Bad stim');
end


function val = isConsonant(item,varargin)

val = 1;
for a = 1:length(varargin)
    if checkArray(item,varargin{a})
        val = 0;
        return;
    end
end

function found = checkArray(item, array)

found = 0;
for a = 1:length(array)
    if strcmp(item,array{a})
        found = 1;
        return;
    end
end


function probe_exp = setProbeExpectations(stims,cond,answer,...
    n_v, p_l, a_p, prep,det,adj_pre,nouns,adj_post,...
    names,modals,adv_pre,verbs,adv_post)

switch answer
    case 'match'
        probe_exp = setMatchProbeExpectations(stims, cond);

    case 'nomatch_1'
        probe_exp = setNomatchProbeExpectations_1(stims,...
            n_v, p_l, a_p, cond, prep,det,adj_pre,nouns,adj_post,...
            names,modals,adv_pre,verbs,adv_post);
        
    case 'nomatch_2'
        probe_exp = setNomatchProbeExpectations_2(...
            n_v, p_l, a_p, cond, prep,det,adj_pre,nouns,adj_post,...
            names,modals,adv_pre,verbs,adv_post);
end

function probe_exp = setNomatchProbeExpectations_2(...
    n_v, p_l, a_p, cond, prep,det,adj_pre,nouns,adj_post,...
    names,modals,adv_pre,verbs,adv_post)

exp = setExpectations(n_v, p_l, a_p,cond, prep,det,adj_pre,...
    nouns,adj_post,names,modals,adv_pre,verbs,adv_post);

probe_exp = {};
probe_exp = addNotUsed(probe_exp,prep,exp);
probe_exp = addNotUsed(probe_exp,det,exp);
probe_exp = addNotUsed(probe_exp,adj_pre,exp);
probe_exp = addNotUsed(probe_exp,nouns,exp);
probe_exp = addNotUsed(probe_exp,adj_post,exp);
probe_exp = addNotUsed(probe_exp,names,exp);
probe_exp = addNotUsed(probe_exp,modals,exp);
probe_exp = addNotUsed(probe_exp,adv_pre,exp);
probe_exp = addNotUsed(probe_exp,verbs,exp);
probe_exp = addNotUsed(probe_exp,adv_post,exp);


function probe_exp = addNotUsed(probe_exp,possible,exp)

for p = 1:length(possible)
    used = 0;
    for e = 1:length(exp)
        for w = 1:length(exp{e})
            if strcmp(possible{p},exp{e}{w})
                used = 1;
                break;
            end
        end
        if used
            break;
        end            
    end
    if ~used
        probe_exp{end+1} = possible{p};
    end
end
        
function probe_exp = setNomatchProbeExpectations_1(stims,...
    n_v, p_l, a_p, cond, prep,det,adj_pre,nouns,adj_post,...
    names,modals,adv_pre,verbs,adv_post)

exp = setExpectations(n_v, p_l, a_p,cond, prep,det,adj_pre,...
    nouns,adj_post,names,modals,adv_pre,verbs,adv_post);

probe_exp = {};
for e = 1:length(exp) 
    for w = 1:length(exp{e})
        used = 0;
        for s = 1:length(stims)
            if strcmp(stims{s},exp{e}{w})
                used = 1;
                break;
            end
        end
        if ~used
            probe_exp{end+1} = exp{e}{w};
        end
    end
end


function probe_exp = setMatchProbeExpectations(stims, cond)

if cond < 5
    probe_exp = {stims{6-cond:5}};
else
    probe_exp = {stims{5}};
end


function exp = setExpectations(n_v, p_l, a_p,...
    cond, prep,det,adj_pre,nouns,adj_post,...
    names,modals,adv_pre,verbs,adv_post)

if strcmp(n_v,'noun') && strcmp(p_l,'phrase')
    if a_p == 1
        exp = {[],prep,det,adj_pre,nouns};
    else
        exp = {[],prep,det,nouns,adj_post};        
    end
elseif strcmp(n_v,'noun') && strcmp(p_l,'list')
    if a_p == 1
        exp = {[],names,det,adv_pre,nouns};
    else
        exp = {[],prep,modals,nouns,adv_post};        
    end
elseif strcmp(n_v,'verb') && strcmp(p_l,'phrase')
    if a_p == 1
        exp = {[],names,modals,adv_pre,verbs};
    else
        exp = {[],names,modals,verbs,adv_post};
    end
else
    if a_p == 1
        exp = {[],prep,modals,adj_pre,verbs};
    else
        exp = {[],names,det,verbs,adj_post};        
    end    
end

exp = removeConsonantPlaces(exp, cond);

function exp = removeConsonantPlaces(exp, cond)

switch cond
    case 1
        exp{2} = []; exp{3} = []; exp{4} = [];
        
    case 2
        exp{2} = []; exp{3} = []; 
        
    case 3
        exp{2} = []; 
        
    case 4
        
    case 5
        exp{5} = exp{4};
        exp{2} = []; exp{3} = []; exp{4} = [];
end



function responses = markOutliers(responses)

[all_acc all_rt ] = NeuroMod_AverageResponses('', responses, []);

% Remove rts 
ctr = 1;
while ctr <= length(responses)
    if responses(ctr).rt < mean(all_rt)-2*std(all_rt) || ...
            responses(ctr).rt > mean(all_rt)+2*std(all_rt)
        responses(ctr).outlier = 1;
        %         responses = responses([1:ctr-1,ctr+1:end]);
        %         ctr = ctr-1;
    else
        responses(ctr).outlier = 0;
    end
    ctr = ctr+1;
end

function responses = checkPracticeResponses(responses)

ctr = 1;
while ctr <= length(responses)
    if responses(ctr).blk == 0
        responses = responses([1:ctr-1,ctr+1:end]);
        ctr = ctr-1;
    end
    ctr = ctr+1;
end


function responses = checkLocalizerResponses(responses)

num_loc_resp = 0;
ctr = 1;
while ctr <= length(responses)
    if strcmp(responses(ctr).n_v,'pseudo') || strcmp(responses(ctr).n_v,'sentence')
        responses = responses([1:ctr-1,ctr+1:end]);
        num_loc_resp = num_loc_resp+1;
        ctr = ctr-1;
    end
    ctr = ctr+1;
end
if num_loc_resp == 2
    disp('Found both localizer responses.');
else
%     error('Wrong number of localizer responses.');
end


function responses = parseDataFile(subject)

responses = [];
fid = fopen([subject '_data.txt']);
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    responses = parseDataLine(line, responses);
end
fclose(fid);


function responses = parseDataLine(line, responses)

% Might be empty
if isempty(line)
    return;
end
[rsp.label rest] = strtok(line);
if ~(strcmp(rsp.label,'KEY') || strcmp(rsp.label,'TIMEOUT'))
    return;
end

% Get the tags
[rsp.rsp_key rest] = strtok(rest);
[rsp.rt rest] = strtok(rest); rsp.rt = str2double(rsp.rt);
[abs_rt rest] = strtok(rest);
[rsp.type rest] = strtok(rest);
[rsp.stim rest] = strtok(rest);

% Only want experimental responses
if ~strcmp(rsp.type,'Text') || strcmp(rsp.stim,'+')
    return;
end

[rsp.blk rest] = strtok(rest); rsp.blk = str2num(rsp.blk);
[rsp.num rest] = strtok(rest); rsp.num = str2num(rsp.num);
[rsp.n_v rest] = strtok(rest); 
[rsp.p_l rest] = strtok(rest); 
[rsp.cond rest] = strtok(rest); rsp.cond = str2num(rsp.cond);
[rsp.a_p rest] = strtok(rest); rsp.a_p = str2num(rsp.a_p);
[rsp.ans rest] = strtok(rest); 

rsp.stim = {};
for i = 1:5
    [rsp.stim{i} rest] = strtok(rest);
end
rsp.probe = strtok(rest);

% And calculate the answer
if strcmp(rsp.ans,'match')
    if strcmp(rsp.rsp_key,'y')
        rsp.acc = 1;
    else
        rsp.acc = 0;
    end
else
    if strcmp(rsp.rsp_key,'p')
        rsp.acc = 1;
    else
        rsp.acc = 0;
    end
end

if isempty(responses)
    responses = rsp;
else
    responses(end+1) = rsp;
end

