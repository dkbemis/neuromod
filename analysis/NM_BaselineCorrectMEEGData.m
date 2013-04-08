function data = NM_BaselineCorrectMEEGData(data, should_save)

% Make sure we really mean it (i.e. can't just leave it out
%   to set
global GLA_meeg_data;
set_data = 0;
if isempty(data)
    NM_LoadMEEGData();
    data = GLA_meeg_data.data;
    set_data = 1;
end

disp('Baseline correcting data...');
for t = 1:length(data.trial)
    data.trial{t} = ft_preproc_baselinecorrect(...
        data.trial{t},1,find(data.time{1} >0,1));
end
disp('Done.');

if set_data
    GLA_meeg_data.data = data; 
end

% Default not to save
if ~exist('should_save','var') || ~should_save
    NM_SaveMEEGData(); 
end
