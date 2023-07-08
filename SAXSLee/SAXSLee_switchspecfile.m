function SAXSLee_switchspecfile(varargin)
hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
hPopupmenuX = findobj(hFigSAXSLee,'Tag','SAXSLee_PopupmenuX');
%hAxes = findobj(hFigSAXSLee,'Tag','SAXSLee_Axes');
%settings = getappdata(hFigSAXSLee,'settings');
%setall = getappdata(hFigSAXSLee,'setall');
setall = evalin('base','setall');
try
    settings = setall{get(hPopupmenuX, 'value')}.settings;
    setappdata(hFigSAXSLee,'settings', settings);
catch
end