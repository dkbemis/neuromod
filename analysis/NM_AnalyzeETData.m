function NM_AnalyzeETData()

cfg = [];
cfg.data_type = 'et';
cfg.trial_type = 'word_5';
cfg.p_threshold = .5;

% Get the rejections once
cfg.rejections = NM_SuggestRejections();

measures =  {'x_pos','y_pos','pupil'};
for m = 1:length(measures)
    cfg.measure = measures{m};
    NM_AnalyzeTimeCourse(cfg);
end
