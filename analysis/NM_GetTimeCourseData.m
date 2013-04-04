
function data = NM_GetTimeCourseData(cfg)

% Make sure we're loaded
NM_LoadSubjectData();

% Send to right function
switch cfg.data_type
    case 'meg_rms'
        data = getMegRMSData(cfg);
        
    case 'et'
        data = getETData(cfg);
        
    otherwise
        error('Unimplemented.');
end

% Pre-group as well, so we can average / test easier
data = grougData(data);

% Set to return and clear
global GL_tc_data;
data = 


function data = grougData(data)

for c = unique(data.conditions)
    data.condition_data = getConditionData(c);
end

function condition_data = getConditionData(c)




function data = getETData(cfg)

% Should be preprocessed
global GLA_subject_data;
global GLA_trial_type; GLA_trial_type = cfg.trial_type; 
if ~isfield(GLA_subject_data.parameters,['et_' GLA_trial_type '_data_preprocessed']) ||...
        GLA_subject_data.parameters.(['et_' GLA_trial_type '_data_preprocessed']) ~= 1
    while 1
        ch = input(['et_' GLA_trial_type ' not processed yet. Process now? (y/n) '],'s');
        if strcmp(ch,'n')
            error('Cannot proceed');
        elseif strcmp(ch,'y')
            NM_PreprocessETData(); 
            break;
        end
    end    
end
        

% Load the cleaned data
NM_ApplyETRejections();

% Get each trial
global GLA_clean_et_data;
for t = 1:length(GLA_clean_et_data.data.cond)
    data.trials{t} = GLA_clean_et_data.data.(cfg.measure){t};
    data.conditions(t) = GLA_clean_et_data.data.cond(t); 
end

% Only one timecourse
data.time = GLA_clean_et_data.data.epoch(1):GLA_clean_et_data.data.epoch(2)-1;

% And clear the data
clear global GLA_clean_et_data;


function data = getMegRMSData(cfg)

% Should be preprocessed
global GLA_rec_type; GLA_rec_type = 'meeg';
global GLA_subject_data;
global GLA_meeg_type; GLA_meeg_type = 'meg'; 
global GLA_meeg_trial_type; GLA_meeg_trial_type = cfg.trial_type; 
if ~isfield(GLA_subject_data.parameters,[GLA_meeg_type '_' GLA_meeg_trial_type '_data_preprocessed']) ||...
        GLA_subject_data.parameters.([GLA_meeg_type '_' GLA_meeg_trial_type '_data_preprocessed']) ~= 1
    while 1
        ch = input([GLA_meeg_type ' ' GLA_meeg_trial_type ' not processed yet. Process now? (y/n) '],'s');
        if strcmp(ch,'n')
            error('Cannot proceed');
        elseif strcmp(ch,'y')
            NM_PreprocessMEEGData(); 
            break;
        end
    end    
end
        

% Load the data
NM_LoadMEEGData();

% Get each trial
global GLA_meeg_data;
for t = 1:length(GLA_meeg_data.data.trial)
    data.trials{t} = calculateRMS(cfg, GLA_meeg_data.data.trial{t});
    data.conditions(t) = GLA_meeg_data.data.trialinfo(t); 
end

% Only one timecourse
data.time = GLA_meeg_data.data.time{1};


function rms = calculateRMS(cfg, t_data)

% Might baseline correct
global GLA_meeg_data;
if isfield(cfg,'baseline_correct') && ...
        strcmp(cfg.baseline_correct,'yes')
    t_data = ft_preproc_baselinecorrect(...
        t_data,1,-1*GLA_meeg_data.pre_stim);
end

% Might only have some channels
channels = [];
if isfield(cfg,'channel')
    for c = 1:length(cfg.channel)
        ind = find(strcmp(GLA_meeg_data.data.label,cfg.channel{c}) == 1);
        if length(ind) ~= 1
            error('Bad channel');
        end
        channels(end+1) = ind; %#ok<AGROW>
    end
else
    channels = 1:size(t_data,1);
end

% TODO: Might want to multiply the mag sensors...
rms = sqrt(mean(t_data(channels,:).^2,1));


