function rejections = NM_SuggestRejections()

% First check if we have some saved to use
global GLA_subject;
global GLA_trial_type;
rej_file_name = [NM_GetCurrentDataDirectory() '/analysis/' GLA_subject ...
    '/' GLA_subject '_' GLA_trial_type '_rejections.mat'];
if exist(rej_file_name,'file')
    while 1
        ch = input(['Use saved rejections for ' GLA_trial_type ' (y/n)? '],'s');
        if strcmp(ch,'y')
            load(rej_file_name);
            return;
        elseif strcmp(ch,'n')
            break;
        end
    end

end

% If not, search for any we might have set
rejections = [];
r_types = {'behavioral','et','meg','eeg'};
for r = 1:length(r_types)
    rejections = getDataRejections(r_types{r}, rejections);
end
rejections = sort(unique(rejections));

% And save for later
save(rej_file_name,'rejections');


function rej_to_use = getDataRejections(r_type, rej_to_use)

% Load the rejections, if we have them
global GLA_meeg_type;
switch r_type
    case 'behavioral'
        if ~exist(NM_GetCurrentBehavioralDataFilename(),'file')
            return;
        end
        load(NM_GetCurrentBehavioralDataFilename(),'rejections');

    case 'et'
        if ~exist(NM_GetCurrentETDataFilename(),'file')
            return;
        end
        load(NM_GetCurrentETDataFilename(),'rejections');

    case 'meg'
        curr_meeg_type = GLA_meeg_type;
        GLA_meeg_type = 'meg'; %#ok<NASGU>
        if ~exist(NM_GetCurrentMEEGDataFilename(),'file')
            GLA_meeg_type = curr_meeg_type;
            return;
        end
        load(NM_GetCurrentMEEGDataFilename(),'rejections');
        GLA_meeg_type = curr_meeg_type;
        
    case 'eeg'
        curr_meeg_type = GLA_meeg_type;
        GLA_meeg_type = 'eeg'; %#ok<NASGU>
        if ~exist(NM_GetCurrentMEEGDataFilename(),'file')
            GLA_meeg_type = curr_meeg_type;
            return;
        end
        load(NM_GetCurrentMEEGDataFilename(),'rejections');
        GLA_meeg_type = curr_meeg_type;

    otherwise
        error('Unknown rejection type.');
        
end

% May have none
if ~exist('rejections','var')
    return;
    
end

% And suggest each type
disp(['Suggesting ' r_type ' rejections...']);
for r = 1:length(rejections)
    rej_to_use = suggestRejections(rejections(r), rej_to_use);
end
disp('Done.');


function rej_to_use = suggestRejections(rejections, rej_to_use)

% Might be nothing to do
if isempty(rejections.trials)
    return;
end

% Otherwise see if we want them
rej_str = ['Apply ' rejections.type ' rejections [('...
    num2str(length(rejections.trials)) ') -'];
for t = 1:length(rejections.trials)
    rej_str = [rej_str ' ' num2str(rejections.trials(t))];  %#ok<AGROW>
end
rej_str = [rej_str ']? (y/n): '];
while 1
    ch = input(rej_str,'s');
    if strcmp(ch,'y')
        rej_to_use(end+1:end+length(rejections.trials)) = rejections.trials;
        return;
    elseif strcmp(ch,'n')
        return;
    end
end


