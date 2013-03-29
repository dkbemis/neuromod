% Give a quick analysis of a single subject's responses
%
% For now, just prints a graph of the errors and rt for each condition,
%   separated by structure type

function NM_BasicAnalysis()

% Check out some basic measures
NM_AnalyzeConditionMeasures('rt',NM_ExtractConditionMeasures('rt'));

types = {'meg','eeg'};
intervals = {[-100 0], [100 200], [300 500]};
for t = 1:length(types)
    for i = 1:length(intervals)
        measures = NM_ExtractConditionMeasures(types{t},intervals{i});
        if ~isempty(measures)
            NM_AnalyzeConditionMeasures([types{t} '_' num2str(intervals{i}(1)) '_'...
                num2str(intervals{i}(2))],measures);
        end          
    end
end

% And the eye tracking
measures = NM_ExtractConditionMeasures('pupil');
if ~isempty(measures)
    NM_AnalyzeConditionMeasures('pupil',measures);
end

