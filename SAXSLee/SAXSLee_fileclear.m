function SAXSLee_fileclear(varargin)
% SAXSLee_fileclear Called by SAXSLee 
%
% Copyright 2010, Byeongdu Lee
hFigSAXSLee = findobj('Tag','SAXSLee_Fig');
setall = evalin('base', 'setall');
%setall = getappdata(hFigSAXSLee, 'setall');
setN = get(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'value');
menustring = get(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'string');

if ~isempty(menustring) & (numel(setall) > 0)
    setall(setN) = [];
    menustring(setN) = [];
    numel(menustring)
    %setappdata(hFigSAXSLee, 'setall', setall);
    assignin('base', 'setall', setall);
    if numel(menustring) == 0
        menustring = ' ';
    end
    set(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'string', menustring);
    set(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'value', 1);
end
%if numel(setall) >= setN
%    try
%        setall{setN} = {};
        
%setN = str2num(strtok(file, 'LoadDir'));
%settings = setall{setN};
%scan = settings.scan;
