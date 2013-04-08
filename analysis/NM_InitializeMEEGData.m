
function NM_InitializeMEEGData()

% Initialize the data
global GLA_subject;
global GLA_subject_data;
global GLA_meeg_type;
global GLA_trial_type;
disp(['Initializing ' GLA_meeg_type ' ' GLA_trial_type ' data...']);
NM_LoadSubjectData({{[GLA_meeg_type '_data_checked'],1},...     % Need the triggers
    {'log_checked',1},...
    {'timing_adjusted',1},...   % Make sure the triggers are in the right place
    });

% Reset
NM_ClearMEEGData();

% Then set the settings
global GLA_meeg_data;
GLA_meeg_data.settings.subject = GLA_subject;
GLA_meeg_data.settings.trial_type = GLA_trial_type;
GLA_meeg_data.settings.meeg_type = GLA_meeg_type;
GLA_meeg_data.settings.channel = upper(GLA_meeg_type);
GLA_meeg_data.data = {};

switch GLA_trial_type
    case 'blinks'
        setRunData('baseline');

    case 'left_eye_movements'
        setRunData('baseline');

    case 'right_eye_movements'
        setRunData('baseline');

    case 'word_5'        
        for r = 1:GLA_subject_data.parameters.num_runs
            setRunData(['run_' num2str(r)]);
        end
        
    otherwise
        error('Unknown type');
end

% And save
NM_SaveMEEGData();
disp('Done.');


function setRunData(run_id)

% Load up the data
global GLA_meeg_data;
global GL_tmp_data;
global GLA_subject;
global GLA_meeg_type;
cfg = [];
cfg.channel = GLA_meeg_data.settings.channel;
cfg.datafile = [NM_GetCurrentDataDirectory() '/' GLA_meeg_type '_data/' ...
    GLA_subject '/' GLA_subject '_' run_id];

% Set the suffix
switch GLA_meeg_type
    case 'meg'
        cfg.datafile = [cfg.datafile '_sss.fif'];

    case 'eeg'
        cfg.datafile = [cfg.datafile '.raw'];
        
    otherwise 
        error('Bad type');
end

% And load
GL_tmp_data = ft_preprocessing(cfg);

% Then epoch
epochData(run_id);

% And append
if isempty(GLA_meeg_data.data)
    GLA_meeg_data.data = GL_tmp_data;
else
    GLA_meeg_data.data = ft_appenddata([],GLA_meeg_data.data,GL_tmp_data);
end

% And clear the tmp 
clear global GL_tmp_data;


function epochData(run_id)

% Define the trials
disp('Epoching data...');
cfg = [];
cfg.trialfun = 'NM_DefineMEEGTrial';
cfg.run_id = run_id;

% Apply some filtering now, if filtering on raw data
% NOTE: This will have to cut the data some to let the hpf finish
global GLA_subject_data;
if GLA_subject_data.parameters.meeg_filter_raw
    cfg = filterData(cfg);
else
    cfg = ft_definetrial(cfg);
end

% And cut the data
global GL_tmp_data;
GL_tmp_data = ft_redefinetrial(cfg, GL_tmp_data);


function cfg = filterData(cfg)

global GL_tmp_data;
global GLA_subject_data;
global GLA_meeg_data;
global GLA_trial_type;
GLA_meeg_data.settings.filter_raw = GLA_subject_data.parameters.meeg_filter_raw;
GLA_meeg_data.settings.hpf = GLA_subject_data.parameters.meeg_hpf;
GLA_meeg_data.settings.lpf = GLA_subject_data.parameters.meeg_lpf;
GLA_meeg_data.settings.bsf = GLA_subject_data.parameters.meeg_bsf;
GLA_meeg_data.settings.bsf_width = GLA_subject_data.parameters.meeg_bsf_width;

% TODO: This should probably be dependent on the frequency of the hpf.
min_trial_length = 2000;
curr_trial_length = GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(2) -...
    GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(1);
if curr_trial_length < min_trial_length
    filter_buffer = round((min_trial_length - curr_trial_length)/2);
else
    filter_buffer = 0; 
end


% Have to cut it so that it'll finish, but wide enough to let the filter work.
% So, reset this and epoch (NOTE: These numbers are used in NM_DefineMEEGTrial...
GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(1) = ...
    GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(1) - filter_buffer;
GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(2) = ...
    GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(2) + filter_buffer;
cfg = ft_definetrial(cfg);
GL_tmp_data = ft_redefinetrial(cfg, GL_tmp_data);


% High pass...
if ~isempty(GLA_meeg_data.settings.hpf)
    disp(['Applying high pass filter: ' num2str(GLA_meeg_data.settings.hpf) 'Hz...']);
    cfg = []; 
    cfg.hpfilter = 'yes';   
    cfg.hpfreq = GLA_meeg_data.settings.hpf;
    if GLA_meeg_data.settings.hpf < 1
        cfg.hpfilttype = 'fir'; % Necessary to not crash
    end
    GL_tmp_data = ft_preprocessing(cfg, GL_tmp_data);
    disp('Done.');
end

% Low pass...
if ~isempty(GLA_meeg_data.settings.lpf)
    disp(['Applying low pass filter: ' num2str(GLA_meeg_data.settings.lpf) 'Hz...']);
    cfg = []; 
    cfg.lpfilter = 'yes';
    cfg.lpfreq = GLA_meeg_data.settings.lpf;
    GL_tmp_data = ft_preprocessing(cfg, GL_tmp_data);
    disp('Done.');
end

% Notches...
for f = 1:length(GLA_meeg_data.settings.bsf)
    disp(['Applying band stop filter: ' num2str(GLA_meeg_data.settings.bsf(f)) 'Hz...']);
    cfg = [];
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [GLA_meeg_data.settings.bsf(f)-GLA_meeg_data.settings.bsf_width ...
        GLA_meeg_data.settings.bsf(f)+GLA_meeg_data.settings.bsf_width];
    GL_tmp_data = ft_preprocessing(cfg, GL_tmp_data);
    disp('Done.');
end


% Reset these, and set to recut
GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(1) = ...
    GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(1) + filter_buffer;
GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(2) = ...
    GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(2) - filter_buffer;
cfg = [];
cfg.begsample = filter_buffer + 1;
cfg.endsample = filter_buffer + GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(2) +...
    - GLA_subject_data.parameters.([GLA_trial_type '_epoch'])(1);




