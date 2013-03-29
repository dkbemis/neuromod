% This will epoch the global meeg data. If none exists, then will load from
% disk.
%
% Will then save the epoched data to disk.
function NM_EpochMEEGData()

% Load the data
NM_LoadMEEGData();

% Define the trials
global GLA_meeg_data;
disp('Epoching data...');
cfg = [];
cfg.trialfun = 'NM_DefineMEEGTrial';
cfg.datafile = GLA_meeg_data.data_file;
cfg = ft_definetrial(cfg);

% And epoch the data
GLA_meeg_data.data = ft_redefinetrial(cfg, GLA_meeg_data.data);
GLA_meeg_data.epoched = 1;

% And save 
NM_SaveMEEGData();

