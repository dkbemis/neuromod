function NM_CreateCleanMEEGData(cfg)

% Load the unclean data
NM_LoadMEEGData();

% Default if no input
if ~exist('cfg','var')
    cfg = [];
end

% Get suggested rejections if we're not given them
clear global GLA_clean_meeg_data;
global GLA_clean_meeg_data;
if isfield(cfg,'rejections')
    GLA_clean_meeg_data.rejections = cfg.rejections;
else
    GLA_clean_meeg_data.rejections = NM_SuggestRejections();
end

% Set the rejected data
% TODO: May need to clear full data for memory
global GLA_meeg_data;
rej_cfg = [];
rej_cfg.trials = 1:length(GLA_meeg_data.data.trial);
for r = 1:length(GLA_clean_meeg_data.rejections)
    r_ind = find(rej_cfg.trials == GLA_clean_meeg_data.rejections(r),1);
    if ~isempty(r_ind)
        rej_cfg.trials = rej_cfg.trials([1:r_ind-1 r_ind+1:end]);
    end
end
GLA_clean_meeg_data.data = ft_redefinetrial(rej_cfg,GLA_meeg_data.data);

% Rereference maybe
global GLA_meeg_type;
if strcmp(GLA_meeg_type,'eeg')
    if isfield(cfg,'rereference')
        if cfg.rereference
            GLA_clean_meeg_data.data = NM_RereferenceEEGData(GLA_clean_meeg_data.data);
        end
    else
        while 1
            ch = input('Rereference data (y/n)? ','s');
            if strcmp(ch,'y')
                GLA_clean_meeg_data.data = NM_RereferenceEEGData(GLA_clean_meeg_data.data);
                break;
            elseif strcmp(ch,'n')
                break;
            end
        end
    end
end

% Baseline correct it
if isfield(cfg,'baseline_correct')
    if cfg.baseline_correct
        GLA_clean_meeg_data.data = NM_BaselineCorrectMEEGData(GLA_clean_meeg_data.data);
    end
    
% Or ask
else
    while 1
        ch = input('Baseline correct data (y/n)? ','s');
        if strcmp(ch,'y')
            GLA_clean_meeg_data.data = NM_BaselineCorrectMEEGData(GLA_clean_meeg_data.data);
            break;
        elseif strcmp(ch,'n')
            break;
        end
    end
end


