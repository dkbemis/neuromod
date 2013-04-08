
% cfg.data_type = 'et';
% cfg.trial_type = 'word_5';
% cfg.p_threshold = .5;
% cfg.rejections = NM_SuggestRejections();
% cfg.measure = 'x_pos';

function NM_AnalyzeTimeCourse(cfg)

global GLA_subject;
disp(['Analyzing ' cfg.measure ' ' cfg.trial_type ' ' ...
    cfg.data_type ' data for ' GLA_subject '...']);

% Make sure we're loaded
NM_LoadSubjectData();

% Get the timecourse
setTimeCourseData(cfg);

% Plot it by condition
plotTimeCourseData();

% Do a point-by-point comparison
analyzeTimeCourseData(cfg);

% And save
saveas(gcf,[NM_GetCurrentDataDirectory() '/analysis/'...
    GLA_subject '/' GLA_subject '_' cfg.data_type ...
    '_' cfg.trial_type '_' cfg.measure '.jpg']);
    

function analyzeTimeCourseData(cfg)

% Plot both types
for t = 1:2
    plotStats(t,(t-1)*5+1:t*5-1, cfg);
end
    

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


function plotTimeCourseData()

% Phrases first...
figure; hold on; subplot(2,1,1);
plotSet('phrases');

% Then lists...
subplot(2,1,2);
plotSet('lists');


function plotSet(type)

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
title(type);
legend('1','2','3','4','Location','NorthEastOutside');


function setTimeCourseData(cfg)

% Send to right function
clear global GL_TC_data;
switch cfg.data_type
    case 'meg_rms'
        setMegRMSData(cfg);
        
    case 'et'
        setETData(cfg);
        
    otherwise
        error('Unimplemented.');
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
    GL_TC_data.trials{t} = GLA_clean_et_data.data.(cfg.measure){t};
    GL_TC_data.conditions(t) = GLA_clean_et_data.data.cond(t); 
end

% Only one timecourse
GL_TC_data.time = GLA_clean_et_data.data.epoch(1):GLA_clean_et_data.data.epoch(2)-1;

% And clear the data
clear global GLA_clean_et_data;


function setMegRMSData(cfg)
error();

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




