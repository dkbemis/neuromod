% Check for high accuracy and low time outs

function NM_SanityCheckResponses()

global GLA_subject;
disp(['Sanity checking responses for ' GLA_subject '...']);

% Make sure we're processed 
disp('Loading data...');
NM_LoadSubjectData({{'behavioral_data_preprocessed',1}});
disp('Done.');

% Load the data
NM_LoadBehavioralData();

% Check the number of outliers and timeouts
global GLA_behavioral_data;
good_rts = []; good_accs = [];
for t = 1:length(GLA_behavioral_data.data.cond)
    if isempty(find(GLA_behavioral_data.data.outliers == t,1)) && ...
            isempty(find(GLA_behavioral_data.data.timeouts == t,1))
        good_rts(end+1) = GLA_behavioral_data.data.rt{t}; %#ok<AGROW>
        good_accs(end+1) = GLA_behavioral_data.data.acc{t}; %#ok<AGROW>
    end
end

% Plot the results
figure;
global GLA_subject_data;
hist(good_rts,round(length(good_rts)/10));
title(['Behavioral Sanity Check (' GLA_subject ')']);
ylabel('Num trials'); xlabel('msec');

% Add the info and save
pos = round(.75*axis);
text(pos(2),pos(4),['Accuracy: ' num2str(100*mean(good_accs)) '%']);
text(pos(2),pos(4)-3,['Outliers: ' num2str(100*length(GLA_behavioral_data.data.outliers) / ...
    (length(GLA_behavioral_data.data.cond) - length(GLA_behavioral_data.data.timeouts))) '%']);
text(pos(2),pos(4)-6,['Timeouts: ' num2str(100*length(GLA_behavioral_data.data.timeouts) / ...
    GLA_subject_data.parameters.num_trials) '%']);
saveas(gcf,[NM_GetCurrentDataDirectory() '/analysis/' GLA_subject ...
    '/' GLA_subject '_Behavioral_Sanity_Check.jpg'],'jpg');


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


