% This gets the data from the acquisition computer and runs the maxfilter
%   on it so that it is useable

function NM_ImportMEGData()

% For now, separate these out...
global GLA_rec_type;
if ~strcmp(GLA_rec_type,'meg')
    return; 
end

% Make sure we're initialized
NM_LoadSubjectData({});

% Get the directory
acq_dir = findAcqDir();

% Need to copy over and run the max filter on each file
global GLA_subject;
global GLA_subject_data;
for r = 1:GLA_subject_data.parameters.num_runs
    importMEGRun([acq_dir '/' GLA_subject_data.parameters.meg_run_files{r} '.fif'],...
        [GLA_subject '_run_' num2str(r) '.fif']); 
end

% And the baseline
importMEGRun([acq_dir '/' GLA_subject_data.parameters.meg_basline_file '.fif'],...
    [GLA_subject '_baseline.fif']);

% And resave with the flag
NM_SaveSubjectData({{'meg_data_imported',1}});



function importMEGRun(src_file, dest_name)

% Copy
global GLA_subject;
disp(['Copying ' dest_name '...']);
dest_dir = [NM_GetCurrentDataDirectory() ...
    '/meg_data/' GLA_subject];
[succ m m_id] = mkdir(dest_dir); %#ok<NASGU,ASGLU>
dest_file = [dest_dir '/' dest_name];
cp_cmd = ['cp ' src_file ' ' dest_file];
system(cp_cmd);
disp('Done.');

% Maxfilter command
filt_file = [dest_file(1:end-4) '_sss.fif'];
disp(['Running maxfilter on ' dest_name '...']);
max_filter_origin = [0 0 40];
max_filter_badlimit = 4;
mf_cmd = ['maxfilter-2.2 -force -f ' dest_file ...
    ' -o ' filt_file ' -v -frame head -origin ' num2str(max_filter_origin(1)) ' '...
    num2str(max_filter_origin(2)) ' ' num2str(max_filter_origin(3)) ' '...
    ' -autobad on -badlimit ' num2str(max_filter_badlimit)];
system(mf_cmd);
disp('Done');

% Delete the other
disp(['Removing raw file: ' dest_name '...']);
rm_cmd = ['rm ' dest_file];
system(rm_cmd);

% And test
disp('Testing conversion...');
hdr = ft_read_header(filt_file);
if hdr.nChans ~= 354
    error('Unexpected header.');
end
disp('Done.');




function acq_dir = findAcqDir()

% Look for the data first
global GLA_subject;
meg_acq_dir = '/neurospin/acquisition/neuromag/data/simp_comp';

% FOr now, assume there's only one
% Also, assume the directory is always named with the underscore between
% the letters and the number.
acq_dir = [meg_acq_dir '/' GLA_subject(1:2) '_' GLA_subject(3:end)];
if ~exist(acq_dir,'dir')
    error('Folder not found.');
end
folders = ls(acq_dir);
if size(folders,1) ~= 1
    error('Wrong number of folders.');
end

% Has an odd trailing character...
acq_dir = [acq_dir '/' folders(1:end-1)];


