function hdl = SAXSLee_loaddata_obsolete
    hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
    hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
    if ~isempty(hFigSAXSLee)
        settings = getappdata(hFigSAXSLee,'settings');
    else
        settings = [];
    end

    if isempty(settings)
        SAXSLeepath = pwd;
    else
        SAXSLeepath = settings.path;
    end

    hLine = findall(hAxes,'Type','line');
% --- get tags of lines and remove datatipmarkers from hLine
    tempHLine = [];
    for iLine = 1:length(hLine)
        if ~strcmp(get(hLine(iLine),'Tag'),'DataTipMarker') & ~strcmp(get(hLine(iLine),'Tag'),'Dot')
            tempHLine(length(tempHLine)+1) = hLine(iLine);
        end
    end
    hLine = tempHLine';

% --- extract x,y data, yerror, scan tags, xlable, ylabel, title from each plot
    hdl = [];
    for mm = 1:length(hLine)
        htag = get(hLine(mm),'tag');
        if htag(1) == 'W'
            continue
        end
        if isempty(findstr(htag, ': W'))
            hdl = [hdl, hLine(mm)];
        end
    end
%    for mm = 1:length(hLine)
%        if isempty(findstr(get(hLine(mm),'tag'), 'REF#'))
%            hdl = [hdl, hLine(mm)];
%        end
%    end
