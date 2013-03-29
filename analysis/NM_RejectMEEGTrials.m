function NM_RejectMEEGTrials()

global GLA_subject_data;
global GLA_meeg_type;
global GLA_meeg_trial_type;

% Load up the data
NM_LoadMEEGData();

% Make sure we haven't rejected already, because that breaks everything
if isfield(GLA_subject_data.parameters,[GLA_meeg_type '_' GLA_meeg_trial_type '_rejected']) &&...
        GLA_subject_data.parameters.([GLA_meeg_type '_' GLA_meeg_trial_type '_rejected']) == 1

    while 1
        ch = input('Already rejected. Reepoch and re-reject? (y/n) ','s');
        if strcmp(ch,'n')
            return;
        elseif strcmp(ch,'y')
            break;
        end
    end
    NM_ClearMEEGData();
    NM_FilterMEEGData();
end

% Use whichever type we set
switch GLA_subject_data.parameters.meeg_rej_type
    case 'raw'
        rejectArtifacts_Raw();
        
    case 'summary'
        rejectArtifacts_Summary();        
        
    otherwise
        error('Unknown type');
end

% Add the behavioral rejections
rejectBehavioral();

% Give a chance to reject the blinks
rejectBlinks();

% Apply the rejections
applyRejections();


% And save 
NM_SaveSubjectData({{[GLA_meeg_type '_' GLA_meeg_trial_type '_rejected'],1}});
NM_SaveMEEGData();


function rejectBlinks()

rej = [];
global GLA_meeg_data;
global GLA_meeg_trial_type;
for t = 1:length(GLA_meeg_data.blinks.trials)
    has_blink = ~isempty(GLA_meeg_data.blinks.starts{t}) ||...
        ~isempty(GLA_meeg_data.blinks.stops{t});
    
    % Want to keep only blinks for blinks trials
    if (strcmp(GLA_meeg_trial_type,'blinks') && ~has_blink) ||...
            (~strcmp(GLA_meeg_trial_type,'blinks') && has_blink)
        rej(end+1) = t; %#ok<AGROW>
    end
end
if strcmp(GLA_meeg_trial_type,'blinks')
    type = 'No blink';
else
    type = 'Blink';
end
suggestRejections(type,rej);


function rejectBehavioral()

rej = [];
global GLA_meeg_data;
for t = 1:length(GLA_meeg_data.behavioral.errors)
    if GLA_meeg_data.behavioral.errors(t) || GLA_meeg_data.behavioral.outliers(t) ||...
            GLA_meeg_data.behavioral.timeouts(t)
        rej(end+1) = t; %#ok<AGROW>
    end
end
suggestRejections('Behavioral',rej);



function suggestRejections(type, rej)

% Might not have any
if isempty(rej)
    disp(['No ' type ' rejections to suggest.']);
    return;
end

% See if we're first
global GLA_subject_data
global GLA_meeg_trial_type;
global GLA_meeg_type;
if ~isfield(GLA_subject_data.parameters,[GLA_meeg_type '_' ...
        GLA_meeg_trial_type '_rejections'])
    GLA_subject_data.parameters.([GLA_meeg_type '_' ...
        GLA_meeg_trial_type '_rejections']) = [];
end

% Check
rej_str = [type ' rejections (' num2str(length(rej)) '): '];
for r = 1:length(rej)
    rej_str = [rej_str num2str(rej(r)) ' '];  %#ok<AGROW>
end
disp(rej_str);
while 1
    rej_ch = input('Reject? (y/n): ','s');
    if strcmp(rej_ch,'y')
        GLA_subject_data.parameters.([GLA_meeg_type '_' ...
                GLA_meeg_trial_type '_rejections'])(end+1:end+length(rej)) = rej;
        break;
    elseif strcmp(rej_ch,'n')
        break;
    end
end


function applyRejections()

global GLA_subject_data;
global GLA_meeg_data;

% Reduce and set
global GLA_meeg_type;
global GLA_meeg_trial_type;
GLA_meeg_data.rejections = ...
    sort(unique(GLA_subject_data.parameters.([GLA_meeg_type '_' ...
                GLA_meeg_trial_type '_rejections'])));
cfg = [];
cfg.trials = 1:length(GLA_meeg_data.data.trial);
for r = 1:length(GLA_meeg_data.rejections)
    ind = find(cfg.trials == GLA_meeg_data.rejections(r),1);
    cfg.trials = cfg.trials([1:ind-1 ind+1:end]);
end
GLA_meeg_data.data = ft_redefinetrial(cfg, GLA_meeg_data.data);

% Reject from the blink and behavioral data too
GLA_meeg_data.blinks.trials = {GLA_meeg_data.blinks.trials{cfg.trials}}; %#ok<CCAT1>
GLA_meeg_data.blinks.starts = {GLA_meeg_data.blinks.starts{cfg.trials}}; %#ok<CCAT1>
GLA_meeg_data.blinks.stops = {GLA_meeg_data.blinks.stops{cfg.trials}}; %#ok<CCAT1>
if ~isempty(GLA_meeg_data.behavioral.errors)
    GLA_meeg_data.behavioral.errors = GLA_meeg_data.behavioral.errors(cfg.trials);
    GLA_meeg_data.behavioral.outliers = GLA_meeg_data.behavioral.outliers(cfg.trials);
    GLA_meeg_data.behavioral.timeouts = GLA_meeg_data.behavioral.timeouts(cfg.trials);
end


function rejectArtifacts_Raw()

% Artifact rejection
global GLA_meeg_data;
cfg = [];
cfg.channel = GLA_meeg_data.channel;
cfg.magscale = 10;
cfg = ft_databrowser(cfg,GLA_meeg_data.data);

% Now, record
recordRejections(cfg.artfctdef.visual.artifact);


function recordRejections(rejections)

global GLA_meeg_data;
global GLA_subject_data;
global GLA_meeg_trial_type;
global GLA_meeg_type;
if ~isfield(GLA_subject_data.parameters,[GLA_meeg_type '_' ...
        GLA_meeg_trial_type '_rejections'])
    GLA_subject_data.parameters.([GLA_meeg_type '_' ...
        GLA_meeg_trial_type '_rejections']) = [];
end

% Create sample data, if not there
% NOTE: It gets deleted when we append runs
if ~isfield(GLA_meeg_data.data, 'sampleinfo')
    
    % Set to be contiguous
    t_len = GLA_meeg_data.post_stim - GLA_meeg_data.pre_stim;
    sampleinfo(:,1) = 1:t_len:length(GLA_meeg_data.data.trial)*t_len;
    sampleinfo(:,2) = t_len:t_len:length(GLA_meeg_data.data.trial)*t_len;
else
    sampleinfo = GLA_meeg_data.data.sampleinfo;
end

% We're going to hope they always treat these as continuous
for r = 1:length(rejections)
    
    % Make sure all is as it's supposed to be
    rej_beg = find(sampleinfo(:,2) >= rejections(r,1),1);
    rej_end = find(sampleinfo(:,2) >= rejections(r,2),1);
    if rej_beg ~= rej_end
        error('Rejection not as expected.');
    end
    GLA_subject_data.parameters.([GLA_meeg_type '_' ...
        GLA_meeg_trial_type '_rejections'])(end+1) = rej_beg;
end


function rejectArtifacts_Summary()

global GLA_meeg_data;
cfg = [];
cfg.channel = GLA_meeg_data.channel;
cfg.magscale = 10;
cfg.method = 'summary';   % 'tral', 'channel', 'summary'
tmp_data = ft_rejectvisual(cfg,GLA_meeg_data.data);
recordRejections(tmp_data.cfg.artifact);

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
