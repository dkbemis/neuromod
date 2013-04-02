% Helper to load the subject data 
%   or create it if not initialized
% This will be stored in NIP_subject_data.mat
%   in data_dir/analysis/subject/
%
% Will assign the loaded data to GLA_subject_data
%
% Inputs:
%   * params: A set of parameter / value pairs that will be
%       checked and added if necessary / possible

function NM_LoadSubjectData(params)

% First, make sure it exists
getSubjectData();

% Then check the params
if ~exist('params','var') || isempty(params)
    return;
end

for p = 1:length(params)
    checkSubjectData(params{p}{1}, params{p}{2});
end


function checkSubjectData(param, val)

global GLA_subject;
global GLA_subject_data;
global GLA_fmri_type;
if ~isfield(GLA_subject_data.parameters,param) || ...
        (ischar(val) && ~strcmp(GLA_subject_data.parameters.(param),val)) ||...
        (isnumeric(val) && GLA_subject_data.parameters.(param) ~= val)
    
    % Might know how to add it
    switch param
        case 'log_parsed'
            NM_ParseLogFile();    
            
        case 'log_checked'
            NM_CheckLogFile();    
            
        case 'et_data_converted'
            NM_ConvertETData();    
            
        case 'responses_preprocessed'
            NM_PreprocessResponses();
            
        case 'et_triggers_checked'
            NM_CheckETTriggers();
            
        case 'meg_data_preprocessed'
            NM_PreprocessMEEGData('meg');
            
        case 'eeg_data_preprocessed'
            NM_PreprocessMEEGData('eeg');
            
        case 'et_data_preprocessed'
            NM_PreprocessETData();
            
        case 'eeg_triggers_checked'
            NM_CheckEEGTriggers();
            
        case 'meg_triggers_checked'
            NM_CheckMEGTriggers();
            
        case 'fmri_localizer_data_preprocessed'
            old_type = GLA_fmri_type;
            GLA_fmri_type = 'localizer'; %#ok<NASGU>
            NM_PreprocessfMRIData();
            GLA_fmri_type = old_type;
            
        case 'fmri_experiment_data_preprocessed'
            old_type = GLA_fmri_type;
            GLA_fmri_type = 'experiment'; %#ok<NASGU>
            NM_PreprocessfMRIData();
            GLA_fmri_type = old_type;
            
        otherwise
            checkForContinue(param, val);
    end

    % And reset
    load([NM_GetCurrentDataDirectory() '/analysis/' ...
       GLA_subject '/' GLA_subject '_subject_data.mat']);
    GLA_subject_data = subject_data;
end


function checkForContinue(param, val)

% see if we want to go anyway
disp(['Parameter ' param ' not equal to ' num2str(val) '.']);
r = input('Set and continue? (y/n) ','s');
if strcmp(r,'y')
    NM_SaveSubjectData({{param, val}});
else
    error('Parameter not as expected.'); 
end

function getSubjectData()

% See if it exists
global GLA_subject;
save_file = [NM_GetCurrentDataDirectory() '/analysis/' ...
    GLA_subject '/' GLA_subject '_subject_data.mat'];

% If not, 
if ~exist(save_file,'file')
    
    % Make the folder if it doesn't exist
    if ~exist([NM_GetCurrentDataDirectory() '/analysis/' GLA_subject], 'dir')
        mkdir([NM_GetCurrentDataDirectory() '/analysis/'],GLA_subject);
    end
    
    % And initialize the data
    NM_InitializeSubjectAnalysis();
end

% Set to use
global GLA_subject_data;
load(save_file);
GLA_subject_data = subject_data;



