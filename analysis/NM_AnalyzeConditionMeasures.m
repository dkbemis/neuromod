% Quick analysis of condition measures
function NM_AnalyzeConditionMeasures(type, measures)

global GLA_subject;
disp(['Analyzing data for ' GLA_subject '...']);

% Take a look at the main effect
analyzeMainEffect(type, measures);

% And the trands
analyzeLinearEffect(type, measures);


% And save
save_file = [NM_GetCurrentDataDirectory() '/analysis/'...
    GLA_subject '/' GLA_subject '_' type '_analysis'];
saveas(gcf, [save_file '.jpg'],'jpg');


function analyzeLinearEffect(type, measures)

% Summarize
types = {'phrases','lists'};
means = []; stderrs = []; p = [];
all_measures.phrases = []; all_measures.lists = [];
for c = 1:4
    for t = 1:length(types)
        means(t,c) = mean(measures.(types{t}){c});
        stderrs(t,c) = std(measures.(types{t}){c})/...
            sqrt(length(measures.(types{t}){c}));
        all_measures.(types{t}) = [all_measures.(types{t}); ...
            [measures.(types{t}){c}' repmat(c,length(measures.(types{t}){c}),1)]];
    end
    [h p(end+1)] = ttest2(measures.(types{1}){c}, measures.(types{2}){c});
end

% And plot
subplot(1,2,2); hold on; title(type);
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
a = axis();
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
        str = [str ' *'];
    end
    text(4.2,means(t,end),str);
end

a = [all_measures.phrases(:,1); all_measures.lists(:,1)];
b = [repmat(1,length(all_measures.phrases(:,1)),1); repmat(2,length(all_measures.lists(:,1)),1)];
c = [all_measures.phrases(:,2); all_measures.lists(:,2)];
[p t] = anovan(a,{b,c},'display','off','model','interaction')

labels = {'structure','length','interaction'};
for i = 1:length(labels)
    text(1,ax(3)+(.05*i)*(ax(4)-ax(3)),[labels{i} ': p = ' num2str(p(i))]);
end


function analyzeMainEffect(type, measures)

% Pool the different conditions
pooled.phrases = []; pooled.lists = [];
for c = 2:4
    pooled.phrases(end+1:end+length(measures.phrases{c})) = measures.phrases{c};
    pooled.lists(end+1:end+length(measures.lists{c})) = measures.lists{c};
end

% Test for an effect
[h p] = ttest2(pooled.phrases,pooled.lists);

% And plot
figure; subplot(1,2,1); hold on; title(type);

% Plot the means
types = {'phrases','lists'};
colors = {'r','g'};
means = []; stderrs = [];
for t = 1:length(types)
    means(t) = mean(pooled.(types{t}));
    bar(t, means(t),colors{t});
    stderrs(t) = std(pooled.(types{t}))/sqrt(length(pooled.(types{t})));
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


