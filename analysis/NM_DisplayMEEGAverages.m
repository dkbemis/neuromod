function NM_DisplayMEEGAverages(save_name, avg_data)

if ~exist('save_name','var')
    save_name = [];
end

% Load up the data
NM_LoadMEEGData();

% Default to average all
global GL_tmp_data;
if ~exist('avg_data','var') || isempty(avg_data)
    averageData();
else
    GL_tmp_data = avg_data;
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


function averageData()

% Baseline correct first
disp('Averaging data...');
global GLA_meeg_data;
global GL_tmp_data;
GL_tmp_data = GLA_meeg_data.data;
for t = 1:length(GL_tmp_data.trial)
    GL_tmp_data.trial{t} = ft_preproc_baselinecorrect(...
        GL_tmp_data.trial{t},1,-1*GLA_meeg_data.pre_stim);
end

cfg = [];
GL_tmp_data = ft_timelockanalysis(cfg, GL_tmp_data);
disp('Done');


function makeChannelPlot(save_name)

global GL_tmp_data;
global GLA_meeg_type;
figure
cfg = [];
cfg.showlabels = 'yes'; 
cfg.interactive = 'yes';
cfg.fontsize = 12; 

switch GLA_meeg_type
    case 'meg'
        cfg.layout = 'neuromag306all.lay';
        cfg.magscale = 10;
        
    case 'eeg'
        cfg.layout = 'GSN-HydroCel-256.sfp';
        
    otherwise
        error('Unknown type.');
end


% Plot and save
ft_multiplotER(cfg, GL_tmp_data);
if ~isempty(save_name)
    saveas(gcf,[save_name '_sensors.jpg']); 
end

% Just a butterfly
figure;
global GLA_meeg_data;
plot(GLA_meeg_data.pre_stim:GLA_meeg_data.post_stim-1, GL_tmp_data.avg');
if ~isempty(save_name)
    saveas(gcf,[save_name '_butterfly.jpg']); 
end

% And the RMS
figure
plot(GLA_meeg_data.pre_stim:GLA_meeg_data.post_stim-1, ...
    sqrt(mean(GL_tmp_data.avg .^ 2)));
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
global GL_tmp_data;
global GLA_meeg_type;
switch GLA_meeg_type
    case 'meg'

        cfg.layout = 'neuromag306all.lay';

        % Grab the right channels
        cfg.channel = NM_GetMEGChannels(GL_tmp_data,s_type);

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
global GLA_meeg_data;
cfg.xlim = 0:inter:GLA_meeg_data.post_stim/1000;  % Define 12 time intervals

% And plot
ft_topoplotER(cfg,GL_tmp_data)
if ~isempty(save_name)
    saveas(gcf,[save_name '_' s_type '.jpg']); 
end



