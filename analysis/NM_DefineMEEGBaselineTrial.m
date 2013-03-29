% Returns the definition of each trial in the data for later processing
% trl contains one row per trial and columns:
%   beginsample     endsample   offset
%
% For a trial with a 200 sample baseline that begins at sample 1000 and has
% 1000 samples after the trigger, the definition would be:
%   1000    2199    -200
%
% NOTE: To add extra outputs, set function [trl, event] = ... (I think)

function trl = NM_DefineMEEGBaselineTrial(cfg)

trl = [];
global GLA_subject_data;
global GLA_meeg_type;
b_types = fieldnames(GLA_subject_data.baseline);
for b = 1:length(b_types)
    if isempty(GLA_subject_data.baseline.(b_types{b}))
        continue;
    end
    for t = 1:length(GLA_subject_data.baseline.(b_types{b}))
        
        % If we've rejected it, don't add
        if isfield(GLA_subject_data.parameters, 'meg_rejections') &&...
                any(GLA_subject_data.parameters.meg_rejections==t)
            continue; 
        end

        % Add every event
        triggers = GLA_subject_data.baseline.(b_types{b})(t).([GLA_meeg_type '_triggers']);
        for i = 1:length(triggers)

            % Get the condition
            cond = mod(triggers(i).value, 128);

            % NOTE: Samples are 1-1 with ms for now.
            % Just get the critical trigger.
            trigger_time = triggers(i).([GLA_meeg_type '_time']);
            trl(end+1,:) = [trigger_time+GLA_subject_data.parameters.meeg_baseline...
                trigger_time+cfg.post_stim-1 GLA_subject_data.parameters.meeg_baseline cond]; %#ok<AGROW>
        end
    end
end

