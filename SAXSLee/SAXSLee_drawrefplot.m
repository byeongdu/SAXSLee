function hLine = SAXSLee_drawrefplot(scan, hAxes, hPopupmenuY)
popmenuref = '';
if numel(scan) < 1
    disp('No reference data')
    return
end

%try
    for is = 1:numel(scan)
    % --- if ydata has negative data,then ydataError = 0
        if ~isempty(scan{is})
            hLine(is) = line('Parent',hAxes,...
                'XData',scan{is}.colData(:,1),...
                'YData',scan{is}.colData(:,2),...
                'Tag',['REF#', num2str(is), ': ', scan{is}.Tag]);
            plotoption(hLine(is), is);
            popmenuref{is} = num2str(is);
        end
        %setappdata(hLine(iSelection),'ydataError',ydataError);
    end
    if isempty(popmenuref)
        popmenuref = '     ';
    end
    set(hPopupmenuY,'String', popmenuref);
%catch
%    disp('refscan.colData is empty')
%end
    
