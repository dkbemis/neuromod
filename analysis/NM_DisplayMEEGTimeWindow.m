function NM_DisplayMEEGTimeWindow(window)

% Load up the data
NM_LoadMEEGData();

% Average it
averageData();

% Show each sensor set
s_types = {'grad_1','grad_2','mag'};
for s = 1:length(s_types)
    makeFieldPlots(s_types{s}, window);     
end

function makeFieldPlots(s_type, window)

global GL_avg_data;
figure;
conditions = fieldnames(GL_avg_data);
for c = 1:length(conditions)
    subplot(2,4,c);
    makeFieldPlot(s_type,window, conditions{c});
end

global GLA_meeg_trial_type;
global GLA_subject;
saveas(gcf,[NM_GetCurrentDataDirectory() '/analysis/' ...
    GLA_subject '/' GLA_subject '_' GLA_meeg_trial_type '_' s_type '_'...
    num2str(round(1000*window(1))) '_' num2str(round(1000*window(2))) '.jpg']);


function makeFieldPlot(s_type,window,condition)

global GL_avg_data;
title(condition);
c_data = GL_avg_data.(condition);

% TODO: Figure out the right options...
cfg = [];

% Don't clutter the graph
cfg.comment = 'no';
cfg.marker = 'off';
global GLA_meeg_type;
switch GLA_meeg_type
    case 'meg'

        cfg.layout = 'neuromag306all.lay';

        % Grab the right channels
        cfg.channel = NM_GetMEGChannels(c_data,s_type);

        % Change scale for magnetometers
        cfg.zlim = [-2e-12 2e-12];    
        if strcmp(s_type,'mag')
            cfg.zlim = cfg.zlim/10;
        end
        
    case 'eeg'
        cfg.layout = 'GSN-HydroCel-256.sfp';
        cfg.zlim = [-4 4];            
    otherwise
        error('Unknown type.');
end

% And plot
cfg.xlim = window;
ft_topoplotER(cfg,c_data)


function averageData()

% Baseline correct first
disp('Averaging data...');
global GLA_meeg_data;
tmp_data = GLA_meeg_data.data;
for t = 1:length(tmp_data.trial)
    tmp_data.trial{t} = ft_preproc_baselinecorrect(...
        tmp_data.trial{t},1,-1*GLA_meeg_data.pre_stim);
end

% Now, average each condition
global GL_avg_data;
conditions = {{'Phrase1',1},{'Phrase2',2},{'Phrase3',3},{'Phrase4',4}...
    {'List1',6},{'List2',7},{'List3',8},{'List4',9}};
for c = 1:length(conditions)
    cfg = [];
    cfg.trials = find(GLA_meeg_data.data.trialinfo == conditions{c}{2});
    GL_avg_data.(conditions{c}{1}) = ft_timelockanalysis(cfg, tmp_data);
end
disp('Done');
