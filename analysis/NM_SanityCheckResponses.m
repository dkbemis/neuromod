% Check for high accuracy and low time outs

function NM_SanityCheckResponses()

global GLA_subject;
disp(['Sanity checking responses for ' GLA_subject '...']);

% Make sure we're processed 
disp('Loading data...');
NM_LoadSubjectData({{'responses_preprocessed',1}});
disp('Done.');

% Check the localizer first
checkLocalizerResponses();

% Check the number of outliers and timeouts
% NOTE: There should be no timeouts for MEG data.
% TODO: Implement timeouts
filter.is_timeout = {1};
num_timeouts = length(NM_FilterTrials(filter));

% Get the outlier trials
filter.is_timeout = {0};
filter.is_response_outlier = {1};
num_outliers = length(NM_FilterTrials(filter));

% Get the summary for non-outlier trials
filter.is_response_outlier = {0};
[good_rts good_accs] = NM_SummarizeTrialSetResponses(NM_FilterTrials(filter)); 

% Plot the results
figure;
global GLA_subject_data;
num_good_trials = GLA_subject_data.parameters.num_trials - num_timeouts;
hist(good_rts,round(num_good_trials/10));
title(['Behavioral Sanity Check (' GLA_subject ')']);
ylabel('Num trials'); xlabel('msec');

% Add the info and save
pos = round(.75*axis);
text(pos(2),pos(4),['Accuracy: ' num2str(100*mean(good_accs)) '%']);
text(pos(2),pos(4)-3,['Outliers: ' num2str(100*num_outliers/num_good_trials) '%']);
text(pos(2),pos(4)-6,['Timeouts: ' num2str(100*num_timeouts/GLA_subject_data.parameters.num_trials) '%']);
saveas(gcf,[NM_GetCurrentDataDirectory() '/analysis/' GLA_subject '/' GLA_subject '_Behavioral_Sanity_Check.jpg'],'jpg');
NM_SaveSubjectData({{'response_sanity_check',1}});

function checkLocalizerResponses()

% Might be nothing to do
global GLA_subject_data;
if GLA_subject_data.parameters.num_localizer_blocks == 0
    return;
end

% Else, make sure we're right
r_times = [];
warn_time = 1.5;
for b = 1:GLA_subject_data.parameters.num_localizer_blocks
    if ~isempty(GLA_subject_data.localizer.blocks(b).params.catch_trial)
        if length(GLA_subject_data.localizer.blocks(b).params.catch_trial) < 3
            error('No localizer response found.');
        elseif GLA_subject_data.localizer.blocks(b).params.catch_trial{3} > warn_time
            disp(['WARNING: Localizer response ' num2str(length(r_times)+1) ' is pretty slow: ' ...
                num2str(1000*GLA_subject_data.localizer.blocks(b).params.catch_trial{3}) ' ms']);
        end
        r_times(end+1) = GLA_subject_data.localizer.blocks(b).params.catch_trial{3};
    end
end
disp(['Average localizer response time: ' num2str(1000*mean(r_times)) ' ms.']);


