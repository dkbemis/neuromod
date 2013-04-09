function NM_DisplayMEEGAverages(cfg)


% Default to nothing
if ~exist('cfg','var')
    cfg = [];
end

% Get the cleaned data
NM_CreateCleanMEEGData(cfg);

% Default to average all
global GL_avg_data;
if isfield(cfg,'avg_data')
    GL_avg_data = avg_data;
else
    averageData();
end

% Plot the channels
makeChannelPlot(cfg); 

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
    makeFieldPlot(s_types{s}, cfg); 
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


function makeChannelPlot(cfg)

global GL_avg_data;
global GLA_meeg_type;
figure
plot_cfg = [];
plot_cfg.showlabels = 'yes'; 
plot_cfg.interactive = 'yes';
plot_cfg.fontsize = 12; 
plot_cfg.layout = NM_GetCurrentMEEGLayout();
if strcmp(GLA_meeg_type,'meg')
    plot_cfg.magscale = 10;
end

% Plot and save
ft_multiplotER(plot_cfg, GL_avg_data);
if isfield(cfg,'save_name')
    saveas(gcf,[cfg.save_name '_sensors.jpg']); 
end

% Just a butterfly
figure;
plot(GL_avg_data.time*1000, GL_avg_data.avg');
if isfield(cfg,'save_name')
    saveas(gcf,[cfg.save_name '_butterfly.jpg']); 
end

% And the RMS
figure
plot(GL_avg_data.time*1000, sqrt(mean(GL_avg_data.avg .^ 2)));
if isfield(cfg,'save_name')
    saveas(gcf,[cfg.save_name '_rms.jpg']); 
end


function makeFieldPlot(s_type, cfg)

figure;

% TODO: Figure out the right options...
plot_cfg = [];

% Don't clutter the graph
plot_cfg.comment = 'no';
plot_cfg.marker = 'off';
global GL_avg_data;
global GLA_meeg_type;
switch GLA_meeg_type
    case 'meg'

        plot_cfg.layout = 'neuromag306all.lay';

        % Grab the right channels
        plot_cfg.channel = NM_GetMEGChannels(GL_avg_data,s_type);

        % Change scale for magnetometers
        plot_cfg.zlim = [-2e-12 2e-12];    
        if strcmp(s_type,'mag')
            plot_cfg.zlim = plot_cfg.zlim/10;
        end
        
    case 'eeg'
        plot_cfg.layout = 'GSN-HydroCel-256.sfp';
        plot_cfg.zlim = [-4 4];            
    otherwise
        error('Unknown type.');
end

% Plot equal intervals
inter = 0.025;  % 25ms
plot_cfg.xlim = 0:inter:GL_avg_data.time(end);  % Define 12 time intervals

% And plot
ft_topoplotER(plot_cfg,GL_avg_data)
if isfield(cfg,'save_name')
    saveas(gcf,[cfg.save_name '_' s_type '.jpg']); 
end



