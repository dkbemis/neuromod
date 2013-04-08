function NM_DisplayMEEGAverages(save_name, avg_data)

% Default not to save
if ~exist('save_name','var')
    save_name = [];
end

% Get the cleaned data
NM_CreateCleanMEEGData();

% Default to average all
global GL_avg_data;
if ~exist('avg_data','var') || isempty(avg_data)
    averageData();
else
    GL_avg_data = avg_data;
end

% Plot the channels
makeChannelPlot(save_name); 

% And the three sensor averages
global GLA_meeg_type;
switch GLA_meeg_type
    case 'meg'
        s_types = {'grad_1','grad_2','mag'};
        
    case 'eeg'
        s_types = {'eeg'};
        
    otherwise
        error('Unknown type.');
end
for s = 1:length(s_types)
    makeFieldPlot(s_types{s}, save_name); 
end

% And clear the memory
clear global GLA_clean_meeg_data;
clear global GL_avg_data;


function averageData()

% Baseline correct first
disp('Averaging data...');
global GLA_clean_meeg_data;
global GL_avg_data;

cfg = [];
GL_avg_data = ft_timelockanalysis(cfg, GLA_clean_meeg_data.data);
disp('Done');


function makeChannelPlot(save_name)

global GL_avg_data;
global GLA_meeg_type;
figure
cfg = [];
cfg.showlabels = 'yes'; 
cfg.interactive = 'yes';
cfg.fontsize = 12; 
cfg.layout = NM_GetCurrentMEEGLayout();
if strcmp(GLA_meeg_type,'meg')
    cfg.magscale = 10;
end

% Plot and save
ft_multiplotER(cfg, GL_avg_data);
if ~isempty(save_name)
    saveas(gcf,[save_name '_sensors.jpg']); 
end

% Just a butterfly
figure;
plot(GL_avg_data.time*1000, GL_avg_data.avg');
if ~isempty(save_name)
    saveas(gcf,[save_name '_butterfly.jpg']); 
end

% And the RMS
figure
plot(GL_avg_data.time*1000, sqrt(mean(GL_avg_data.avg .^ 2)));
if ~isempty(save_name)
    saveas(gcf,[save_name '_rms.jpg']); 
end


function makeFieldPlot(s_type, save_name)

figure;

% TODO: Figure out the right options...
cfg = [];

% Don't clutter the graph
cfg.comment = 'no';
cfg.marker = 'off';
global GL_avg_data;
global GLA_meeg_type;
switch GLA_meeg_type
    case 'meg'

        cfg.layout = 'neuromag306all.lay';

        % Grab the right channels
        cfg.channel = NM_GetMEGChannels(GL_avg_data,s_type);

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

% Plot equal intervals
inter = 0.025;  % 25ms
cfg.xlim = 0:inter:GL_avg_data.time(end);  % Define 12 time intervals

% And plot
ft_topoplotER(cfg,GL_avg_data)
if ~isempty(save_name)
    saveas(gcf,[save_name '_' s_type '.jpg']); 
end



