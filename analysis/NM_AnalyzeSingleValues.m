% 
% % TTest
% cfg.data_type = 'behavioral';
% cfg.value_type = 'rt';


% Quick analysis of condition measures
function NM_AnalyzeSingleValues(cfg)

global GLA_subject;
disp(['Analyzing ' cfg.data_type ' ' ...
    cfg.value_type ' data for ' GLA_subject '...']);

% Make sure we're loaded
NM_LoadSubjectData();

% Set the measure
setValues(cfg);

% Take a look at the main effect
analyzeMainEffect(cfg);

% And the trands
analyzeLinearEffect(cfg);

% And save and clear the data
saveas(gcf, [NM_GetCurrentDataDirectory() '/analysis/'...
    GLA_subject '/' GLA_subject '_' cfg.data_type '_' ...
    cfg.value_type '_analysis.jpg'],'jpg');
clear global GL_SV_data;


function setValues(cfg)

% Calculate the measures
clear global GL_SV_data;
switch cfg.data_type
    case 'behavioral'
        setBehavioralValues(cfg);
    
    otherwise
        error('Unknown type');
end


function setBehavioralValues(cfg)

% Make the clean data
NM_CreateCleanBehavioralData();

% Set and arrange the right measure
global GL_SV_data;
global GLA_clean_behavioral_data;
switch cfg.value_type
    case 'rt'
        GL_SV_data.trial_cond = GLA_clean_behavioral_data.data.cond;
        GL_SV_data.trial_data = [GLA_clean_behavioral_data.data.rt{:}];
        arrangeData();
        
    otherwise
        error('Unknown type');
end

function arrangeData()

% Arrange the data how we want
global GL_SV_data;
GL_SV_data.conditions = sort(unique(GL_SV_data.trial_cond));
for c = 1:length(GL_SV_data.conditions)
    GL_SV_data.condition_data{c} = ...
        GL_SV_data.trial_data(GL_SV_data.trial_cond == GL_SV_data.conditions(c));
end


function analyzeLinearEffect(cfg)

% Summarize
global GL_SV_data;
types = {'phrases','lists'};
means = []; stderrs = []; p = [];
all_measures.phrases = []; all_measures.lists = [];
for c = 1:4
    for t = 1:length(types)
        
        % Get the right condition
        if strcmp(types{t},'lists')
            cond = c + 5;
        else
            cond = c; 
        end
        
        means(t,c) = mean(GL_SV_data.condition_data{cond}); %#ok<AGROW>
        stderrs(t,c) = std(GL_SV_data.condition_data{cond})/...
            sqrt(length(GL_SV_data.condition_data{cond})); %#ok<AGROW>
        all_measures.(types{t}) = [all_measures.(types{t}); ...
            [GL_SV_data.condition_data{cond}' ...
                repmat(c,length(GL_SV_data.condition_data{cond}),1)]];
    end
    [h p(end+1)] = ttest2(GL_SV_data.condition_data{c},GL_SV_data.condition_data{c+5}); %#ok<ASGLU,AGROW>
end

% And plot
global GLA_subject;
subplot(1,2,2); hold on; 
title([GLA_subject ' ' cfg.data_type ' ' cfg.value_type]);
colors = {'r','g'};
for t = 1:length(types)
    plot(means(t,:),colors{t},'LineWidth',2);
end
legend(types,'location','best'); xlabel('Condition')
for t = 1:length(types)
    errorbar(means(t,:),stderrs(t,:),'k');    
end
for t = 1:length(types)
    plot(means(t,:),colors{t},'LineWidth',2);
end

% Reset the axis
axis([.5,5.5, min(min(means-stderrs))-5*mean(mean(stderrs)),...
    max(max(means+stderrs))+3*mean(mean(stderrs))]);
ax = axis();

% Plot significance
for c = 1:length(p)
    plotSig(p(c),c,max(means(:,c)+stderrs(:,c))+1.5*mean(stderrs(:,c)));
end


% Look at the linear trends
for t = 1:length(types)
    [r p] = corr(all_measures.(types{t}));
    str = ['r^2 = ' num2str(round(r(1,2)*r(1,2)*100)/100)];
    if p(1,2) < 0.05
        str = [str ' *']; %#ok<AGROW>
    end
    text(4.2,means(t,end),str);
end

a = [all_measures.phrases(:,1); all_measures.lists(:,1)];
b = [ones(length(all_measures.phrases(:,1)),1); repmat(2,length(all_measures.lists(:,1)),1)];
c = [all_measures.phrases(:,2); all_measures.lists(:,2)];
p = anovan(a,{b,c},'display','off','model','interaction');

labels = {'structure','length','interaction'};
for i = 1:length(labels)
    text(1,ax(3)+(.05*i)*(ax(4)-ax(3)),[labels{i} ': p = ' num2str(p(i))]);
end


function analyzeMainEffect(cfg)

% Pool the different conditions
global GL_SV_data;
pooled.phrases = horzcat(GL_SV_data.condition_data{2},...
    GL_SV_data.condition_data{3},GL_SV_data.condition_data{4}); 
pooled.lists = horzcat(GL_SV_data.condition_data{7},...
    GL_SV_data.condition_data{8},GL_SV_data.condition_data{9}); 


% Test for an effect
[h p] = ttest2(pooled.phrases,pooled.lists); %#ok<ASGLU>

% And plot
global GLA_subject;
figure; subplot(1,2,1); hold on; 
title([GLA_subject ' ' cfg.data_type ' ' cfg.value_type]);

% Plot the means
types = {'phrases','lists'};
colors = {'r','g'};
means = []; stderrs = [];
for t = 1:length(types)
    means(t) = mean(pooled.(types{t})); %#ok<AGROW>
    bar(t, means(t),colors{t});
    stderrs(t) = std(pooled.(types{t}))/sqrt(length(pooled.(types{t}))); %#ok<AGROW>
    errorbar(t,means(t), stderrs(t),'k','LineWidth',2);
end

% Reset the axis
a = axis();
axis([a(1:2), min(means-stderrs)-5*mean(stderrs), max(means+stderrs)+3*mean(stderrs)]);
set(gca,'XTickLabel',{'','phrases','','lists',''})

% Plot significance
plotSig(p,mean(a(1:2)),max(means+stderrs)+1.5*mean(stderrs));


function plotSig(p,x,y)

if p < 0.001
    t = text(x,y,'***');
elseif p < 0.01
    t = text(x,y,'**');
elseif p < 0.05
    t = text(x,y,'*');
elseif p < 0.1
    t = text(x,y,'(*)');
else
    return;
end
set(t,'FontSize',30);


