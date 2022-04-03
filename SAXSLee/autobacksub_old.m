function autobacksub(varargin)
% autobacksub Called by SAXSLee to plot scans.
%
% Copyright 2004, Byeongdu Lee
% background subtraction option
% 0 (default) just subtract after correcting transmittance
% 1 based on WAXS (using WAXS data to normalize SAXS)
%   in this case, one needs to provide q range to integrate.
% settings.backsuboption
% settings.bascksubIntQrange

hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
hPopupmenuX = findall(hFigSAXSLee,'Tag','SAXSLee_PopupmenuX');
hPopupmenuY = findall(hFigSAXSLee,'Tag','SAXSLee_PopupmenuY');
hPopupmenuI0 = findall(hFigSAXSLee,'Tag','SAXSLee_PopupmenuI0');
hPopupmenuPlotStyle = findall(hFigSAXSLee,'Tag','SAXSLee_PopupmenuPlotStyle');
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
%settings = getappdata(hFigSAXSLee,'settings');
%settings = evalin('base', 'settings');
setall = evalin('base', 'setall');
Nsel = get(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'value');
settings = setall{Nsel};
%settings = getappdata(hFigSAXSLee,'settings');
backscan = getappdata(hFigSAXSLee,'backscan');

% --- set x, y axis labels
popupmenuXString = get(hPopupmenuX,'String');
popupmenuYString = get(hPopupmenuY,'String');
popupmenuXValue = get(hPopupmenuX,'Value');
popupmenuYValue = get(hPopupmenuY,'Value');
popupmenuI0Value = get(hPopupmenuI0,'string');
set(get(hAxes,'XLabel'),'String',popupmenuXString(popupmenuXValue));
set(get(hAxes,'YLabel'),'String',popupmenuYString(popupmenuYValue));

if isempty(backscan)
    disp('No reference file is selected')
    return
end

if isempty(backscan)
    disp('No background file is selected')
    disp('#1 in the backscan is empty')
    return
end

%hObject = findall(0, 'Tag', 'toolbarRefScan');
%if ~strcmp(get(hObject, 'State'), 'on');
%    return
%end

hObject = findall(0, 'Tag', 'toolbarAutobacksub');
if ~strcmp(get(hObject, 'State'), 'on');
    hLine = findall(hAxes,'Type','line');
    for mm = 1:numel(hLine)
         if SAXSLee_isbacksub(hLine(mm))
             delete(hLine(mm));
         end
    end
    curvelegend(hFigSAXSLee)
    return
end

%refscan = settings.refscan;
%backN = str2num(popupmenuYString(get(hPopupmenuY,'Value')));
backN = 1;   % number 1 is always background file.....

scan = settings.scan;
sfilen = scan.filen;
if isfield(settings, 'backsuboption');
    backsuboption = settings.backsuboption;
else
    backsuboption = 0;
end
if isfield(settings, 'backsubIntQrange');
    backsubIntQrange = settings.backsubIntQrange;
else
    backsubIntQrange = [];
end


%if strcmp(get(hAxes, 'Nextplot'), 'replace')
%    cla(hAxes);
%    NoldL = 0;
%else
NoldL = numel(findobj(hAxes, 'type', 'line'));
%end

trans = str2double(popupmenuI0Value);

backN = 1;




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







%try
if ~isempty(scan.selectionIndex)
    for iSelection = 1:numel(scan.selectionIndex)
    % --- if ydata has negative data,then ydataError = 0
%        if ~SAXSLee_isbacksub(hLine(iSelection))
        if backsuboption == 0;
            xd = scan.selection{iSelection}.colData(:,1);
            yd = scan.selection{iSelection}.colData(:,2);
            zd = scan.selection{iSelection}.colData(:,3);
            tg = [scan.selection{iSelection}.Tag, '_bsub'];
            %tg = [sfilen{scan.selectionIndex(iSelection)}, '_bsub'];
            bx = backscan.colData(:,1);
            by = backscan.colData(:,2);
            bz = backscan.colData(:,3);
     % Background subtraction 
            [nn, nd] = backsub(xd, yd, zd, trans, tg, bx, by, bz);
            hLine(iSelection) = nn;
            plotoption(hLine(iSelection), 6+iSelection + NoldL);
            dataType = 'SAXS';
            savedata
            if isfield(scan.selection{iSelection}, 'colWData')
                xd = scan.selection{iSelection}.colWData(:,1);
                yd = scan.selection{iSelection}.colWData(:,2);
                zd = scan.selection{iSelection}.colWData(:,3);
                tg = [scan.selection{iSelection}.WTag, '_bsub'];
                %tg = [sfilen{scan.selectionIndex(iSelection)}, '_bsub'];
                bx = backscan.colWData(:,1);
                by = backscan.colWData(:,2);
                bz = backscan.colWData(:,3);
         % Background subtraction 
                [nn, nd] = backsub(xd, yd, zd, trans, tg, bx, by, bz);
                hLine(iSelection) = nn;
                plotoption(hLine(iSelection), 6+iSelection + NoldL);
                dataType = 'WAXS';
                savedata
            end
        else
            bx = backscan.colWData(:,1);
            by = backscan.colWData(:,2);
            bz = backscan.colWData(:,3);
            backNom = integrateq(bx, by, backsubIntQrange);
            xd = scan.selection{iSelection}.colWData(:,1);
            yd = scan.selection{iSelection}.colWData(:,2);
            zd = scan.selection{iSelection}.colWData(:,3);
            backWNom = integrateq(xd, yd, backsubIntQrange);
            tg = [scan.selection{iSelection}.WTag, '_bsub'];
            [nn, nd] = backsub(xd, yd, zd, backWNom/backNom, tg, bx, by, bz);
            hLine(iSelection) = nn;
            plotoption(hLine(iSelection), 6+iSelection + NoldL);
            dataType = 'WAXS';
            savedata

            bx = backscan.colData(:,1);
            by = backscan.colData(:,2);
            bz = backscan.colData(:,3);

            xd = scan.selection{iSelection}.colData(:,1);
            yd = scan.selection{iSelection}.colData(:,2);
            zd = scan.selection{iSelection}.colData(:,3);
            %tg = [sfilen{scan.selectionIndex(iSelection)}, '_bsub'];
            tg = [scan.selection{iSelection}.Tag, '_bsub'];
            %setappdata(hLine(iSelection),'ydataError',ydataError);
            [nn, nd] = backsub(xd, yd, zd, backWNom/backNom, tg, bx, by, bz);
            hLine(iSelection) = nn;
            plotoption(hLine(iSelection), 6+iSelection + NoldL);
            dataType = 'SAXS';
            savedata
        end
%        end
    end
else
    hLine = findall(hAxes,'Type','line');
% --- get tags of lines and remove datatipmarkers from hLine
    tempHLine = [];
    lineTags = {};
    for iLine = 1:length(hLine)
        if ~strcmp(get(hLine(iLine),'Tag'),'DataTipMarker')
            tempHLine(length(tempHLine)+1) = hLine(iLine);
            lineTags{length(lineTags)+1} = get(hLine(iLine),'Tag');
        end
    end
    hLine = tempHLine';
    lineTags = fliplr(lineTags);

% --- extract x,y data, yerror, scan tags, xlable, ylabel, title from each plot
    scanTag = {};
    scanData = {};
    scanIndex = [];
    iLine = 0;
    for mm = 1:length(hLine)
        if isempty(findstr(get(hLine(mm),'tag'), 'REF#'))
            if ~SAXSLee_isbacksub(hLine(mm))
                iLine = iLine+1;
                xd = get(hLine(mm),'xdata');
                yd = get(hLine(mm),'ydata');
                zd = getappdata(hLine(mm),'yDataError');
                tg = [get(hLine(mm),'tag'), '_bsub'];
                bx = backscan.colData(:,1);
                by = backscan.colData(:,2);
                bz = backscan.colData(:,3);
            
                [hLine(mm), nd] = backsub(xd, yd, zd, trans, tg, bx, by, bz);
                plotoption(hLine(mm), 6+mm + NoldL);
                dataType = '';
                savedata
            end
        end
    end
end    
%catch
    
    
%end
    function [hdl, nd] = backsub(xd, yd, zd, trans, tg, bx, by, bz)
            xd = xd(:);
            yd = yd(:);
            zd = zd(:);
            if numel(yd) == numel(by)
                yd = yd - trans*by;
                zd = sqrt(zd.^2 + bz.^2);
            else
                by2 = interp1(bx, by, xd);
                bz2 = interp1(bx, bz, xd);
                yd = yd - trans*by2;
                zd = sqrt(zd.^2 + bz2.^2);
            end
            

            hdl = line('Parent',hAxes,...
                'XData',xd,...
                'YData',yd,...
                'Tag',tg);
            setappdata(hdl, 'yDataError', zd);
            setappdata(hdl, 'isbacksubtracted', 1);
            nd = [xd, yd, zd];
            setappdata(hdl, 'isbacksubtracted', 1);
    end

    function savedata
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
