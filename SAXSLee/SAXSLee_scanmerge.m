function SAXSLee_scanmerge(varargin)
% SCANMERGE Called by SAXSLee to read scans from current plot to call mrgker
%   to merge scans.
%

hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
hAxes = findobj(hFigSAXSLee,'Tag','SAXSLee_Axes');
hLine = findobj(hAxes,'Type','line');
hObject = findobj(0, 'Tag', 'toolbarMerge');

if ~strcmp(get(hObject, 'State'), 'on');
    hLine = findall(hAxes,'Type','line');
    for mm = 1:numel(hLine)
         if SAXSLee_ismerged(hLine(mm))
             delete(hLine(mm));
         end
    end
    curvelegend(hFigSAXSLee)
    return
end


% --- get merge mode
settings = getappdata(hFigSAXSLee,'settings');

% --- if no or only one curve plotted, return
if isempty(hLine) || length(hLine) <= 1
    return;
end


if isfield(settings, 'atBeamline')
    if strcmp(settings.atBeamline, '12IDB')
        Beamline = '12IDB';
    end
    if strcmp(settings.atBeamline, 'PLS9A')
        Beamline = 'PLS9A';
    end
else
    Beamline = 'Unknown';
end

% --- get tags of lines and remove datatipmarkers from hLine
% tempHLine = [];
% lineTags = {};
% linetype = {};
% FN = {};
% k = 1;
% for iLine = 1:length(hLine)
%     if strfind(get(hLine(iLine),'Tag'), 'BACK: ')
%         continue;
%     end
%     if strfind(get(hLine(iLine),'Tag'), 'FF: ')
%         continue;
%     end
%     if getappdata(hLine(iLine), 'ismerged')
%         continue;
%     end
%     if ~strcmp(get(hLine(iLine),'Tag'),'DataTipMarker')
%         tempHLine(k) = hLine(iLine);
%         lineTags{k} = get(hLine(iLine),'Tag');
%         [~, f, e] = fileparts(lineTags{k});
%         FN{k} = f;
%         linetype{k} = e;
%         k = k + 1;
%     end
% end
% New way
isData = ~strcmp(get(hLine,'Tag'),'DataTipMarker');
isData = isData & cellfun('isempty', strfind(get(hLine,'Tag'), 'BACK: '));
isData = isData & cellfun('isempty', strfind(get(hLine,'Tag'), 'FF: '));
isMgd = zeros(size(hLine));
for i=1:numel(hLine)
    isM = getappdata(hLine(i), 'ismerged');
    if isempty(isM)
        isMgd(i) = 0;
    else
        isMgd(i) = isM;
    end
end
isData = isData & ~isMgd;

hLine2 = hLine(isData);
Nhl = length(hLine2);
tempHLine = zeros(1, Nhl);
lineTags = cell(1, Nhl);
linetype = cell(1, Nhl);
FN = cell(1, Nhl);
for iLine = 1:Nhl
    tempHLine(k) = hLine2(iLine);
    lineTags{k} = get(hLine2(iLine),'Tag');
    [~, f, e] = fileparts(lineTags{k});
    FN{k} = f;
    linetype{k} = e;
    k = k + 1;
end


[EXTtype, ~, lineCategory] = unique(linetype);

for i=1:numel(EXTtype)
    Sdt = cell(numel(hd), 1);
    Wdt = cell(numel(hd), 1);
    index = find(lineCategory == i);
    hd = tempHLine(lineCategory == i);
    comFN = FN{index(1)};
    sInd = 1;
    wInd = 1;
    for t = 1:numel(hd)
        [~,~, comFN] = LCS(comFN, FN{index(t)});
%        comFN = intersect(comFN, FN{index(t)});
        xd = get(hd(t), 'xdata');
        yd = get(hd(t), 'ydata');
        zd = getappdata(hd(t), 'yDataError');
        if getappdata(hd(t), 'isSAXS')
            Sdt{sInd} = [xd(:), yd(:), zd(:)];
            sInd = sInd + 1;
        else
            Wdt{wInd} = [xd(:), yd(:), zd(:)];
            wInd = wInd + 1;
        end
    end
    comFN(strfind(comFN, ' ')) = '_';
    newfilename = [comFN, EXTtype{i}, '_avg'];
    nd = SAXSLee_mrgker(Sdt);
    isSW = getappdata(hd(t), 'isSAXSWAXS');
    if isSW
        tg = ['S', newfilename];
        hd = plotdata(hAxes, nd, hd(t), tg);
        dataType = 'SAXS';
        ud = get(SAXSdata(i), 'userdata');
        %savedata(Beamline, dataType, settings, tg)
        SAXSLee_saveresult(settings, Beamline, dataType, nd, tg, ud)
        nd = SAXSLee_mrgker(Wdt);
        tg = ['W', newfilename];
        whd = plotdata(hAxes, nd, hd, tg);
        dataType = 'WAXS';
        ud = get(WAXSdata(i), 'userdata');
        %savedata(Beamline, dataType, settings, tg)
        SAXSLee_saveresult(settings, Beamline, dataType, nd, tg, ud);
        setappdata(whd, 'SAXShandle', hd)
        setappdata(hd, 'WAXShandle', whd)
    else
        tg = newfilename;
        %hd = plotdata(nd, hd(t), tg);
        dataType = 'SAXS';
        ud = get(SAXSdata(i), 'userdata');
        savedata(Beamline, dataType, settings, tg)
        SAXSLee_saveresult(settings, Beamline, dataType, nd, tg, ud);
    end
end

    function hdl = plotdata(hAxes, md, oldhandle, tg)

            hdl = line('Parent',hAxes,...
                'XData',md(:,1),...
                'YData',md(:,2),...
                'Tag',tg);
            setappdata(hdl, 'yDataError', md(:,3));
            setappdata(hdl, 'ismerged', 1);
            SAXSLee_copyPlotoption(oldhandle, hdl);
            set(hdl,...
                'Color','b',...
                'LineStyle','-',...
                'Marker','o',...
                'MarkerSize',3,...
                'MarkerFaceColor','m');
    end

    function rt = SAXSLee_ismerged(h)
        rt = getappdata(h, 'ismerged');
        if isempty(rt)
            rt = 0;
        end
    end

    function savedata(Beamline, dataType, settings, tg)
        switch Beamline
            case '12IDB'
                if numel(dataType)>1
                    pth = [settings.path, filesep, dataType];
                else
                    pth = settings.path;
                end
            case 'PLS9A'
                pth = settings.path;
            otherwise
                pth = settings.path;
        end
        
            filename = fullfile(pth, settings.backsubtractedDir, tg);
            if ~isdir(fullfile(pth, settings.backsubtractedDir))
                mkdir(fullfile(pth, settings.backsubtractedDir));
            end
            save(filename, 'nd', '-ascii');
            fprintf('%s%s%s is saved\n', settings.backsubtractedDir,filesep,tg);
    end

end