% Neuromag has some weird labeling...

function type = NM_GetMEGChannelType(ch_name)

% Load the mapping
%   A variable meg_channel_types with cells
%       * type 
%       * ch_names
load('meg_channel_types.mat');
for ch = 1:length(meg_channel_types)
    ch_type = meg_channel_types{ch}{1};
    ch_names = meg_channel_types{ch}{2};
    for n = 1:length(ch_names)
        if strcmp(ch_names{n},ch_name)
            type = ch_type;
            return;
        end
    end
end

% Signal no type
type = 'Unknown';
