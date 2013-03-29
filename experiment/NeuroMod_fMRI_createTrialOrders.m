function NeuroMod_fMRI_createTrialOrders(num_orders, ...
    num_trials, num_conditions, stim_time, SOA)

% Check
if num_trials > num_conditions*num_conditions
    error('Too many trials.');
end

out_ctr = 1;
while out_ctr < num_orders+1
    ord = getOrder(num_conditions, out_ctr, num_trials);
    checkOrder(ord, num_conditions);
    printOrder(['fMRI_Order_' num2str(out_ctr) '.csv'], ...
        ord, stim_time, SOA);
    out_ctr = out_ctr+1;
end

function checkOrder(ord, num_conditions)

% Check the numbers
trial_cts = zeros(num_conditions,1);
for c = 1:num_conditions
    trial_cts(c) = sum(ord(1:end) == c);
end
if sum(diff(trial_cts)) > 0
    error('Different number of trials per condition');
end

% And check that no orders are repeated
for c = 1:num_conditions
    offset = 0;
    ind = find(ord == c);
    if ind(end) == length(ord)
        ind = ind(1:end-1);
        offset = 1;
    end
    if length(unique(ord(ind+1))) ~= trial_cts(c)-offset
        error('Duplicated orders.');
    end
end



function printOrder(out_file, ord, stim_time, SOA)

fid = fopen(out_file,'w');
time_ctr = 0;
for t = 1:length(ord)
    fprintf(fid,[num2str(time_ctr) ',' num2str(ord(t)) ',' num2str(stim_time) '\n']);
    time_ctr = time_ctr+SOA;
end
fclose(fid);


function ord = getOrder(num_cond, out_ctr, num_trials)

% Only set for even number...
if mod(num_trials,num_cond) ~= 0
    error('Non-even number of trials per run.');
end
num_cond_trials = num_trials / num_cond;

test_ctr = 0;
while test_ctr < 1000
    to_use = ones(num_cond,num_cond);
    
    ord = ceil(rand*num_cond);
    for i = 1:num_trials-1
        ctr = 1;
        r_ord = randperm(num_cond);
        while ctr < num_cond+1
            if sum(ord == r_ord(ctr)) >= num_cond_trials
                ctr = ctr+1;
                continue;
            end
            if to_use(ord(end),r_ord(ctr)) == 1
                to_use(ord(end),r_ord(ctr)) = 0;
                ord(end+1) = r_ord(ctr);
                break;
            end
            ctr = ctr+1;
        end
        if ctr == 11
            disp(['Not found: ' num2str(test_ctr) ' at ' num2str(length(ord))]);
            break;
        end
    end
    if length(ord) == num_trials
        disp(['Found: ' num2str(out_ctr)]);
        return;
    end
    test_ctr = test_ctr+1;
end


