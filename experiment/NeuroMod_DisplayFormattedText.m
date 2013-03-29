
% Quick helper to display formatted text for the neuromod experiment
%
% end_time output: Set to end_time + stim_time, unless we're waiting for a
% response

function end_time = NeuroMod_DisplayFormattedText(text, start_time, ...
    stim_time, size, color, font, trigger, use_photo_square)

% Experiment parameters
global GL_vertical_offset;
global GL_trigger_delay;
global GL_use_photo_square;
global PTBScreenRes;

% Only set given options
if exist('font','var') && ~isempty(font)
    PTBSetTextFont(font);
end
if exist('size','var') && ~isempty(size)
    PTBSetTextSize(size);
end
if exist('color','var') && ~isempty(color)
    PTBSetTextColor(color);
end

% Set the duration
if isnumeric(stim_time)
    end_time = start_time + stim_time;
    duration = {end_time};

% Could be response keys
elseif iscell(stim_time)
    duration = stim_time;
    end_time = -1;
else
    error('Bad duration');
end

% And display
if exist('trigger','var')

    % Might be using the photo square, but allow overriding
    if ~exist('use_photo_square','var')
        use_photo_square = GL_use_photo_square;
    end
    if use_photo_square
        PTBDisplayPictures({'white_square.jpg'}, {[50 PTBScreenRes.height - 50]},{1}, {-1},'PhotoSquare');
    end
    PTBDisplayText(text, {'center', [0 GL_vertical_offset]},...
        duration, trigger, GL_trigger_delay);
else    
    PTBDisplayText(text, {'center', [0 GL_vertical_offset]},duration);
end

