function resettrueref(varargin)
hFigTrueref = findall(0,'Tag','trueref_Fig');
hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
settings = getappdata(hFigSAXSLee,'settings');
if isempty(hFigTrueref)
    return;
end
if isappdata(hFigTrueref,'data');
    rmappdata(hFigTrueref,'data');  % delete figure's children 'data'
    settings.trueref.openfiles = {};
    setappdata(hFigSAXSLee,'settings',settings);
end
hAxes = findall(hFigTrueref,'Tag','trueref_Axes');
if ~isempty(hAxes)
    cla(hAxes);
end
legend off;
resettoolbar(hFigTrueref);