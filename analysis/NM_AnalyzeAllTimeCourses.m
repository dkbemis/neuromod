
function NM_AnalyzeAllTimeCourses()

% Make a plot of all the meg data
trial_types = {'word_1','word_2','word_3','word_4',...
    'word_5','delay','target'};
trial_types = {'delay','target'};
for t = 1:length(trial_types)
    cfg = [];
    cfg.type = 'meg_rms';
    cfg.name = ['meg_' trial_types{t} '_rms_all'];
    cfg.trial_type = trial_types{t};
    cfg.window_width = 25;
    % cfg.channel = {'MEG2412'};
    % cfg.baseline_correct = 'yes';

    stats = NM_AnalyzeTimeCourse(cfg);
end
