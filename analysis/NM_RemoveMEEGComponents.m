function NM_RemoveMEEGComponents(should_save)

% Load up the data
global GLA_meeg_data;
NM_LoadMEEGData();

% Set the options
global GLA_subject_data;
GLA_meeg_data.decomp_method = GLA_subject_data.parameters.meeg_decomp_method;
GLA_meeg_data.decomp_type = GLA_subject_data.parameters.meeg_decomp_type;  
GLA_meeg_data.decomp_comp_num = GLA_subject_data.parameters.meeg_decomp_comp_num;  

% See which type
switch GLA_meeg_data.decomp_type
    case 'combined'
        removeComponents_Combined();
        
    case 'separate'
        removeComponents_Separate();
           
    otherwise
        error('Unknown type');
end

% Default to save
if ~exist('should_save','var') || should_save
    NM_SaveMEEGData();
end


function removeComponents_Combined()

% Need to normalize the data first
norms = getNorms();
normalizeData(norms);

global GLA_meeg_data;
GLA_meeg_data.data = computeRejections('MEG', 'MEG');

% And unnormalize
norms = 1./norms;
normalizeData(norms);


function data = computeRejections(type, channels)

% See if we already computed on blinks
global GLA_subject;
global GLA_meeg_type;
global GLA_meeg_trial_type;
blinks_file_name = [NM_GetCurrentDataDirectory() '/analysis/' GLA_subject '/'...
    GLA_subject '_' GLA_meeg_type '_blinks_data.mat'];
if ~strcmp(GLA_meeg_trial_type,'blinks') && exist(blinks_file_name,'file')
    
    % See if we want to use the blinks
    while 1
        ch = input('Use saved blinks decomposition? (y/n) ','s');
        if strcmp(ch,'y')
            use_blinks = 1;
            break;
        end
        if strcmp(ch,'n')
            use_blinks = 0;
            break;
        end
    end    
else
    use_blinks = 0;
end

% Either use the blinks or not
if use_blinks
    setComponentsFromBlinks(type, blinks_file_name);
else
    decomposeData(type, channels); 
end


% And reconstruct
global GLA_meeg_data;
cfg = [];
cfg.demean = 'no';
cfg.component = GLA_meeg_data.([type '_comp_rej']);
data = ft_rejectcomponent(cfg,GLA_meeg_data.([type '_comp']),GLA_meeg_data.data);


function setComponentsFromBlinks(type, blinks_file_name)

% Just set exactly 
global GLA_meeg_data;
b_data = load(blinks_file_name);
GLA_meeg_data.([type '_comp']) = b_data.GLA_meeg_data.([type '_comp']);
GLA_meeg_data.([type '_comp_rej']) = b_data.GLA_meeg_data.([type '_comp_rej']);


function decomposeData(type, channels)

global GLA_meeg_data;
cfg = [];
cfg.method = GLA_meeg_data.decomp_method;
cfg.numcomponent = GLA_meeg_data.decomp_comp_num;
cfg.channel = channels;
GLA_meeg_data.([type '_comp']) = ft_componentanalysis(cfg,GLA_meeg_data.data);
GLA_meeg_data.([type '_comp']).typechan = cfg.channel;

% Browse...
cfg = [];
cfg.layout='neuromag306all.lay';
ft_databrowser(cfg, GLA_meeg_data.([type '_comp']));

% Display some helpful blink info
displayBlinkInfo(type);

% Get the components to reject
GLA_meeg_data.([type '_comp_rej']) = [];
while 1
    rej = input('Comp to reject (enter to end): ');
    if isempty(rej)
        break;
    end
    GLA_meeg_data.([type '_comp_rej'])(end+1) = rej; 
end


function displayBlinkInfo(type)

% Are there blinks?
has_blinks = 0;
global GLA_meeg_data;
disp('Blinks:');
for t = 1:length(GLA_meeg_data.blinks.trials)
    if ~isempty(GLA_meeg_data.blinks.starts{t}) || ~isempty(GLA_meeg_data.blinks.stops{t})
        has_blinks = 1;
        b_str = ['    ' num2str(t) ': '];
        if ~isempty(GLA_meeg_data.blinks.starts{t})
            b_str = [b_str 'Starts (']; %#ok<AGROW>
            for b = 1:length(GLA_meeg_data.blinks.starts{t})
                b_str = [b_str num2str(GLA_meeg_data.blinks.starts{t}(b) + GLA_meeg_data.pre_stim) ',']; %#ok<AGROW>
            end
            b_str = [b_str ') ']; %#ok<AGROW>
        end
        if ~isempty(GLA_meeg_data.blinks.stops{t})
            b_str = [b_str 'Ends (']; %#ok<AGROW>
            for b = 1:length(GLA_meeg_data.blinks.stops{t})
                b_str = [b_str num2str(GLA_meeg_data.blinks.stops{t}(b) + GLA_meeg_data.pre_stim) ',']; %#ok<AGROW>
            end
            b_str = [b_str ') ']; %#ok<AGROW>
        end
        disp(b_str);
    end
end

if ~has_blinks
    disp('     No blinks!');
    return;
end

% Compute the correlation
num_comp = size(GLA_meeg_data.([type '_comp']).trial{1},1);
all_corr = zeros(num_comp, length(GLA_meeg_data.([type '_comp']).trial));
for t = 1:length(GLA_meeg_data.([type '_comp']).trial)
    all_corr(:,t) = corr(GLA_meeg_data.([type '_comp']).trial{t}',GLA_meeg_data.blinks.trials{t}); 
end
mean_corr = nanmean(all_corr,2);
[val s_ord] = sort(abs(mean_corr),'descend'); %#ok<ASGLU>
disp('Correlation with blinks:');
for c = s_ord'
    disp(['     ' num2str(c) ': ' num2str(mean_corr(c))]); 
end

    

function normalizeData(norms)
global GLA_meeg_data;
for ch = 1:length(GLA_meeg_data.data.label)
    switch NM_GetMEGChannelType(GLA_meeg_data.data.label{ch})
        case 'grad_1'
            ind = 1;
        case 'grad_2'
            ind = 2;
        case 'mag'
            ind = 3;
    end
    for t = 1:length(GLA_meeg_data.data.trial)
        GLA_meeg_data.data.trial{t}(ch,:) = ...
            GLA_meeg_data.data.trial{t}(ch,:)/norms(ind);
    end
end


function norms = getNorms()

global GLA_meeg_data;

% Grab all the limits
ch_limits = ones(length(GLA_meeg_data.data.label),2);
ch_limits(:,1) = ch_limits(:,1)*-1000; ch_limits(:,2) = ch_limits(:,2)*1000; 
for t = 1:length(GLA_meeg_data.data.trial)
    ch_limits(:,1) = max([ch_limits(:,1) max(GLA_meeg_data.data.trial{1},[],2)],[],2);
    ch_limits(:,2) = min([ch_limits(:,2) min(GLA_meeg_data.data.trial{1},[],2)],[],2);
end

% Distill the norms
limits = ones(3,2); 
limits(:,1) = limits(:,1)*-1000; limits(:,2) = limits(:,2)*1000; 
for ch = 1:length(GLA_meeg_data.data.label)
    switch NM_GetMEGChannelType(GLA_meeg_data.data.label{ch})
        case 'grad_1'
            ind = 1;
        case 'grad_2'
            ind = 2;
        case 'mag'
            ind = 3;
    end
    limits(ind,1) = max(limits(ind,1),ch_limits(ch,1));
    limits(ind,2) = min(limits(ind,2),ch_limits(ch,2));
end
norms = max(abs(limits),[],2);


function removeComponents_Separate()

% Run the algorithm on each of the senors
s_types = {'grad_1','grad_2','mag'};
recon = {};
global GLA_meeg_data;
for s = 1:length(s_types)
    s_channels.(s_types{s}) = NM_GetMEGChannels(GLA_meeg_data.data, s_types{s});
    recon.(s_types{s}) = computeRejections(s_types{s}, s_channels.(s_types{s}));
end

% And reconstruct
for ch = 1:length(GLA_meeg_data.data.label)
    for s = 1:length(s_types)
        ind = find(strcmp(GLA_meeg_data.data.label{ch},s_channels.(s_types{s}))); 

        % When we do, replace the data
        if ~isempty(ind)
            for t = 1:length(GLA_meeg_data.data.trial)
                GLA_meeg_data.data.trial{t}(ch,:) = ...
                    recon.(s_types{s}).trial{t}(ind,:);
            end
        end
    end
end

