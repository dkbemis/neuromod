function NM_CreateCleanBehavioralData(rejections)

% Load the data
NM_LoadBehavioralData();

% Get suggested rejections if we're not given them
clear global GLA_clean_behavioral_data;
global GLA_clean_behavioral_data;
if ~exist('rejections','var')
    GLA_clean_behavioral_data.rejections = NM_SuggestRejections();
else
    GLA_clean_behavioral_data.rejections = rejections;
end

% Set the rejected data
% TODO: May need to clear full data for memory
global GLA_behavioral_data;
trials = 1:length(GLA_behavioral_data.data.cond);
for r = 1:length(GLA_clean_behavioral_data.rejections)
    r_ind = find(trials == GLA_clean_behavioral_data.rejections(r),1);
    if ~isempty(r_ind)
        trials = trials([1:r_ind-1 r_ind+1:end]);
    end
end

% And set all of data
data_fields = fieldnames(GLA_behavioral_data.data);
for d = 1:length(data_fields)

    % Only these are needed
    if sum(strcmp(data_fields{d},{'acc','rt','cond'})) > 0
        GLA_clean_behavioral_data.data.(data_fields{d}) = ...
                GLA_behavioral_data.data.(data_fields{d})(trials);
    end
end


