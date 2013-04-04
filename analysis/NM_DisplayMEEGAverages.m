function NM_DisplayMEEGAverages(save_name, baseline_correct, avg_data)

% Default not to save
if ~exist('save_name','var')
    save_name = [];
end

% Default not to baseline correct
if ~exist('baseline_correct','var')
    baseline_correct = 0; 
end

% Get the cleaned data
NM_ApplyMEEGRejections();

% Default to average all
global GL_avg_data;
if ~exist('avg_data','var') || isempty(avg_data)
    averageData(baseline_correct);
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


function averageData(baseline_correct)

% Baseline correct first
disp('Averaging data...');
global GLA_clean_meeg_data;
global GL_avg_data;
GL_avg_data = GLA_clean_meeg_data.data;

% If we must...
if baseline_correct
    disp('Baseline correcting data...');
    for t = 1:length(GL_avg_data.trial)
        GL_avg_data.trial{t} = ft_preproc_baselinecorrect(...
            GL_avg_data.trial{t},1,find(GL_avg_data.time{1} >0,1));
    end
    disp('Done.');
end

cfg = [];
GL_avg_data = ft_timelockanalysis(cfg, GL_avg_data);
disp('Done');


function makeChannelPlot(save_name)

global GL_avg_data;
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



