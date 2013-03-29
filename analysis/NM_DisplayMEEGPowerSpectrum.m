function NM_DisplayMEEGPowerSpectrum()

% Load up the data
NM_LoadMEEGData();

global GLA_meeg_data;
global GL_freq_data;
cfg.output       = 'pow';
cfg.channel      = 'MEG';
cfg.method       = 'mtmconvol';
cfg.taper        = 'hanning';
cfg.foi          = 1:1:50;                         % analysis 2 to 30 Hz in steps of 2 Hz 
cfg.t_ftimwin    = ones(length(cfg.foi),1).*0.3;   % length of time window = 0.5 sec
cfg.toi          = -0.2:0.02:.6;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)
GL_freq_data    = ft_freqanalysis(cfg, GLA_meeg_data.data);

% Average here over channels
avg_freq = squeeze(nanmean(GL_freq_data.powspctrm));

% Baseline correct
baselines = [];
for f = 1:length(GL_freq_data.freq)
    vals = [];
     for t = 1:length(GL_freq_data.time)
         if GL_freq_data.time(t) > 0
             break;
         end
         if ~isnan(avg_freq(f,t))
             vals(end+1) = avg_freq(f,t); %#ok<AGROW>
         end
     end
     baselines(end+1) = mean(vals); %#ok<AGROW>
end
avg_freq = avg_freq ./ repmat(baselines',1,length(GL_freq_data.time));
imagesc(GL_freq_data.time, GL_freq_data.freq, avg_freq); set(gca,'YDir','normal')


% And the power spectrum
cfg            = [];
cfg.output     = 'pow';
cfg.method     = 'mtmfft';
cfg.foilim     = [0 125];
cfg.tapsmofrq  = 5;
cfg.keeptrials = 'yes';

% And plot...
freq_data    = ft_freqanalysis(cfg, GLA_meeg_data.data);
plot(freq_data.freq,squeeze(mean(mean(freq_data.powspctrm,1),2)));
