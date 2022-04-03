function SAXSLee_monitorscan
% OPENSPEC Called by SAXSLee to load fids of scans in a selected spec file
%

hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
hToolbarMonitor = findobj(hFigSAXSLee,'Tag','toolbarMonitor');
hSAXSLeetimerMonitor   = timerfindobj('Tag','SAXSLeetimerMonitor');
hToolbarLegend = findobj(hFigSAXSLee,'Tag','toolbarLegend');

% turn legend off
if strcmp(get(hToolbarLegend, 'state'), 'on');
    %curvelegend(hFigSAXSLee);
    set(hToolbarLegend, 'state', 'off');
    legend off
end

% --- get setttings
settings = getappdata(hFigSAXSLee,'settings');
setall = evalin('base', 'setall');
setN = get(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'value');
file = setall{setN}.file;
scan = setall{setN}.scan;
%file = settings.file;
%scan = settings.scan;

% --- get initial 'enable' property of menus,toolbars and pushbuttons 
hEnableGroup  = [...
    findobj(hFigSAXSLee,'Tag','SAXSLee_MenuTools');...
    findobj(hFigSAXSLee,'Tag','SAXSLee_MenuFile');...
    findobj(hFigSAXSLee,'Tag','toolbarOpen');...
    findobj(hFigSAXSLee,'Tag','toolbarSave');...
    findobj(hFigSAXSLee,'Tag','toolbarPrint');...
    findobj(hFigSAXSLee,'Tag','toolbarEditPlot');...
    %findobj(hFigSAXSLee,'Tag','toolbarZoom');...
    findobj(hFigSAXSLee,'Tag','toolbarDataCursor');...
    findobj(hFigSAXSLee,'Tag','toolbarLegend');...
    findobj(hFigSAXSLee,'Tag','toolbarPlottoolsOff');...
    %findobj(hFigSAXSLee,'Tag','toolbarPlottoolsOn');...
    findobj(hFigSAXSLee,'Tag','toolbarInvert');...
    findobj(hFigSAXSLee,'Tag','toolbarMerge');...
    findobj(hFigSAXSLee,'Tag','toolbarConvert');...
    findobj(hFigSAXSLee,'Tag','toolbarFootprint');...
    %findobj(hFigSAXSLee,'Tag','SAXSLee_PushbuttonSelectScan');...
    ];
initEnable = get(hEnableGroup,'Enable');

if isempty(file) | isempty(scan.fidPos)
    set(hToolbarMonitor,'state','off');
    return;    
end

icons = load('SG_icons.mat');
if strcmp(get(hToolbarMonitor,'state'),'on');
    set(hToolbarMonitor,'CData',icons.iconmonitor.pause);
else
    set(hToolbarMonitor,'CData',icons.iconmonitor.play);
    if ~isempty(hSAXSLeetimerMonitor)
        if isvalid(hSAXSLeetimerMonitor)
            stop(hSAXSLeetimerMonitor);
        end
        delete(hSAXSLeetimerMonitor);
    end
    return;
end


% --- set and start timer
hSAXSLeetimerMonitor=timer('Tag','SAXSLeetimerMonitor');
set(hSAXSLeetimerMonitor,'StartDelay', 1,...
    'TimerFcn', @SAXSLeetimerMonitorFcn,...
    'StartFcn', {@SAXSLeetimerMonitorStartFcn,hEnableGroup,initEnable},...
    'StopFcn',  {@SAXSLeetimerMonitorStopFcn,hEnableGroup,initEnable},...
    'ExecutionMode','fixedRate',...
    'BusyMode','drop',...
    'TasksToExecute',inf,...
    'Period',settings.monitorPeriod);
start(hSAXSLeetimerMonitor);

%================================================================
% --- callback function of monitor timer
%================================================================
function SAXSLeetimerMonitorFcn(hObject,eventdata)
hFigSAXSLee = findobj(0,'Tag','SAXSLee_Fig');
% hSAXSLeetimerMonitor   = timerfind('Tag','SAXSLeetimerMonitor');
% hPopupmenuX = findobj(hFigSAXSLee,'Tag','SAXSLee_PopupmenuX');
% hPopupmenuY = findobj(hFigSAXSLee,'Tag','SAXSLee_PopupmenuY');
settings = getappdata(hFigSAXSLee,'settings');
file = settings.file;
scan = settings.scan;

% --- check dynamically if there are more scans added to spec file
fid = fopen(file);
fseek(fid,scan.fidPos(end),'bof');  % move fid to end of the last stored scan
%scanline = fgetl(fid);      % skip the currentline (head of the last stored scan);
flagNewScan = 0;
%settings.oldfileN = numel(settings.scan.filen);
oldfileN = numel(scan.filen);

while feof(fid) == 0
    tempfid = ftell(fid);
    scanline = fgetl(fid);
    fl = sscanf(scanline, '#Z %s', 1);
    if ~isempty(fl)
        [~, RR] = strtok(scanline, '#Z ');
        kk = strfind(RR, ' '); 
        date = RR(kk(end-5):kk(end-1)); % read date
        
        %if flag == 1
        %    break;
        %end
        scan.fidPos = [scan.fidPos,tempfid];
        %numel(scan.fidPos), 
        nf = numel(scan.filen);
        scan.filen{nf+1} = fl;
        scan.date{nf+1} = date;
        flagNewScan = 1;
    end
end
fclose(fid);

newfileN = numel(scan.filen);
settings.scan = scan;
%setappdata(hFigSAXSLee,'settings',settings);
%settings = getappdata(hFigSAXSLee,'settings');
selection = length(scan.fidPos);
scan.selection = cell(length(selection),1);
scan.selectionIndex = selection;        % store the selected scan index
settings.scan = scan;

setappdata(hFigSAXSLee,'settings',settings);
settings = getappdata(hFigSAXSLee,'settings');

%if get(hSAXSLeetimerMonitor,'TasksExecuted') == 1 && flagNewScan == 1;
if flagNewScan == 1;
    for t = (oldfileN+1):newfileN
        fn = settings.scan.filen{t};
        
        for mm = 1:1000
            
        end
        
        cdir = pwd;
        eval(['cd ', settings.path]);
        
        t = dir(fn);
        timeout = 0;isfileok = 1;
        while isempty(t)
            t = dir(fn);
            if timeout > 100
                isfileok = 0;
                break
            end
            timeout = timeout + 1;
        end
        
        if isfileok == 1
            isfileok = 0;timeout = 1;
            while ~isfileok
                try
                    pp = imread(fn);
                    isfileok = 1;
                    break
                catch
                    isfileok = 0;
                end
                if timeout > 100
                    isfileok = 0;
                    break
                end
                timeout = timeout + 1;
            end
        end
        if isfileok ~= 1
            break
        end
        strcmd = sprintf('%s %s %s', settings.averageCmd, file, fn);
        system(strcmd);
        eval(['cd ', cdir]);
        
        fnload = fullfile(settings.path, settings.averageDir, fn);
        a = [];
        a = dir(fnload);cnt = 0 ;
        while (~isempty(a) && (cnt < 2))
            a = dir(fnload);
            cnt = cnt + 1;
            for kkk=1:1000;
            end
        end
     
        %try
            SAXSLee_scanplot;
        %catch
        %end
    end
end
%================================================================
% --- start callback function of monitor timer
%================================================================
function SAXSLeetimerMonitorStartFcn(varargin)
hEnableGroup = varargin{3};
hFigSAXSLee = findobj('Tag','SAXSLee_Fig');
resettoolbar(hFigSAXSLee);
set(hEnableGroup,'Enable','off');
SAXSLee_datalabel off

% remove datalabels
hdl = SAXSLee_findcursor('any');
if ~isempty(hdl)
    delete(hdl);
end


%================================================================
% --- stop callback function of monitor timer
%================================================================
function SAXSLeetimerMonitorStopFcn(varargin)
hEnableGroup = varargin{3};
initEnable = varargin{4};
for i=1:length(hEnableGroup)
    set(hEnableGroup(i),'Enable',initEnable{i});
end
SAXSLee_datalabel on

