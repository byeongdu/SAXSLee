function resetrefscan(varargin)
% SCANPLOT Called by SAXSLee to plot scans.
%
hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
refscan = getappdata(hFigSAXSLee,'refscan');


hPopupmenuY = findall(hFigSAXSLee,'Tag','SAXSLee_PopupmenuY');
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
set(hPopupmenuY,'value', 1);
set(hPopupmenuY,'String', ' ');

% --- set x, y axis labels
rmdataplot
rmbackplot
rmFFplot
%settings = rmfield(settings, 'refscan');
refscan = [];
setappdata(hFigSAXSLee,'refscan', refscan);
setappdata(hFigSAXSLee,'FFscan', []);
setappdata(hFigSAXSLee,'backscan', []);
hObject = findall(0, 'Tag', 'toolbarRefScan');
set(hObject, 'State', 'off');
hObject = findall(0, 'Tag', 'toolbarAutobacksub');
set(hObject, 'State', 'off');
hObject = findall(0, 'Tag', 'toolbarshowFF');
set(hObject, 'State', 'off');
hObject = findall(0, 'Tag', 'toolbarAutoFFdivide');
set(hObject, 'State', 'off');

    function rmdataplot
    tm = findobj(hAxes, 'type', 'line');
        for is = 1:numel(tm);
            if strfind(get(tm(is), 'Tag'), 'REF#')
                delete(tm(is));
            end
        end
    end
    function rmbackplot
    tm = findobj(hAxes, 'type', 'line');
        for is = 1:numel(tm);
            if strfind(get(tm(is), 'Tag'), 'BACK: ')
                delete(tm(is));
            end
        end
    end
    function rmFFplot
    tm = findobj(hAxes, 'type', 'line');
        for is = 1:numel(tm);
            if strfind(get(tm(is), 'Tag'), 'FF: ')
                delete(tm(is));
            end
        end
    end
end