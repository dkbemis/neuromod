
% Helper to add to struct arrays...
function a = NM_AddStructToArray(s, a)
if isempty(a)
    a = s;
else
    a(end+1) = s(1); 
end

