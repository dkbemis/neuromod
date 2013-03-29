

% For visual angle
function angle = calculateVisualAngle(text_width, dist_to_screen)
angle = 2*atand(text_width/dist_to_screen/2);

% % Hello. -> 28mm ~2 visual degrees (Geneva, 25 pt. font
% 
% % Distance to screen ~890mm
% % Display screen 33mm -> 36mm in the scanner
% 
% dist_to_screen = 890;
% 
% %   * Geneva, 25pt, 'Hello.' ~ 1.96 degrees (28mm)
% %   * Geneva, 30pt, 'Hello.' ~ 2.45 degrees (35mm)
% %   * Geneva, 30pt, 'ahsjdkfl' ~ 3.44 degrees (49mm)
% %   * Geneva, 30pt, 'ahsj' ~ 1.75 degrees (25mm)
% text_width = 25;    % On display compter
% 
% % Convert to in scanner
% text_width =  text_width*36/33;
