function tickset(h, axis, axisvalue, tickv, form)
% form : format ex, '%3.1f'
if axis == 0
    axis = 'xtick';
    axisl = 'xticklabel';
else
    axis = 'ytick';
    axisl = 'yticklabel';
end

if nargin < 5
    form = '%2.1f';
end

tick = [];
tickl = {};
for i=1:length(tickv)
    t = find(axisvalue == tickv(i));
    tick(i) = t;
    tickl{i} = num2str(tickv(i), form);
end
set(h, axis, tick);
set(h, axisl, tickl);