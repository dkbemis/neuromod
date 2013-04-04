function NM_SetMEEGRejections()

% Load the data
global GLA_meeg_type;
global GLA_subject;
global GLA_trial_type;
disp(['Setting ' GLA_meeg_type ' rejections for ' GLA_trial_type ' for ' GLA_subject]);
NM_LoadMEEGData();

% Use whichever type we set
global GLA_subject_data;
global GLA_meeg_data;
GLA_meeg_data.rejections = {};
GLA_meeg_data.rejections(1).type = ...
    GLA_subject_data.parameters.meeg_rej_type;
switch GLA_subject_data.parameters.meeg_rej_type
    case 'raw'
        GLA_meeg_data.rejections(1).trials = ...
            rejectArtifacts_Raw();
        
    case 'summary'
        GLA_meeg_data.rejections(1).trials = ...
            rejectArtifacts_Summary();
        
    otherwise
        error('Unknown type');
end


% Take out duplicates and save
NM_SaveMEEGData();
disp('Done.');


function rej = rejectArtifacts_Raw()

% Artifact rejection
global GLA_meeg_data;
cfg = [];
cfg.channel = GLA_meeg_data.settings.channel;
cfg.magscale = 10;
cfg = ft_databrowser(cfg,GLA_meeg_data.data);
rej = findTrialRejections(cfg.artfctdef.visual.artifact);


function rej = rejectArtifacts_Summary()

global GLA_meeg_data;
cfg = [];
cfg.channel = GLA_meeg_data.settings.channel;
cfg.magscale = 10;
cfg.method = 'summary';   % 'tral', 'channel', 'summary'
tmp_data = ft_rejectvisual(cfg,GLA_meeg_data.data);
rej = findTrialRejections(tmp_data.cfg.artifact);


function r_trials = findTrialRejections(rejections)


% Create sample data, if not there
% NOTE: It gets deleted when we append runs
global GLA_meeg_data;
if ~isfield(GLA_meeg_data.data, 'sampleinfo')
    
    % Set to be contiguous
    t_len = round((GLA_meeg_data.data.time{1}(end) - GLA_meeg_data.data.time{1}(1))*1000)+1;
    sampleinfo(:,1) = 1:t_len:length(GLA_meeg_data.data.trial)*t_len;
    sampleinfo(:,2) = t_len:t_len:length(GLA_meeg_data.data.trial)*t_len;
else
    sampleinfo = GLA_meeg_data.data.sampleinfo;
end

% We're going to hope they always treat these as continuous
r_trials = [];
for r = 1:size(rejections,1)
    
    % Make sure all is as it's supposed to be
    rej_beg = find(sampleinfo(:,2) >= rejections(r,1),1);
    rej_end = find(sampleinfo(:,2) >= rejections(r,2),1);
    if rej_beg ~= rej_end
        error('Rejection not as expected.');
    end
    r_trials(end+1) = rej_beg; %#ok<AGROW>
end


% TTest
% 
% function rejectBlinks()
% 
% rej = [];
% global GLA_meeg_data;
% global GLA_meeg_trial_type;
% for t = 1:length(GLA_meeg_data.blinks.trials)
%     has_blink = ~isempty(GLA_meeg_data.blinks.starts{t}) ||...
%         ~isempty(GLA_meeg_data.blinks.stops{t});
%     
%     % Want to keep only blinks for blinks trials
%     if (strcmp(GLA_meeg_trial_type,'blinks') && ~has_blink) ||...
%             (~strcmp(GLA_meeg_trial_type,'blinks') && has_blink)
%         rej(end+1) = t; %#ok<AGROW>
%     end
% end
% if strcmp(GLA_meeg_trial_type,'blinks')
%     type = 'No blink';
% else
%     type = 'Blink';
% end
% suggestRejections(type,rej);
% 
% 
% function rejectBehavioral()
% 
% rej = [];
% global GLA_meeg_data;
% for t = 1:length(GLA_meeg_data.behavioral.errors)
%     if GLA_meeg_data.behavioral.errors(t) || GLA_meeg_data.behavioral.outliers(t) ||...
%             GLA_meeg_data.behavioral.timeouts(t)
%         rej(end+1) = t; %#ok<AGROW>
%     end
% end
% suggestRejections('Behavioral',rej);
% 
% 
% 
% function suggestRejections(type, rej)
% 
% % Might not have any
% if isempty(rej)
%     disp(['No ' type ' rejections to suggest.']);
%     return;
% end
% 
% % See if we're first
% global GLA_subject_data
% global GLA_meeg_trial_type;
% global GLA_meeg_type;
% if ~isfield(GLA_subject_data.parameters,[GLA_meeg_type '_' ...
%         GLA_meeg_trial_type '_rejections'])
%     GLA_subject_data.parameters.([GLA_meeg_type '_' ...
%         GLA_meeg_trial_type '_rejections']) = [];
% end
% 
% % Check
% rej_str = [type ' rejections (' num2str(length(rej)) '): '];
% for r = 1:length(rej)
%     rej_str = [rej_str num2str(rej(r)) ' '];  %#ok<AGROW>
% end
% disp(rej_str);
% while 1
%     rej_ch = input('Reject? (y/n): ','s');
%     if strcmp(rej_ch,'y')
%         GLA_subject_data.parameters.([GLA_meeg_type '_' ...
%                 GLA_meeg_trial_type '_rejections'])(end+1:end+length(rej)) = rej;
%         break;
%     elseif strcmp(rej_ch,'n')
%         break;
%     end
% end
% 
% 
% function applyRejections()
% 
% global GLA_subject_data;
% global GLA_meeg_data;
% 
% % Reduce and set
% global GLA_meeg_type;
% global GLA_meeg_trial_type;
% GLA_meeg_data.rejections = ...
%     sort(unique(GLA_subject_data.parameters.([GLA_meeg_type '_' ...
%                 GLA_meeg_trial_type '_rejections'])));
% cfg = [];
% cfg.trials = 1:length(GLA_meeg_data.data.trial);
% for r = 1:length(GLA_meeg_data.rejections)
%     ind = find(cfg.trials == GLA_meeg_data.rejections(r),1);
%     cfg.trials = cfg.trials([1:ind-1 ind+1:end]);
% end
% GLA_meeg_data.data = ft_redefinetrial(cfg, GLA_meeg_data.data);
% 
% % Reject from the blink and behavioral data too
% GLA_meeg_data.blinks.trials = {GLA_meeg_data.blinks.trials{cfg.trials}}; %#ok<CCAT1>
% GLA_meeg_data.blinks.starts = {GLA_meeg_data.blinks.starts{cfg.trials}}; %#ok<CCAT1>
% GLA_meeg_data.blinks.stops = {GLA_meeg_data.blinks.stops{cfg.trials}}; %#ok<CCAT1>
% if ~isempty(GLA_meeg_data.behavioral.errors)
%     GLA_meeg_data.behavioral.errors = GLA_meeg_data.behavioral.errors(cfg.trials);
%     GLA_meeg_data.behavioral.outliers = GLA_meeg_data.behavioral.outliers(cfg.trials);
%     GLA_meeg_data.behavioral.timeouts = GLA_meeg_data.behavioral.timeouts(cfg.trials);
% end


% 
% 
% function rej = findChannelRejections(pre)
% 
% % Check each one we did have
% global GLA_meeg_data;
% rej = {};
% for pre_ind = 1:length(pre)
% 
%     found = 0;
%     for post_ind = 1:length(GLA_meeg_data.label)
%         if strcmp(GLA_meeg_data.label{post_ind},pre{pre_ind})
%             found = 1;
%             break;
%         end
%     end
%     if ~found
%         rej{end+1} = pre{pre_ind}; 
%     end
% end
% 
