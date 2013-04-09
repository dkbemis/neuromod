function NM_AnalyzeMEEGData()

% Make sure we're ready
global GLA_meeg_type;
NM_LoadSubjectData({...
    {[GLA_meeg_type '_word_5_data_preprocessed'],1},...
    });

cfg = [];
cfg.data_type = 'meeg';
cfg.trial_type = 'word_5';
cfg.p_threshold = .05;
cfg.time_windows = {[200 300] [300 500]};
cfg.time_window_measure = 'rms';
cfg.baseline_correct = 0;

% Get the rejections once
global GLA_trial_type;
GLA_trial_type = cfg.trial_type;
cfg.rejections = NM_SuggestRejections();

% Analyze the time courses of sensor sets
cfg.measure = 'rms';
s_types = {'all','posterior'};
if strcmp(GLA_meeg_type,'meg')
    s_types{end+1} = 'left';
end
for s = 1:length(s_types)
    cfg.tc_name = [GLA_meeg_type '_' s_types{s}];
    cfg.channels = NM_GetMEEGChannels(s_types{s});
    NM_AnalyzeTimeCourse(cfg);
end
cfg = rmfield(cfg,'channels');
        
% And the different bands
bands = {[4 8], [8 13], [12 30], [30 50], [50 100]};
band_names = {'theta','alpha','beta','low_gamma','high_gamma'};
for b = 1:length(bands)
    cfg.bpf = bands{b};
    cfg.tc_name = [GLA_meeg_type '_' band_names{b}];
    NM_AnalyzeTimeCourse(cfg);
end

