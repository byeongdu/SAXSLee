function refscanplot(varargin)

hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
hAxes = findobj(hFigSAXSLee,'Tag','SAXSLee_Axes');
if numel(varargin) == 0
    hObject = findobj(hFigSAXSLee, 'Tag', 'toolbarRefScan');
else
    hObject = varargin{1};
end

if strcmp(get(hObject, 'State'), 'on')
    try
        backscan = getappdata(hFigSAXSLee,'backscan');
    catch
        backscan = [];
    end
    if ~isempty(backscan)
        tgs = ['BACK: ', backscan.Tag];
        hLine = line('Parent',hAxes,...
            'XData',backscan.colData(:,1),...
            'YData',backscan.colData(:,2),...
            'Tag',tgs);
        backscan.handle(1) = hLine;
        setappdata(hLine, 'yDataError', backscan.colData(:,3))
        setappdata(hLine, 'isSAXS', 1)
%        plotoption(hLine, 1);
        set(hLine, 'linewidth', 2);
%        set(hLine, 'linestyle', ':');
        if isfield(backscan, 'WTag')
            tgs = ['BACK: ', backscan.WTag];
            hLine = line('Parent',hAxes,...
                'XData',backscan.colWData(:,1),...
                'YData',backscan.colWData(:,2),...
                'Tag',tgs);
            backscan.handle(2) = hLine;
            setappdata(hLine, 'yDataError', backscan.colWData(:,3))
            setappdata(hLine, 'isSAXS', 0);
        set(hLine, 'linewidth', 2);
            
        end
        
    end
else
    tm = findobj(hAxes, 'type', 'line', '-regexp','Tag','BACK:');
    delete(tm);
%     for is = 1:numel(tm);
%         if strfind(get(tm(is), 'Tag'), 'BACK')
%            delete(tm(is));
%         end
%     end
    %backscan.handle = [];
end
% --- determine legend

if exist('backscan', 'var')
    setappdata(hFigSAXSLee,'backscan', backscan);
end

%curvelegend(hFigSAXSLee);
%SAXSLee_transmittance_callback(hFigSAXSLee)
end
