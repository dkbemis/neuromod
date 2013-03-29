%% 

% Distances for 'humungou' ('This') with Verdana, 22

% Want to keep this below 4 degrees
%   * Was originally set to work_comp_ang

% This is on the linux at work
work_comp_dist = 460;
work_comp_text = 31;     % 31 (12)
work_comp_ang = calculateVisualAngle(work_comp_text, work_comp_dist);

% Home
home_comp_dist = 480;
home_comp_text = 25;     % 25 (10)
home_comp_ang = calculateVisualAngle(home_comp_text, home_comp_dist);


% This is in the mri scanner
mri_dist = 890;
mri_text = 60;     % 60 (25)
mri_ang = calculateVisualAngle(mri_text, mri_dist);

mri_ang_corr = calculateVisualAngle(comp_ang/mri_ang*comp_text*2, mri_dist)


%% Font test

environment = 'MEG_computer';
is_debugging = 0;
stims = {'This','is','humongou','and','this','is','tiny'};
bg_color = [100 100 100];
size = 22;  % 22, 26
color = [255 255 255];
font = 'Verdana'; % Verdana, Times
wait_for_key = 1;
upper_case = 0;
NeuroMod_FontTest(environment, stims, bg_color, size, color,...
    font, upper_case, wait_for_key, is_debugging);


