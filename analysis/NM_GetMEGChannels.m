function channels = NM_GetMEGChannels(data,s_type)

% Check the labels...
channels = {};
for ch = 1:length(data.label)
    if strcmp(NM_GetMEGChannelType(data.label{ch}),s_type)
        channels{end+1} = data.label{ch}; %#ok<AGROW>
    end
end

