
function NM_FilterMEEGData()

% If we're filtering the raw data, then clear and load
global GLA_subject_data;
NM_LoadSubjectData({});
if GLA_subject_data.parameters.meeg_filter_raw
    NM_ClearMEEGData();
    NM_LoadMEEGData();
    return;
end

% Otherwise, load and go
NM_LoadMEEGData();
   
% Set the parameters
global GLA_meeg_data;
GLA_meeg_data.filter_raw = GLA_subject_data.parameters.meeg_filter_raw;
GLA_meeg_data.hpf = GLA_subject_data.parameters.meeg_hpf;
GLA_meeg_data.lpf = GLA_subject_data.parameters.meeg_lpf;
GLA_meeg_data.bsf = GLA_subject_data.parameters.meeg_bsf;
GLA_meeg_data.bsf_width = GLA_subject_data.parameters.meeg_bsf_width;

% High pass...
if ~isempty(GLA_meeg_data.hpf)
    disp(['Applying high pass filter: ' num2str(GLA_meeg_data.hpf) 'Hz...']);
    cfg = []; 
    cfg.hpfilter = 'yes';
    cfg.hpfreq = GLA_meeg_data.hpf;
    if GLA_meeg_data.hpf < 1
        cfg.hpfilttype = 'fir'; % Necessary to not crash
    end
    GLA_meeg_data.data = ft_preprocessing(cfg, GLA_meeg_data.data);
    disp('Done.');
end

% Low pass...
if ~isempty(GLA_meeg_data.lpf)
    disp(['Applying low pass filter: ' num2str(GLA_meeg_data.lpf) 'Hz...']);
    cfg = []; 
    cfg.lpfilter = 'yes';
    cfg.lpfreq = GLA_meeg_data.lpf;
    GLA_meeg_data.data = ft_preprocessing(cfg, GLA_meeg_data.data);
    disp('Done.');
end

% Notches...
for f = 1:length(GLA_meeg_data.bsf)
    disp(['Applying band stop filter: ' num2str(GLA_meeg_data.bsf(f)) 'Hz...']);
    cfg = [];
    cfg.bsfilter = 'yes';
    cfg.bsfreq = [GLA_meeg_data.bsf(f)-GLA_meeg_data.bsf_width ...
        GLA_meeg_data.bsf(f)+GLA_meeg_data.bsf_width];
    GLA_meeg_data.data = ft_preprocessing(cfg, GLA_meeg_data.data);
    disp('Done.');
end

% And save
NM_SaveMEEGData();



