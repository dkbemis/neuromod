% Wrapper for extracting data summaries
function measures = NM_ExtractConditionMeasures(type, nargin)

global GLA_subject;
disp(['Extractin ' type ' for ' GLA_subject '...']);
switch type
    case 'rt'
        measures = NM_ExtractBehavioralConditionMeasures(type);
        
    case 'meg'
        measures = NM_ExtractMEEGConditionMeasures(type, nargin(1:2));
        
    case 'eeg'
        measures = NM_ExtractMEEGConditionMeasures(type, nargin(1:2));
        
    case 'pupil'
        measures = NM_ExtractETConditionMeasures(type);
        
    otherwise
        error('Unknown measure.');
end
disp('Done.');
