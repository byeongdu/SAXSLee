function showFF(varargin)

hFigSAXSLee = evalin('base', 'SAXSLee_Handle');

hAxes = findobj(hFigSAXSLee,'Tag','SAXSLee_Axes');
hObject = findobj('Tag', 'toolbarshowFF');
%popmenuref = [];
if strcmp(get(hObject, 'State'), 'on')
    try
        backscan = getappdata(hFigSAXSLee,'FFscan');
    catch
        backscan = [];
    end
    if ~isempty(backscan)
        tgs = ['FF: ', backscan.Tag];
        hLine = line('Parent',hAxes,...
            'XData',backscan.colData(:,1),...
            'YData',backscan.colData(:,2),...
            'Tag',tgs);
        setappdata(hLine, 'yDataError', backscan.colData(:,3))
        set(hLine, 'linewidth', 2);
%        set(hLine, 'linestyle', ':');
%        plotoption(hLine, 1);
        if isfield(backscan, 'WTag')
            tgs = ['FF: ', backscan.WTag];
            hLine = line('Parent',hAxes,...
                'XData',backscan.colWData(:,1),...
                'YData',backscan.colWData(:,2),...
                'Tag',tgs);
            setappdata(hLine, 'yDataError', backscan.colWData(:,3))
        set(hLine, 'linewidth', 2);
%        set(hLine, 'linestyle', ':');
%            plotoption(hLine, 1);
        end
        
    end
else
    tm = findobj(hAxes, 'type', 'line');
    for is = 1:numel(tm)
        if strfind(get(tm(is), 'Tag'), 'FF')
            delete(tm(is));
        end
    end
end
% --- determine legend
    curvelegend(hFigSAXSLee);
end