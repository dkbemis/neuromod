function NM_ApplyMEEGRejections(rejections)

% Load the data
NM_LoadMEEGData();

% Get suggested rejections if we're not given them
clear global GLA_clean_meeg_data;
global GLA_clean_meeg_data;
if ~exist('rejections','var')
    GLA_clean_meeg_data.rejections = NM_SuggestRejections();
else
    GLA_clean_meeg_data.rejections = rejections;
end

% Set the rejected data
% TODO: May need to clear full data for memory
global GLA_meeg_data;
cfg = [];
cfg.trials = 1:length(GLA_meeg_data.data.trial);
for r = 1:length(GLA_clean_meeg_data.rejections)
    r_ind = find(cfg.trials == GLA_clean_meeg_data.rejections(r),1);
    if ~isempty(r_ind)
        cfg.trials = cfg.trials([1:r_ind-1 r_ind+1:end]);
    end
end
GLA_clean_meeg_data.data = ft_redefinetrial(cfg,GLA_meeg_data.data);


