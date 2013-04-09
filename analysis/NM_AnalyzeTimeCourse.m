
% cfg.data_type = 'et';
% cfg.trial_type = 'word_5';
% cfg.p_threshold = .5;
% cfg.rejections = NM_SuggestRejections();
% cfg.measure = 'x_pos';
% cfg.time_windows = {[200 300]};

function NM_AnalyzeTimeCourse(cfg)

cfg = [];
cfg.data_type = 'meeg';
cfg.trial_type = 'word_5';
cfg.p_threshold = .05;
cfg.time_windows = {[200 300] [300 500]};
cfg.time_window_measure = 'rms';
cfg.measure = 'rms';
% cfg.bpf = [8 13];
cfg.rejections = [];
% cfg.baseline_correct = 0;


global GLA_subject;
disp(['Analyzing ' cfg.measure ' ' cfg.trial_type ' ' ...
    cfg.data_type ' data for ' GLA_subject '...']);

% Make sure we're loaded
NM_LoadSubjectData();

% Get the timecourse
setTimeCourseData(cfg);

% Plot it by condition
plotTimeCourseData(cfg);

% Do a point-by-point comparison
analyzeTimeCourseData(cfg);

% And save
saveas(gcf,[NM_GetCurrentDataDirectory() '/analysis/'...
    GLA_subject '/' GLA_subject '_' cfg.data_type ...
    '_' cfg.trial_type '_' cfg.measure '.jpg']);

% And any time windows    
if isfield(cfg,'time_windows')
    for w = 1:length(cfg.time_windows)
        analyzeTimeWindow(cfg.time_windows{w}, cfg);
    end
end


function analyzeTimeCourseData(cfg)

% Plot both types
for t = 1:2
    plotStats(t,(t-1)*5+1:t*5-1, cfg);
end


function analyzeTimeWindow(window, cfg)

global GL_TC_data;
w_start = find(GL_TC_data.time == window(1),1);
w_end = find(GL_TC_data.time == window(2),1);
cfg.SV_data.trial_cond = GL_TC_data.conditions;
for t = 1:length(GL_TC_data.trials)
    switch cfg.time_window_measure
        case 'mean'
           cfg.SV_data.trial_data(t) = mean(GL_TC_data.trials{t}(w_start:w_end));

        case 'rms'
           cfg.SV_data.trial_data(t) = sqrt(mean(GL_TC_data.trials{t}(w_start:w_end) .^2));
        
        case 'max'
           cfg.SV_data.trial_data(t) = max(GL_TC_data.trials{t}(w_start:w_end));
        
        case 'min'
           cfg.SV_data.trial_data(t) = min(GL_TC_data.trials{t}(w_start:w_end));
           
        otherwise
            error('Unknown measure');
    end
end
cfg.measure = [cfg.trial_type ' ' cfg.measure ' ' cfg.time_window_measure ...
    ' (' num2str(window(1)) '-' num2str(window(2)) ')'];       % For naming
NM_AnalyzeSingleValues(cfg);



function plotStats(t_num, conditions, cfg)

% Set the plotting parameters
subplot(2,1,t_num);
a = axis(); 
line_spacing = (a(4)-a(3))/20;
axis([a(1) a(2) a(3) a(4) + line_spacing*6]);
hold on;
colors = {'b','g','r','c'};

% Calculate point-by-point linear correlation
global GL_TC_data;
corr_data_x = [];
corr_data_y = [];
for c = conditions
    corr_data_x = vertcat(corr_data_x,GL_TC_data.condition_data{c}); %#ok<AGROW>
    corr_data_y = vertcat(corr_data_y,c*ones(size(GL_TC_data.condition_data{c},1),1)); %#ok<AGROW>
end
[r p] = corr(corr_data_x, corr_data_y);
plotStat(a, line_spacing, 1, p, r, {'k','y'}, cfg);

% And the pairwise comparisons
for c = 1:length(conditions)-1
    
    [h p ci s] = ttest2(GL_TC_data.condition_data{conditions(c)},...
        GL_TC_data.condition_data{conditions(c+1)}); %#ok<ASGLU>
    plotStat(a, line_spacing, c+1, p, s.tstat, {colors{c},colors{c+1}}, cfg);
end


function plotStat(a, line_spacing, line_num, p, dir, colors, cfg)

% Fix the points
x = a(1):a(2)-1; y = (a(4)+line_num*line_spacing)*ones(1,a(2)-a(1));

% And plot both sides
scatter(x(p<cfg.p_threshold & dir > 0), y(p<cfg.p_threshold & dir > 0),1,'.',colors{1});
scatter(x(p<cfg.p_threshold & dir < 0), y(p<cfg.p_threshold & dir < 0),1,'.',colors{2});


function plotTimeCourseData(cfg)

% Phrases first...
figure; hold on; subplot(2,1,1);
plotSet('phrases', cfg);

% Then lists...
subplot(2,1,2);
plotSet('lists', cfg);


function plotSet(type, cfg)

global GL_TC_data;

switch type
    case 'phrases'
        conditions = 1:4;
        
    case 'lists'
        conditions = 6:9;
        
    otherwise
        error('Unknown type');
end

% Average the conditions of interest
% I.e. not the extraneous one-word condition for now
avg_data = zeros(length(conditions),length(GL_TC_data.time));
for c = 1:length(conditions)
    avg_data(c,:) = mean(GL_TC_data.condition_data{conditions(c)});
end
plot(GL_TC_data.time,avg_data');

% Labels
global GLA_subject;
title([type ': ' GLA_subject ' ' cfg.data_type ...
    ' ' cfg.trial_type ' ' cfg.measure]);
legend('1','2','3','4','Location','NorthEastOutside');


function setTimeCourseData(cfg)

% Send to right function
clear global GL_TC_data;
switch cfg.data_type
    case 'meeg'
        setMEEGData(cfg);
        
    case 'et'
        setETData(cfg);
        
    otherwise
        error('Unknown type');
end

% Pre-group as well, so we can average / test easier
grougData();


function grougData()

global GL_TC_data;
for c = unique(GL_TC_data.conditions)
    t_ctr = 1;
    GL_TC_data.condition_data{c} = [];
    for t = find(GL_TC_data.conditions == c)
        GL_TC_data.condition_data{c}(t_ctr,:) = ...
            GL_TC_data.trials{t};
        t_ctr = t_ctr+1;
    end
end


function setETData(cfg)

% Should be preprocessed
global GLA_subject_data;
global GLA_trial_type; GLA_trial_type = cfg.trial_type; 
if ~isfield(GLA_subject_data.parameters,['et_' GLA_trial_type '_data_preprocessed']) ||...
        GLA_subject_data.parameters.(['et_' GLA_trial_type '_data_preprocessed']) ~= 1
    error(['Eye tracking ' GLA_trial_type ' data not preprocessed.']);
end
        
% Load the cleaned data
if isfield(cfg,'rejections')
    NM_CreateCleanETData(cfg.rejections);
else
    NM_CreateCleanETData();    
end

% Get each trial
global GL_TC_data;
global GLA_clean_et_data;
for t = 1:length(GLA_clean_et_data.data.cond)
    switch cfg.measure
        case 'x_pos'
            GL_TC_data.trials{t} = GLA_clean_et_data.data.x_pos{t};
    
        case 'y_pos'
            GL_TC_data.trials{t} = GLA_clean_et_data.data.y_pos{t};
            
        case 'pupil'
            GL_TC_data.trials{t} = GLA_clean_et_data.data.pupil{t};

        case 'x_vel'
            GL_TC_data.trials{t} = [0 diff(GLA_clean_et_data.data.x_pos{t})];

        case 'y_vel'
            GL_TC_data.trials{t} = [0 diff(GLA_clean_et_data.data.y_pos{t})];

        otherwise
            error('Unknown measure');
    end            
end

% Set these faster...
GL_TC_data.conditions = GLA_clean_et_data.data.cond; 
GL_TC_data.time = GLA_clean_et_data.data.epoch(1):GLA_clean_et_data.data.epoch(2)-1;

% And clear the data
clear global GLA_clean_et_data;


function setMEEGData(cfg)

% Should be preprocessed
global GLA_subject_data;
global GLA_meeg_type;
global GLA_trial_type; GLA_trial_type = cfg.trial_type; 
if ~isfield(GLA_subject_data.parameters,[GLA_meeg_type '_' GLA_trial_type '_data_preprocessed']) ||...
        GLA_subject_data.parameters.([GLA_meeg_type '_' GLA_trial_type '_data_preprocessed']) ~= 1
    error([GLA_meeg_type ' ' GLA_trial_type ' data not preprocessed.']);
end
        
% Load the cleaned data
if isfield(cfg,'rejections')
    NM_CreateCleanMEEGData(cfg.rejections);
else
    NM_CreateCleanMEEGData();    
end

% Might only want some channels
global GLA_clean_meeg_data;
channels = [];
if isfield(cfg,'channels')
    for c = 1:length(cfg.channels)
        ind = find(strcmp(GLA_clean_meeg_data.data.label,cfg.channels{c}) == 1);
        if length(ind) ~= 1
            error('Bad channel');
        end
        channels(end+1) = ind; %#ok<AGROW>
    end
else
    channels = 1:size(GLA_clean_meeg_data.data.label,1);
end

% See if there's a filter
if isfield(cfg,'bpf')
    disp(['Applying band pass filter: ' num2str(cfg.bpf(1)) '-' ...
        num2str(cfg.bpf(2)) 'Hz...']);
    filt_cfg = []; 
    filt_cfg.bpfilter = 'yes';
    filt_cfg.bpfreq = cfg.bpf;
    GLA_clean_meeg_data.data = ft_preprocessing(filt_cfg, GLA_clean_meeg_data.data);
    disp('Done.');
end

% Get each trial
global GL_TC_data;
for t = 1:length(GLA_clean_meeg_data.data.trial)
    switch cfg.measure
        case 'rms'
            % TODO: Might want to multiply the mag sensors...
            GL_TC_data.trials{t} = sqrt(mean(GLA_clean_meeg_data.data.trial{t}(channels,:).^2,1));

        otherwise
            error('Unknown measure');
    end            
end

% Set these faster...
GL_TC_data.conditions = GLA_clean_meeg_data.data.trialinfo'; 
GL_TC_data.time = GLA_clean_meeg_data.data.time{1}*1000;        % In ms...

% And clear the data
clear global GLA_clean_meeg_data;


