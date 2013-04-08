

function NM_InitializeSubjectAnalysis()

global GLA_subject;
disp(['Initializing analysis for ' GLA_subject '...']);

% See if we already have it
save_file = [NM_GetCurrentDataDirectory() '/analysis/' GLA_subject '/' ...
    GLA_subject '_subject_data.mat'];
if exist(save_file,'file')
    load(save_file); 
end


% Set the default parameters
subject_data.parameters.localizer_catches = {'cliquez','2','1','appuyez','7','2'};
subject_data.parameters.num_critical_stim = 5;
subject_data.parameters.num_conditions = 5; % NOTE: Means within each structure type
subject_data.parameters.num_structure_types = 2;
subject_data.parameters.num_critical_stim = 5;
subject_data.parameters.num_phrase_types = 2;   % Noun / list
subject_data.parameters.num_a_pos = 2;  % Adjectives before and after nouns
subject_data.parameters.num_nomatch_types = 2;
subject_data.parameters.num_all_stim = 13;  % Including crosses, etc... 
subject_data.parameters.num_localizer_block_stims = 3;
subject_data.parameters.num_localizer_stim_words = 12;
subject_data.parameters.num_localizer_catch_trials = 2;
subject_data.parameters.localizer_response_key = 'r';
subject_data.parameters.num_blinks = 15;
subject_data.parameters.blinks_trigger = 2;
subject_data.parameters.num_mouth_movements = 0;
subject_data.parameters.mouth_movements_trigger = 5;
subject_data.parameters.num_breaths = 0;    
subject_data.parameters.breaths_trigger = 6;
subject_data.parameters.noise_trigger = 1;
subject_data.parameters.num_eye_movements = 10;
subject_data.parameters.eye_tracker = 1;
subject_data.parameters.eye_movements_triggers = [3 4];

% fMRI acquisition settings
subject_data.parameters.fmri_num_slices = 80;
subject_data.parameters.fmri_tr = 1.5;
subject_data.parameters.fmri_ta = subject_data.parameters.fmri_tr* ...
    (1-1/subject_data.parameters.fmri_num_slices);
subject_data.parameters.fmri_slice_order = ...
    1:subject_data.parameters.fmri_num_slices;
subject_data.parameters.fmri_ref_slice = 1;
subject_data.parameters.fmri_voxel_size = [1.5 1.5 1.5];

% Epoch settings
subject_data.parameters.blinks_epoch = [-200 600];
subject_data.parameters.left_eye_movements_epoch = [-200 600];
subject_data.parameters.right_eye_movements_epoch = [-200 600];
subject_data.parameters.word_5_epoch = [-200 600];
subject_data.parameters.word_4_epoch = [-200 600];
subject_data.parameters.word_3_epoch = [-200 600];
subject_data.parameters.word_2_epoch = [-200 600];
subject_data.parameters.word_1_epoch = [-200 600];
subject_data.parameters.target_epoch = [-200 1000];
subject_data.parameters.delay_epoch = [-200 2000];
subject_data.parameters.all_epoch = [-200 6000];

% Behavioral analysis settings
subject_data.parameters.min_resp_time = 200;  % Fastest response to keep
subject_data.parameters.max_resp_time = 2500;  % Slowest response to keep

% MEEG analysis settings
subject_data.parameters.meeg_rej_type = 'summary';  % summary, raw
subject_data.parameters.meeg_decomp_method = 'pca'; % pca, fastica, runica
subject_data.parameters.meeg_decomp_comp_num = 10; 
subject_data.parameters.meeg_decomp_type = 'combined';  % combined, separate (wrt decomposing)
subject_data.parameters.meeg_decomp_baseline_correct = 'no';  % Should we baseline correct before decomposing
subject_data.parameters.meeg_filter_raw = 1;    % 1 - will filter the raw data
subject_data.parameters.meeg_hpf = .1;  % .1
subject_data.parameters.meeg_lpf = 120; % 120
subject_data.parameters.meeg_bsf = [50 100];    % [50 100]
subject_data.parameters.meeg_bsf_width = 1;


% These can change 
global GLA_rec_type;
switch GLA_rec_type
    case 'meeg'
        subject_data.parameters.num_trials = 400;
        subject_data.parameters.num_runs = 5;
        subject_data.parameters.num_localizer_blocks = 0;
        subject_data.parameters.eeg = 1;
        subject_data.parameters.meg = 1;
        subject_data.parameters.num_noise = 1;
        
    case 'fmri'
        subject_data.parameters.num_trials = 320;
        subject_data.parameters.num_runs = 4;
        subject_data.parameters.num_localizer_blocks = 16;
        subject_data.parameters.eeg = 0;
        subject_data.parameters.meg = 0;
        subject_data.parameters.num_noise = 0;

    otherwise
        error('Unknown case');
end


% Subject specific
subject_data = addSubjectParameters(subject_data); %#ok<NASGU>


% And save
if ~exist([NM_GetCurrentDataDirectory() '/analysis/' GLA_subject],'dir')
    mkdir([NM_GetCurrentDataDirectory() '/analysis/', GLA_subject]); 
end
save(save_file,'subject_data');
disp(['Initialized ' GLA_subject ' for analysis.']);


function subject_data = addSubjectParameters(subject_data)

% Load the subject notes file and parse
global GLA_rec_type;
fid = fopen([GLA_rec_type '_subject_notes.txt']);

% Go through and look for the subject
global GLA_subject;
in_subject = 0;
while 1
    line = fgetl(fid);
    if ~ischar(line)
        break;
    end
    [label rest] = strtok(line);

    % Flag when we find it
    if strcmp(label,'subject') 
        if strcmp(GLA_subject,strtok(rest))
            in_subject = 1;
        else
            
            % If we've found it, then we're done
            if in_subject
                fclose(fid);
                return;
            end
        end
        continue;
    end
    
    % And parse if we need to
    if in_subject
        
        % # Marks a comment
        if ~isempty(line) && ~strcmp(line(1),'#')
            
            % These are intended to be:
            %   1 - parameter name
            %   2 - parameter type
            %   3 - parameter value
            C = textscan(line,'%s%s%s');
            val = C{3}{1};
            switch C{2}{1}
                case 'number'
                    val = str2double(val);
                    
                case 'string'
                    % Nothing to do here

                case 'cell'
                    val = parseCellParameter(line);
                    
                otherwise 
                    error('Unknown parameter type');
                    
            end
            
            % And set the value
            subject_data.parameters.(C{1}{1}) = val;
        end
    end
end
fclose(fid);

% If we got here and we're not in the last subject,
%   then the subject is not in the file yet
if ~in_subject
    error('Subject not found.');
end

function val = parseCellParameter(line)

% Comma delimited 3rd argument
% First two are just the labels parsed above
val = {};
[label rest] = strtok(line); [label rest] = strtok(rest); %#ok<ASGLU>
while ~isempty(rest)
    [val{end+1} rest] = strtok(rest); %#ok<AGROW,STTOK>
end




