function print2figure(varargin)
% PRINT2FIGURE Called by SAXSLee 

hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
fig = figure;
copyobj(findobj(hFigSAXSLee, 'type', 'axes'), fig);
ax = findobj(fig, 'type', 'axes');
set(ax, 'unit', 'normalized');
set(ax, 'position', [0.13 0.11 0.775 0.815]);
%set(ax, 'ActivePositionProperty', 'OuterPosition');
set(fig, 'color', 'w')
if (numel(ax) > 1)
    delete(ax(2:end));
end



