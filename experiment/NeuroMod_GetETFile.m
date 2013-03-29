% Helper until the crashing is fixed
%
% NOTE: This has to be run repeatedly until it finally works

function NeuroMod_GetETFile(et_file_name)

% Add the extension
et_file_name = [et_file_name '.edf'];

% Grab it
disp(['Retrieving eyetracker file ' et_file_name '...']);

% First close the eyetracker
Eyelink('ShutDown');
pause(1);

% Then open it...
Eyelink('Initialize','PsychEyelinkDispatchCallback');

% And get the file
status = Eyelink('ReceiveFile', et_file_name, et_file_name);
disp(['Got status ' num2str(status) ' for command for receive file.']);
if status < 0
    error('Eyetracker file not received.');
end
if ~exist(et_file_name, 'file')
    error('Eyetracker file not found.');
end

% And done
PTBCloseEyeTracker;
