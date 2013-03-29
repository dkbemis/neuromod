% Purpose is to generate trial orders such that no pairwise order is
% duplicated. 
%   * The function checks this criterion before printing the lists.

function NeuroMod_CreateTrialOrder(out_file)

% NOTE: For fMRI orders, we include conditions 11, 12 for blanks
global GL_order_num_conditions;
global GL_run_length;

% Calculate  the number of trials
num_trials = GL_run_length*GL_order_num_conditions*2;   % 2 b/c run length separates n/v trials

% Check
if num_trials > GL_order_num_conditions*GL_order_num_conditions
    error('Too many trials.');
end

ord = getOrder(num_trials);
checkOrder(ord);
printOrder(out_file, ord);

function checkOrder(ord)

global GL_order_num_conditions;

% Check the numbers
trial_cts = zeros(GL_order_num_conditions,1);
for c = 1:GL_order_num_conditions
    trial_cts(c) = sum(ord(1:end) == c);
end
if sum(diff(trial_cts)) > 0
    error('Different number of trials per condition');
end

% And check that no orders are repeated
for c = 1:GL_order_num_conditions
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



function printOrder(out_file, ord)

global GL_order_stim_time;
global GL_order_SOA;

fid = fopen(out_file,'w');
time_ctr = 0;
for t = 1:length(ord)
    fprintf(fid,[num2str(time_ctr) ',' num2str(ord(t)) ',' num2str(GL_order_stim_time) '\n']);
    time_ctr = time_ctr+GL_order_SOA;
end
fclose(fid);


function ord = getOrder(num_trials)

global GL_order_num_conditions;
global GL_blank_buffer;

% Only set for even number...
if mod(num_trials,GL_order_num_conditions) ~= 0
    error('Non-even number of trials per run.');
end
num_cond_trials = num_trials / GL_order_num_conditions;

test_ctr = 0;
while test_ctr < 1000
    to_use = ones(GL_order_num_conditions,GL_order_num_conditions);
    
    ord = ceil(rand*GL_order_num_conditions);
    for i = 1:num_trials-1
        ctr = 1;
        r_ord = randperm(GL_order_num_conditions);
        while ctr < GL_order_num_conditions+1
            if sum(ord == r_ord(ctr)) >= num_cond_trials
                ctr = ctr+1;
                continue;
            end
            if to_use(ord(end),r_ord(ctr)) == 1
                to_use(ord(end),r_ord(ctr)) = 0;
                ord(end+1) = r_ord(ctr); %#ok<AGROW>
                break;
            end
            ctr = ctr+1;
        end
        if ctr == 11
            disp(['Not found: ' num2str(test_ctr) ' at ' num2str(length(ord))]);
            break;
        end
    end
    
    % Check to make sure we don't have blanks near the beginning or end
    % and that we got a full list.
    
    % ...or end
    if length(ord) == num_trials && ~any(ord([1:GL_blank_buffer, end-GL_blank_buffer+1:end]) > 10)
        return;
    end
    test_ctr = test_ctr+1;
end


