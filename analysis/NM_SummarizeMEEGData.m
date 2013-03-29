function NM_SummarizeMEEGData

% Load up the data
NM_LoadMEEGData(); 

% Get the condition averages
averageConditions();

% Plot the rms_s across all conditions
plotConditionRMSs(); close all;

% Plot the interesting differences
plotDifferences();

% Plot each condition averages
plotConditionAverages();


function plotConditionAverages()

global GLA_subject;
global GLA_meeg_trial_type;
global GL_avg_data;
global GL_freq_data;
global GL_avg_freq_data;
for c = 1:length(GL_avg_data)
    NM_DisplayMEEGAverages([GLA_subject '_' GLA_meeg_trial_type '_' num2str(c)], GL_avg_data{c}); 

    figure;
    imagesc(GL_freq_data{c}.time, GL_freq_data{c}.freq, ...
        GL_avg_freq_data{c}); set(gca,'YDir','normal');
    title(num2str(c));
    saveas(gcf,[GLA_subject '_' GLA_meeg_trial_type ...
        '_' num2str(c) '_freq.jpg']);
    close all;
end


function plotDifferences()

% Phrases...
for c = 4:-1:2
    plotDifference(c,c-1);
end

% Lists...
for c = 9:-1:6
    plotDifference(c,c-1);
end

% Compare...
for c = 1:5
    plotDifference(c,c+5);
end

% And the last two
plotDifference(11,12);


function plotDifference(c_1, c_2)

global GLA_subject;
global GLA_meeg_trial_type;
% RMS first
global GLA_meeg_data;
global GL_rms_data;
figure;
rms = GL_rms_data{c_1} - GL_rms_data{c_2};
plot(GLA_meeg_data.pre_stim:GLA_meeg_data.post_stim-1, rms);
title([num2str(c_1) ' - ' num2str(c_2)]);

saveas(gcf,[GLA_subject '_' GLA_meeg_trial_type ...
    '_sub_' num2str(c_1) '_' num2str(c_2) '_rms.jpg']);


% Then the helper
global GL_avg_data;
data = GL_avg_data{c_1};
data.avg = GL_avg_data{c_1}.avg - GL_avg_data{c_2}.avg;
NM_DisplayMEEGAverages([GLA_subject '_' GLA_meeg_trial_type ...
    '_diff_' num2str(c_1) '_' num2str(c_2)], data); close all;


global GL_freq_data;
global GL_avg_freq_data;
figure;
imagesc(GL_freq_data{c_1}.time, GL_freq_data{c_2}.freq, ...
    GL_avg_freq_data{c_1}-GL_avg_freq_data{c_2}); set(gca,'YDir','normal');
title([num2str(c_1) ' - ' num2str(c_2)]);
saveas(gcf,[GLA_subject '_' GLA_meeg_trial_type ...
    '_sub_' num2str(c_1) '_' num2str(c_2) '_freq.jpg']);

global GL_pow_data;
global GL_avg_pow_data;
figure;
pow_data = GL_avg_pow_data{c_1} - GL_avg_pow_data{c_2};
plot(GL_pow_data{1}.freq, pow_data);
title([num2str(c_1) ' - ' num2str(c_2)]);

saveas(gcf,[GLA_subject '_' GLA_meeg_trial_type ...
    '_sub_' num2str(c_1) '_' num2str(c_2) '_pow.jpg']);


function plotConditionRMSs()

global GLA_meeg_data;
global GL_rms_data;
global GLA_subject;
global GLA_meeg_trial_type;
plotConditionData(GLA_meeg_data.pre_stim:GLA_meeg_data.post_stim-1,...
    [GL_rms_data{1}; GL_rms_data{2}; GL_rms_data{3}; GL_rms_data{4}],...
    [GL_rms_data{6}; GL_rms_data{7}; GL_rms_data{8}; GL_rms_data{9}],...
    [GLA_subject '_' GLA_meeg_trial_type '_rms.jpg']);


% And the frequency bands
global GL_freq_data;
global GL_freq_bands;
global GL_freq_band_data;
for b = 1:length(GL_freq_bands)
    plotConditionData(GL_freq_data{1}.time,...
        [GL_freq_band_data{b}{1}; GL_freq_band_data{b}{2}; GL_freq_band_data{b}{3}; GL_freq_band_data{b}{4}],...
        [GL_freq_band_data{b}{6}; GL_freq_band_data{b}{7}; GL_freq_band_data{b}{8}; GL_freq_band_data{b}{9}],...
        [GLA_subject '_' GLA_meeg_trial_type '_' GL_freq_bands{b}{1} '.jpg']);
end


global GL_pow_data;
global GL_avg_pow_data;
plotConditionData(GL_pow_data{1}.freq,...
    [GL_avg_pow_data{1}; GL_avg_pow_data{2}; GL_avg_pow_data{3}; GL_avg_pow_data{4}],...
    [GL_avg_pow_data{6}; GL_avg_pow_data{7}; GL_avg_pow_data{8}; GL_avg_pow_data{9}],...
    [GLA_subject '_' GLA_meeg_trial_type '_pow.jpg']);


function plotConditionData(time, phrase_data, list_data, save_name)

figure;
subplot(2,1,1); hold on;
plot(time, phrase_data);
legend('1','2','3','4'); title('Phrases');

subplot(2,1,2); hold on;
plot(time, list_data);
legend('1','2','3','4'); title('Lists');

saveas(gcf,save_name);     

function averageConditions()

global GL_pow_data;
global GL_freq_data;
global GL_avg_data;
global GL_rms_data;
global GLA_meeg_data;
tmp_data = GLA_meeg_data.data;
for t = 1:length(tmp_data.trial)
    tmp_data.trial{t} = ft_preproc_baselinecorrect(...
        tmp_data.trial{t},1,-1*GLA_meeg_data.pre_stim);
end

% Not so sure about this...
freq_cfg              = [];
freq_cfg.output       = 'pow';
freq_cfg.method       = 'mtmconvol';
freq_cfg.taper        = 'hanning';
freq_cfg.foi          = 1:1:50;                         % analysis 2 to 30 Hz in steps of 2 Hz 
freq_cfg.t_ftimwin    = ones(length(freq_cfg.foi),1).*0.3;   % length of time window = 0.5 sec
freq_cfg.toi          = GLA_meeg_data.pre_stim/1000:0.05:GLA_meeg_data.post_stim/1000;                  % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)            % time window "slides" from -0.5 to 1.5 sec in steps of 0.05 sec (50 ms)

pow_cfg            = [];
pow_cfg.output     = 'pow';
pow_cfg.method     = 'mtmfft';
pow_cfg.foilim     = [0 125];
pow_cfg.tapsmofrq  = 5;
pow_cfg.keeptrials = 'yes';


% Now get all of the condition averages
GL_avg_data = {}; GL_rms_data = {}; GL_freq_data = {}; GL_pow_data = {};
for c = unique(tmp_data.trialinfo)'

    cfg = [];
    cfg.trials = find(tmp_data.trialinfo == c);
    GL_avg_data{c} = ft_timelockanalysis(cfg, tmp_data); %#ok<*AGROW>
    GL_rms_data{c} = sqrt(mean(GL_avg_data{c}.avg .^ 2));

    freq_cfg.trials = cfg.trials;
    GL_freq_data{c}    = ft_freqanalysis(freq_cfg, GLA_meeg_data.data);

    pow_cfg.trials = cfg.trials;
    GL_pow_data{c}    = ft_freqanalysis(pow_cfg, GLA_meeg_data.data);
end

% Phrases...
cfg = [];
cfg.trials = find(tmp_data.trialinfo == 2 | tmp_data.trialinfo == 3 | tmp_data.trialinfo == 4);
GL_avg_data{11} = ft_timelockanalysis(cfg, tmp_data);
GL_rms_data{11} = sqrt(mean(GL_avg_data{11}.avg .^ 2));    
freq_cfg.trials = cfg.trials;
GL_freq_data{11}    = ft_freqanalysis(freq_cfg, GLA_meeg_data.data);
pow_cfg.trials = cfg.trials;
GL_pow_data{11}    = ft_freqanalysis(pow_cfg, GLA_meeg_data.data);

% Lists...
cfg = [];
cfg.trials = find(tmp_data.trialinfo == 6 | tmp_data.trialinfo == 7 | tmp_data.trialinfo == 8);
GL_avg_data{12} = ft_timelockanalysis(cfg, tmp_data);
GL_rms_data{12} = sqrt(mean(GL_avg_data{12}.avg .^ 2));    
freq_cfg.trials = cfg.trials;
GL_freq_data{12}    = ft_freqanalysis(freq_cfg, GLA_meeg_data.data);
pow_cfg.trials = cfg.trials;
GL_pow_data{12}    = ft_freqanalysis(pow_cfg, GLA_meeg_data.data);

% All...
cfg = [];
cfg.trials = 'all';
GL_avg_data{13} = ft_timelockanalysis(cfg, tmp_data);
GL_rms_data{13} = sqrt(mean(GL_avg_data{13}.avg .^ 2));    
freq_cfg.trials = cfg.trials;
GL_freq_data{13}    = ft_freqanalysis(freq_cfg, GLA_meeg_data.data);
pow_cfg.trials = cfg.trials;
GL_pow_data{13}    = ft_freqanalysis(pow_cfg, GLA_meeg_data.data);



global GL_avg_freq_data;
GL_avg_freq_data = {};
global GL_avg_pow_data;
GL_avg_pow_data = {};
for c = 1:length(GL_freq_data)
    averageFrequencyData(c);
end

% Break it down by frequency bands
global GL_freq_bands;
global GL_freq_band_data;
GL_freq_band_data = {};
GL_freq_bands = {{'delta',[.5 4]},{'theta',[4 8]},{'alpha',[8 14]},{'beta',[14 30]},{'gamma',[30 80]}};
for b = 1:length(GL_freq_bands)
    GL_freq_band_data{b} = {};
    for c = 1:length(GL_freq_data)
        averageFrequencyBandData(b,c);
    end
end


function averageFrequencyBandData(b,c)

% Average everything within the band
global GL_freq_bands;
global GL_freq_band_data;
global GL_avg_freq_data;
global GL_freq_data;
GL_freq_band_data{b}{c} = zeros(1,length(GL_freq_data{c}.time));
for f = 1:length(GL_freq_data{c}.freq)
    if GL_freq_data{c}.freq(f) >= GL_freq_bands{b}{2}(1) && ...
            GL_freq_data{c}.freq(f) < GL_freq_bands{b}{2}(2)
         GL_freq_band_data{b}{c} = GL_freq_band_data{b}{c} + GL_avg_freq_data{c}(f,:);
    end
end


function averageFrequencyData(c)

global GL_avg_freq_data;
global GL_freq_data;
global GL_pow_data;
global GL_avg_pow_data;

% Average here over channels
GL_avg_freq_data{c} = squeeze(nanmean(GL_freq_data{c}.powspctrm));

% Baseline correct
baselines = [];
for f = 1:length(GL_freq_data{c}.freq)
    vals = [];
     for t = 1:length(GL_freq_data{c}.time)
         if GL_freq_data{c}.time(t) > 0
             break;
         end
         if ~isnan(GL_avg_freq_data{c}(f,t))
             vals(end+1) = GL_avg_freq_data{c}(f,t); %#ok<AGROW>
         end
     end
     baselines(end+1) = mean(vals); %#ok<AGROW>
end
GL_avg_freq_data{c} = GL_avg_freq_data{c} ./ repmat(baselines',1,length(GL_freq_data{c}.time));

% Just average these...
GL_avg_pow_data{c} = squeeze(mean(mean(GL_pow_data{c}.powspctrm,1),2))';

