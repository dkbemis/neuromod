% Quick helper to switch the order on the localizer stims
function switchLocalizerOrder(order_nums)

for on = 1:length(order_nums)
    order_num = order_nums(on);
    num_str = num2str(order_num);
    if order_num < 10
        num_str = ['0' num_str]; %#ok<AGROW>
    end

    % Read
    fid = fopen(['run' num_str '.csv']);
    lines = {};
    while 1
        line = fgetl(fid);
        if ~ischar(line)
            break;
        end
        lines{end+1} = NeuroMod_ConvertToUTF8(line); %#ok<AGROW>
    end
    fclose(fid);

    % Grab the onsets
    onsets = [];
    for l = 2:length(lines)
        [num lines{l}] = strtok(lines{l},',');
        [onset lines{l}] = strtok(lines{l},',');
        onsets(end+1) = str2double(onset);
    end
    
    % Switch up the orders
    order = zeros(1,length(lines)-1);
    order(1:2:end) = 3:2:length(lines);
    order(2:2:end) = 2:2:length(lines);


    % Write
    fid = NeuroMod_OpenUTF8File(['run' num_str '.csv']);
    fprintf(fid,[lines{1} '\n']);
    for i = 1:length(order)

        % Write out with the new order and old onsets
        
        fprintf(fid,['"' num2str(i) '",' num2str(onsets(i)) lines{order(i)} '\n']);
    end
    fclose(fid);
end
