
% Summarize the responses from a set of trials
function [rts accs] = NM_SummarizeTrialSetResponses(trials)

rts = zeros(length(trials),1);
accs = zeros(length(trials),1);
for t = 1:length(trials)
    rts(t) = trials(t).response.rt; 
    accs(t) = trials(t).response.acc; 
end


