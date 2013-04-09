function NM_AnalyzeETData()


% Make sure we're ready
NM_LoadSubjectData({...
    {'et_word_5_data_preprocessed',1},...
    });

cfg = [];
cfg.data_type = 'et';
cfg.trial_type = 'word_5';
cfg.p_threshold = .05;
cfg.time_windows = {[200 300] [300 500]};
cfg.time_window_measure = 'rms';

% Get the rejections once
global GLA_trial_type;
GLA_trial_type = cfg.trial_type;
cfg.rejections = NM_SuggestRejections();

% Analyze the time courses
measures =  {'x_pos','y_pos','pupil','x_vel','y_vel'};
for m = 1:length(measures)
    cfg.measure = measures{m};
    cfg.tc_name = cfg.measure;
    NM_AnalyzeTimeCourse(cfg);
end

% And the saccades
measures =  {'num_saccades','saccade_length'};
for m = 1:length(measures)
    cfg.measure = measures{m};
    cfg.sv_name = cfg.measure;
    NM_AnalyzeSingleValues(cfg);
end

