% This gets the data from the acquisition computer and runs the maxfilter
%   on it so that it is useable

function NM_ImportfMRIData()

% Keep these separate for now
global GLA_rec_type;
if ~strcmp(GLA_rec_type,'fmri')
    return;
end

% Make sure we're initialized
NM_LoadSubjectData({});

% Get the directory
acq_dir = findAcqDir();

% Unfortunately, have to manually run from the command line
global GLA_subject;

% Just write to whereever we are in matlab
fid = setupImport();

% Need to copy using the conversion script
global GLA_subject_data;
importScan(acq_dir, GLA_subject_data.parameters.anat_scan, 'anat', 'experiment', fid);
for r = 1:GLA_subject_data.parameters.num_runs
    importScan(acq_dir, GLA_subject_data.parameters.run_scans{r}, ...
        ['run_' num2str(r)], 'experiment', fid);
end

% And the localizer
importScan(acq_dir, GLA_subject_data.parameters.anat_scan, 'anat', 'localizer', fid);
importScan(acq_dir, GLA_subject_data.parameters.loc_scan, 'loc', 'localizer', fid);
fclose('all');

% Now, wait for confirmation of running
resp = input('Please run the script and then hit enter if ok. Otherwise, type n: ','s');
if strcmp(resp,'n')
    error('Not ok.');
end
NM_SaveSubjectData({{'fmri_data_imported',1}});
disp(['Imported fmri data for ' GLA_subject '.']);

function fid = setupImport()

% Make the folders, otherwise the copy will be in the wrong place
global GLA_subject;
data_folder = [NM_GetCurrentDataDirectory() '/fmri_data/' GLA_subject];
[success message message_id] = mkdir(data_folder); %#ok<NASGU,ASGLU>
[success message message_id] = mkdir([data_folder '/localizer']); %#ok<NASGU,ASGLU>
[success message message_id] = mkdir([data_folder '/experiment']); %#ok<NASGU,ASGLU>


% Start the conversion script
fid = fopen([data_folder '/dcm2nii_script.sh'],'w');
fprintf(fid,'#! /bin/bash\n');
fprintf(fid,['# Conversion of dcm files to nii for ' GLA_subject '.\n\n']);


function importScan(acq_dir, scan_num, label, run_type, fid)

% Get the folder
global GLA_subject;
scan_dir = getScanDir(acq_dir, scan_num);
dest_dir = [NM_GetCurrentDataDirectory() ...
    '/fmri_data/' GLA_subject '/' run_type];


% Copy 
disp(['Copying run ' scan_num '...']);
cp_cmd = ['cp -r ' acq_dir '/' scan_dir ' ' dest_dir];
system(cp_cmd);
disp('Done.');


% Can't get this to work from matlab, so we'll have to write out a bash
% file and run it...

% The conversion command
fprintf(fid, ['dcm2nii -g n -d n -e n -p n ' dest_dir '/' scan_dir '\n']);

% The move / rename command
fprintf(fid, ['mv ' dest_dir '/' scan_dir '/*nii ' ...
    dest_dir '/' GLA_subject '_' label '.nii\n']);

% And the delete command
fprintf(fid, ['rm -r ' dest_dir '/' scan_dir '\n']);





function scan_dir = getScanDir(acq_dir, scan_num)

% Not dealing with more scans yet. Have to add some zeros...
if str2double(scan_num) > 9
    error('Unimplemented.');
end
scan_dir = '';
folders = dir(acq_dir);
for f = 1:length(folders)
    if ~isempty(strfind(folders(f).name,['00000' scan_num]))
        scan_dir = folders(f).name;
    end
end
if isempty(scan_dir)
    error('Scan not found.');
end



function acq_dir = findAcqDir()

% Look for the data first
fmri_acq_dir = '/neurospin/acquisition/database/TrioTim';

% Get the date from the parameters
global GLA_subject_data;
acq_dir = [fmri_acq_dir '/' GLA_subject_data.parameters.rec_date];

% Fr now, assume there's only one
% Also, assume the directory is always named with the underscore between
% the letters and the number.
if ~exist(acq_dir,'dir')
    error('Folder not found.');
end

global GLA_subject;
subj_folder = [];
folders = dir(acq_dir);
for f = 1:length(folders)
    if ~isempty(strfind(folders(f).name, GLA_subject))
        subj_folder = folders(f).name;
    end
end
if isempty(subj_folder)
    error('Folder not found.');
end
acq_dir = [acq_dir '/' subj_folder];



