function SAXSLee_selectref(varargin)
    hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
    Nsel = get(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'value');
    setall = getappdata(hFigSAXSLee,'setall');
    scan = setall{Nsel}.scan;

    try
        [~, ~, ~, ~, data, tg] = SAXSLee_findcursor;
    catch
        disp('No data is selected')
        return
    end
    
    refscan = getappdata(hFigSAXSLee, 'refscan');
    refscan{1}.colData = data;
    refscan{1}.Tag = tg;
    if (tg(1) == 'S')
        for k=1:numel(scan.selection)
            tagtofind = scan.selection{k}.Tag;
            if strcmp(tagtofind, ['W', tg(2:end)])
                break
            end
        end
        refscan{1}.colWData = scan.selection{k}.colWData;
    end
    setappdata(hFigSAXSLee, 'refscan', refscan);    
    %hPopupmenuY = findall(hFigSAXSLee,'Tag','SAXSLee_PopupmenuY');
    %hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');

    %popmenuref = get(hPopupmenuY,'String')
    %str2num(popmenuref)
    %popmenuref = 
    %SAXSLee_drawrefplot(refscan, hAxes, hPopupmenuY)