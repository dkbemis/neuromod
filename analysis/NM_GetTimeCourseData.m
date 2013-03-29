
function data = NM_GetTimeCourseData(cfg)

% Make sure we're loaded
NM_LoadSubjectData();

% Send to right function
switch cfg.type
    case 'meg_rms'
        data = getMegRMSData(cfg);
        
    otherwise
        error('Unimplemented.');
end



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


