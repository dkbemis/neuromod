
% cfg.name = 'word_5_meg_rms_all';
% cfg.type = 'meg_rms';
% cfg.trial_type = 'word_5';
% cfg.window_width = 25;

function stats = NM_AnalyzeTimeCourse(cfg)

global GLA_subject;
disp(['Analyzing ' cfg.name ' for ' GLA_subject '...']);

% Get the timecourse
global GL_TC_data;
GL_TC_data = NM_GetTimeCourseData(cfg);

% Plot it by condition
plotTimeCourseData(cfg);

% Analyze moving windows in the timecourse
stats = analyzeTimeWindows(cfg);

% And some plotting
plotStats(stats);

% And save
saveas(gcf,[NM_GetCurrentDataDirectory() '/analysis/'...
    GLA_subject '/' GLA_subject '_' cfg.name '.jpg']);
    


function plotStats(stats)

for s = 1:length(stats)
    plotStat(stats{s}); 
end


function plotStat(stat)

types = {'phrases','lists'};
effects = {{'linear_r','linear_p','k'},...
    {'diff_2_1','p_2_1','g'},{'diff_3_2','p_3_2','r'},...
    {'diff_4_3','p_4_3','c'},};
for t = 1:length(types)
    subplot(2,1,t); hold on; a = axis;
    for e = 1:length(effects)
        if stat.(types{t}).(effects{e}{1}) > 0
            plotEffect(stat.(types{t}).(effects{e}{2}), ...
                types{t}, stat.epoch,(effects{e}{3}));
            if stat.(types{t}).(effects{e}{2}) < .1
                break;
            end
        end
    end
    axis(a);
end

function plotEffect(p, type, epoch, l_color)

% Plotting settings
line_height = 5e-13;
text_height = 7e-13;

% Set the text
if p > .1
    return;
elseif p > .05
    sig_str = '(*)';
    x = mean(epoch) - 0.01;
elseif p > .01
    sig_str = '*';
    x = mean(epoch);
elseif p > .001
    sig_str = '**';
    x = mean(epoch) - 0.005;
else
    sig_str = '***';
    x = mean(epoch) - 0.01;
end

% Find the height
global GL_TC_data;
beg_ind = find(GL_TC_data.time == epoch(1),1);
end_ind = find(GL_TC_data.time == epoch(2),1);
if strcmp(type,'phrases')
    conditions = 1:4;
else
    conditions = 6:9;
end
m = 0;
for c = conditions
    avg_data = averageData(c);
    m_2 = max(avg_data(beg_ind:end_ind));
    if m_2 > m
        m = m_2;
    end
end

% Plot the marker
errorbar(epoch,[m+line_height m+line_height],[5e-14 5e-14],l_color)

% And the significance
text(x,m+text_height,sig_str)


function stats = analyzeTimeWindows(cfg)

% Roll along
global GL_TC_data;
stats = {};
types = {'phrases','lists'};
for w = 1:cfg.window_width:length(GL_TC_data.time)-cfg.window_width
    
    % Average all the conditions for the time window
    for t = 1:length(types)
        avg_data.(types{t}) = cell(4,1);
        for i = 1:length(GL_TC_data.trials)
            type_cond = GL_TC_data.conditions(i);
            if strcmp(types{t},'lists')
                type_cond = type_cond - 5;
            end
            if type_cond < 5 && type_cond > 0
                avg_data.(types{t}){type_cond}(end+1) = ...
                    mean(GL_TC_data.trials{i}(w:w+cfg.window_width));
            end
        end
    end
    
    % Then get the stats
    stats{end+1} = analyzeTimeWindow(avg_data, [w w+cfg.window_width]); %#ok<AGROW>
end

function stats = analyzeTimeWindow(avg_data, epoch)

% Check the linear trends
global GL_TC_data;
stats.epoch = GL_TC_data.time(epoch);
types = {'phrases','lists'};
for t = 1:length(types)
    all_measures = [];
    for c = 1:4
        all_measures = [all_measures; ...
            [avg_data.(types{t}){c}' repmat(c,length(avg_data.(types{t}){c}),1)]]; %#ok<AGROW>
        
        % Test for increases
        if c > 1
            [h p] = ttest2(avg_data.(types{t}){c},avg_data.(types{t}){c-1});  %#ok<ASGLU>
            stats.(types{t}).(['p_' num2str(c) '_' num2str(c-1)]) = p;
            stats.(types{t}).(['diff_' num2str(c) '_' num2str(c-1)]) = ...
                mean(avg_data.(types{t}){c}) - mean(avg_data.(types{t}){c-1});
        end
    end
    [r p] = corr(all_measures);
    stats.(types{t}).linear_r = r(1,2);
    stats.(types{t}).linear_p = p(1,2);
end


function plotTimeCourseData(cfg)

% Phrases first...
figure; hold on; subplot(2,1,1);
plotSet('phrases');

% Then lists...
subplot(2,1,2);
plotSet('lists');

% And save
global GLA_subject;
saveas(gcf,[NM_GetCurrentDataDirectory() '/analysis/' GLA_subject ...
    '/' GLA_subject '_' cfg.name '.jpg']);


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
    avg_data(c,:) = averageData(conditions(c));
end
plot(GL_TC_data.time,avg_data');

% Labels
title(type);
legend('1','2','3','4','Location','NorthEastOutside');



function avg_data = averageData(c)

global GL_TC_data;
avg_data = zeros(1,length(GL_TC_data.time));
c_ind = find(GL_TC_data.conditions == c);
for t = c_ind
    avg_data = avg_data + GL_TC_data.trials{t};
end
avg_data = avg_data ./ length(c_ind);

