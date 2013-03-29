% Quick helper to check the eye tracker setup
% Should produce the file ET_Test.edf with a single trigger in it.

function NeuroMod_CheckEyeTracker

% Have to initialize these to send a trigger
global PTBUSBBoxInitialized;
if isempty(PTBUSBBoxInitialized)
    PTBUSBBoxInitialized = 0;
end
global PTBStimTrackerInitialized;
if isempty(PTBStimTrackerInitialized)
    PTBStimTrackerInitialized = 0;
end
global PTBTriggerPortInitialized;
if isempty(PTBTriggerPortInitialized)
    PTBTriggerPortInitialized = 0;
end
global PTBEyeTrackerRecording;
if isempty(PTBEyeTrackerRecording)
    PTBEyeTrackerRecording = 0;
end

% Turn it on
PTBInitEyeTracker;

% Set a file going
status = Eyelink('OpenFile','ET_Test.edf');
disp(['Got status ' num2str(status) ' for command for open file.']);
if status ~= 0
    error(['Could not open eye tracker file. Gave status :' num2str(status) '.']);
end

% Start a recording
global PTBEyeTrackerRecording;
status = Eyelink('StartRecording');
disp(['Got status ' num2str(status) ' for command for start recording.']);
if status ~= 0
    error('Could not start recording eyetracker.');
end
PTBEyeTrackerRecording = 1;

% Send a test trigger
pause(1);
PTBSendTrigger(1, 0);

% Stop
PTBStopEyeTrackerRecording;

% Get the file
NeuroMod_GetETFile('ET_Test');

