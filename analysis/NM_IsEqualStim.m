function is_equal = NM_IsEqualStim(stim_1, stim_2)

% Let capitalization slide...
is_equal = strcmpi(stim_1, stim_2);

% Might allow some wiggle room
if ~is_equal

    % Might be just formatting
    if ~isempty(find(stim_1-0 > 128, 1)) ||...
        	~isempty(find(stim_2-0 > 128,1))
        is_equal = 1;
    end
end
