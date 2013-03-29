% Helper to make sure our trials look the same
function NeuroMod_PrintTrial(fid, run_num, item_num, stims, ITI,...
    condition, a_pos, n_v, p_l, answer, probe, triggers)

% The item num
trial_str = [num2str(run_num) '\t' num2str(item_num) '\t'];
for s = 1:length(stims)
    trial_str = [trial_str stims{s} '\t'];
end
trial_str = [trial_str num2str(ITI) '\t' num2str(condition) '\t'...
    num2str(a_pos) '\t' n_v '\t' p_l '\t' answer '\t' probe '\t'];
for t = 1:length(triggers)
    trial_str = [trial_str num2str(triggers(t)) '\t'];
end
fprintf(fid,[trial_str '\n']);
