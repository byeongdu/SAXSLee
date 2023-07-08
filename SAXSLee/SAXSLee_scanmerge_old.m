function SAXSLee_scanmerge_old(varargin)
% SCANMERGE Called by SAXSLee to read scans from current plot to call mrgker
%   to merge scans.
%

hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
hAxes = findobj(hFigSAXSLee,'Tag','SAXSLee_Axes');
hLine = findobj(hAxes,'Type','line');

%hObject = findobj(0, 'Tag', 'toolbarMerge2');
%% This needs when the merge button is a toggle button instead of pushbutton.
% if ~strcmp(get(hObject, 'State'), 'on');
%     hLine = findall(hAxes,'Type','line');
%     
%     for mm = 1:numel(hLine)
%         if ~ischar(get(hLine(mm), 'MarkerFaceColor'))
%             if sum(get(hLine(mm), 'MarkerFaceColor')== [1,0,1])
%                  delete(hLine(mm));
%             end
%         end
%     end
%     curvelegend(hFigSAXSLee)
%     return
% end

%%
% --- get merge mode
settings = getappdata(hFigSAXSLee,'settings');
merge = settings.merge;

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


% % --- get tags of lines and remove datatipmarkers from hLine
% tempHLine = [];
% lineTags = {};
% for iLine = 1:length(hLine)
%     if ~strcmp(get(hLine(iLine),'Tag'),'DataTipMarker')
%         tempHLine(length(tempHLine)+1) = hLine(iLine);
%         lineTags{length(lineTags)+1} = get(hLine(iLine),'Tag');
%     end
% end
% hLine = tempHLine';
% lineTags = fliplr(lineTags);


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
for iLine = 1:Nhl
    tempHLine(iLine) = hLine2(iLine);
    lineTags{iLine} = get(hLine2(iLine),'Tag');
end
hLine = tempHLine';
%lineTags = fliplr(lineTags);



% --- extract x,y data, yerror, scan tags, xlable, ylabel, title from each plot
scanTag = {};
%scanData = {};
scanIndex = [];
%iLine = 0;
scanTagBS = {};
%scanDataBS = {};
scanIndexBS = [];
%iLineBS = 0;
%hSAXS = []; hWAXS = [];hnone = [];
isRef = ~cellfun('isempty', strfind(get(hLine,'Tag'), 'REF#'));
hRef = hLine(isRef);
hLine = hLine(~isRef);
lineTags(isRef) = [];
lTags = cellfun('length', lineTags);
switch Beamline
    case '12IDB'
        isTagNameSW = lTags > 2;
        oklineTags = lineTags(isTagNameSW);
        okhLine = hLine(isTagNameSW);
        isS = cellfun(@(x) x(1)=='S', oklineTags);
        hSAXS = okhLine(isS);
        isW = cellfun(@(x) x(1)=='W', oklineTags);
        hWAXS = okhLine(isW);
        hnone = hLine(~isTagNameSW);
        clear oklineTags okhLine
%         if ~isempty(fstr > 2)
%             switch fstr(1)
%                 case 'S'
%                     hSAXS = [hSAXS hLine(mm)];
%                 case 'W'
%                     hWAXS = [hWAXS hLine(mm)];    
%                 otherwise
%                     hnone = [hnone hLine(mm)];
%             end
%         else
%             hnone = [hnone hLine(mm)];
%         end
    otherwise
        hnone = hLine;
end

% for mm=1:length(hLine)
%     fstr = get(hLine(mm),'tag');
%     if ~isempty(strfind(fstr, 'REF#'))
%         hRef = [hRef hLine(mm)];
%     else
%         switch Beamline
%             case '12IDB'
%                 if ~isempty(fstr > 2)
%                     switch fstr(1)
%                         case 'S'
%                             hSAXS = [hSAXS hLine(mm)];
%                         case 'W'
%                             hWAXS = [hWAXS hLine(mm)];    
%                         otherwise
%                             hnone = [hnone hLine(mm)];
%                     end
%                 else
%                     hnone = [hnone hLine(mm)];
%                 end
%             case 'PLS9A'
%                 hnone = [hnone hLine(mm)];
%             otherwise
%                 hnone = [hnone hLine(mm)];
%         end
%     end
% end

%hLs{1} = hRef;
%hLs{2} = hSAXS;
%hLs{3} = hWAXS;
%hLs{4} = hnone;


switch Beamline
    case '12IDB'
        hLs{1} = hRef;
        hLs{2} = hSAXS;
        hLs{3} = hWAXS;
        hLs{4} = hnone;
    case 'PLS9A'
        hLs{1} = hRef;
        hLs{2} = hnone;
    otherwise
        hLs{1} = hRef;
        hLs{2} = hnone;
end


%xlabel_str = get(get(hAxes,'XLabel'),'String');
%ylabel_str = get(get(hAxes,'YLabel'),'String');

%cla(hAxes);

for kkk=2:4
    hLine = hLs{kkk};
    if length(hLine) < 1
        break
    end
    scanData = {};
    scanDataBS = {};
    iLineBS = 0;
    iLine = 0;
    
    ud = get(hLine(1), 'userdata');
    if ~isempty(ud)
        fnames = fieldnames(ud);
        for ifn=1:numel(fnames)
            ud.(fnames{ifn}) = [];
            udBS.(fnames{ifn}) = [];
        end
    else
        fnames = [];
        ud = [];
        udBS = [];
    end
    
    for mm = 1:length(hLine)
        xdata = get(hLine(mm),'xdata');
        ydata = get(hLine(mm),'ydata');
        ydataError = getappdata(hLine(mm),'yDataError');
        udata = get(hLine(mm), 'userdata');
        if SAXSLee_isbacksub(hLine(mm))
            iLineBS = iLineBS+1;
            scanTagBS{iLineBS} = get(hLine(mm),'tag');
            scanIndexBS = [scanIndexBS str2num(scanTagBS{iLineBS}(10:end))];
            scanDataBS{iLineBS} = [xdata(:) ydata(:) ydataError(:)];
            if ~isempty(udata)
                for ifn=1:numel(fnames)
                    udBS.(fnames{ifn}) = [udBS.(fnames{ifn}), udata.(fnames{ifn})];
                end
            end
        else
            % scan selected data... it does not has 
            iLine = iLine+1;
            scanTag{iLine} = get(hLine(mm),'tag');
            scanIndex = [scanIndex str2num(scanTag{iLine}(10:end))];
            scanData{iLine} = [xdata(:) ydata(:) ydataError(:)];
            if ~isempty(udata)
                for ifn=1:numel(fnames)
                    ud.(fnames{ifn}) = [ud.(fnames{ifn}), udata.(fnames{ifn})];
                end
            end
        end
    end
    %xlabel_str = get(get(hAxes,'XLabel'),'String');
    %ylabel_str = get(get(hAxes,'YLabel'),'String');
    %scanIndex = sort(scanIndex);
    %title_str = ['Merged scans ',num2str(scanIndex)];

% --- if merging failed do nothing

%try
    %mergeData = mrgker(scanData,merge);  % call mrgker function to merge scanData
isbsub = 0;
    %cla(hAxes);
    mergeData = SAXSLee_mrgker(scanData, merge);
    if ~isempty(ud)
        for ifn=1:numel(fnames)
            ud.(fnames{ifn}) = mean(ud.(fnames{ifn}));
        end
    end
    smerge(scanTag, isbsub, Beamline, kkk, settings, mergeData, fnames, ud);
    
    if ~isempty(scanDataBS)
        isbsub=1;
        scanData = scanDataBS;
        scanIndex = scanIndexBS;
        scanTag = scanTagBS;
        %iLine = iLineBS;
        mergeData = SAXSLee_mrgker(scanData, merge);
        if ~isempty(udBS)
            for ifn=1:numel(fnames)
                udBS.(fnames{ifn}) = mean(udBS.(fnames{ifn}));
            end
        end
        ud = udBS;
        smerge(scanTag, isbsub, Beamline, kkk, settings, mergeData, fnames, ud);
    end

    refscanplot;
    %settings.scan.selectionIndex = [];
    %settings.scan.selection = {};
    setappdata(hFigSAXSLee,'settings', settings);
    curvelegend(hFigSAXSLee);
    resettoolbar(hFigSAXSLee);
end


%catch
%    uiwait(msgbox('Merging failed. Check selected scans.','Merge Error','error','modal'));
%    return;
%end
function smerge(scanTag, isbsub, Beamline, kkk, settings, mergeData, fnames, ud)
loopend = 0;
for k=1:numel(scanTag{1});
    ss=scanTag{1}(k);
    if loopend == 1;
        break;
    end
    for cnti=2:numel(scanTag);
        tt = scanTag{cnti};
        if loopend == 1;
            break;
        end
        if ~strcmp(tt(k),ss);
            %TagIndx = k;
            loopend = 1;
        end
    end
end

%TagIndx = TagIndx - 1
% indx = findstr(scanTag{1}, '_');
indx2 = strfind(scanTag{1}, '.');
indspace = strfind(scanTag{1}, ' ');
TagIndx = [];
if ~isempty(indspace)
    TagIndx = indspace(end);
end
if isempty(TagIndx)
    indspace = strfind(scanTag{1}, '_');
    if ~isempty(indspace)
        TagIndx = indspace(end);
    end
end
if isempty(TagIndx)
    TagIndx = indx2;
end
fn = scanTag{1}(1:TagIndx-1);
indspace = strfind(fn, ' ');
fn(indspace) = '_';
% indx = [indx, indx2];
% NIndx = numel(scanTag{1});
% loopend = 0;
% if ~isempty(indx)
%     indx = unique(indx);
%     for kk=1:numel(indx)
%         if loopend == 1
%             break;
%         end
%         if indx(kk) < TagIndx
%             NIndx = indx(kk);
%         else
%             loopend = 1;
%         end
%     end
% end
% if NIndx < TagIndx
%     TagIndx = NIndx;
% end
% --- clear previous plot and plot merged data
if isbsub
    mergeLineTag = [fn,'.bsub_avg'];
else
    mergeLineTag = [fn,'.avg'];
end
%if length(scanIndex) == 1
%    mergeLineTag    = ['SAXSLeeMerge',num2str(scanIndex)];
%else
%    mergeLineTag    = ['SAXSLeeMerge',num2str(min(scanIndex)),'To',num2str(max(scanIndex))];
%end

switch Beamline
    case '12IDB'
        pth = settings.path;
%         switch kkk
%             case 2
%                 pth = [settings.path, filesep, 'SAXS'];
%             case 3
%                 pth = [settings.path, filesep, 'WAXS'];
%             case 4
%                 pth = settings.path;
%         end
        
    case 'PLS9A'
        pth = settings.path;
    otherwise
        pth = settings.path;
end

filename = fullfile(pth, settings.backsubtractedDir, mergeLineTag);
if ~isdir(fullfile(pth, settings.backsubtractedDir))
    mkdir(fullfile(pth, settings.backsubtractedDir));
end
nd = mergeData;

    fid = fopen(filename, 'w');
    if ~isempty(fnames)
        for conti = 1:numel(fnames)
            fprintf(fid, '%s\n', sprintf('%% %s : %0.3f', fnames{conti}, ud.(fnames{conti})));
        end
    end
    scanfilename = '';
    for ist = 1:numel(scanTag)
        scanfilename = sprintf('%s %s;', scanfilename, scanTag{ist});
    end
        
    fprintf(fid, '%% Filename : %s\n', scanfilename);
    fprintf(fid, '%% Date & Time : %s\n', datestr(now));

    fprintf(fid, '%% \n');
    fprintf(fid, '%% q(A^-1)   I(q)    sqrt(I(q))\n');
    fclose(fid);
    dlmwrite(filename, nd,'delimiter','\t','precision','%.8e', '-append');

%save(filename, 'nd', '-ascii');
%fprintf('%s%s%s is saved\n', settings.backsubtractedDir,filesep,mergeLineTag);
fprintf('%s is saved\n', filename);

%% This is needed when the merge button is a togglebutton.
% hNewLine = line('Parent',hAxes,...
%         'XData',mergeData(:,1)',...
%         'YData',mergeData(:,2)',...
%         'Tag',mergeLineTag);
%  %nd = mergeData;
% setappdata(hNewLine,'yDataError',mergeData(:,3));
% set(hNewLine,...
%     'Color','b',...
%     'LineStyle','-',...
%     'Marker','o',...
%     'MarkerSize',3,...
%     'MarkerFaceColor','m');
end

end