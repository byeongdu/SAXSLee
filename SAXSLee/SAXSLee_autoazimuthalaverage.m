function SAXSLee_autoazimuthalaverage
% OPENSPEC Called by SAXSLee to load fids of scans in a selected spec file
%
% In order to use this function at 12ID-B station,
% SAXSWAXSfiletransfer.m should be running independently. The function will
% automatically transfer the measured data.

hFigSAXSLee = findobj('Tag','SAXSLee_Fig');
hToolbarMonitor = findobj(hFigSAXSLee,'Tag','toolbarMonitorAvg');
hSAXSLeetimerAzimAvg   = timerfindobj('Tag','SAXSLeetimerAzimAvg');
hToolbarAutoImageOn = findobj(hFigSAXSLee,'Tag','hToolbarAutoImageOn');
%saxsimageviewerhandle = findobj( 'tag', 'SAXSImageViewer');

% --- get setttings
%settings = getappdata(hFigSAXSLee,'settings');
%file = settings.file;
%scan = settings.scan;
Nsel = get(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'value');
%setall = getappdata(hFigSAXSLee,'setall');
%settings.Nsel = Nsel;
%settings.scan.filen = setall{Nsel}.scan.filen;
setappdata(hFigSAXSLee, 'insituNsel', Nsel);
%setall = getappdata(hFigSAXSLee,'setall');
setall = evalin('base', 'setall');
%settings.file

settings = setall{Nsel};
file = settings.file;
scan = settings.scan;


if isempty(file) | isempty(scan.fidPos)
    set(hToolbarMonitor,'state','off');
    return;    
end

icons = load('SG_icons.mat');
if strcmp(get(hToolbarMonitor,'state'),'on');
    set(hToolbarMonitor,'CData',icons.iconmonitor.pause);
else
    set(hToolbarMonitor,'CData',icons.iconmonitor.play);
    if ~isempty(hSAXSLeetimerAzimAvg)
        if isvalid(hSAXSLeetimerAzimAvg)
            stop(hSAXSLeetimerAzimAvg);
        end
        delete(hSAXSLeetimerAzimAvg);
    end
    return;
end
hEnableGroup = {};
initEnable = 1 ;
% --- set and start timer
hSAXSLeetimerAzimAvg=timer('Tag','SAXSLeetimerAzimAvg');
set(hSAXSLeetimerAzimAvg,'StartDelay', 1,...
    'TimerFcn', @SAXSLeetimerAzimAvgFcn,...
    'StartFcn', {@SAXSLeetimerAzimAvgStartFcn,hEnableGroup,initEnable},...
    'StopFcn',  {@SAXSLeetimerAzimAvgStopFcn,hEnableGroup,initEnable},...
    'ExecutionMode','fixedRate',...
    'BusyMode','drop',...
    'TasksToExecute',inf,...
    'Period',1);
%    'Period',settings.monitorPeriod);
start(hSAXSLeetimerAzimAvg);

%================================================================
% --- callback function of monitor timer
%================================================================
function SAXSLeetimerAzimAvgFcn(hObject,eventdata)
hFigSAXSLee = findobj('Tag','SAXSLee_Fig');
hSAXSLeetimerAzimAvg   = timerfind('Tag','SAXSLeetimerAzimAvg');
hPopupmenuX = findobj(hFigSAXSLee,'Tag','SAXSLee_PopupmenuX');
hPopupmenuY = findobj(hFigSAXSLee,'Tag','SAXSLee_PopupmenuY');
Nsel = getappdata(hFigSAXSLee, 'insituNsel');
saxsimageviewerhandle = evalin('base', 'SAXSimageviewerhandle');
hToolbarAutoImageOn = findobj(hFigSAXSLee,'Tag','hToolbarAutoImageOn');



%settings = getappdata(hFigSAXSLee,'settings');
%file = settings.file;
%scan = settings.scan;
setall = getappdata(hFigSAXSLee,'setall');
file = setall{Nsel}.file;
scan = setall{Nsel}.scan;
imagepath = setall{Nsel}.rootDir;
averagedpath = fullfile(setall{Nsel}.rootDir, setall{Nsel}.averageDir);

flagNewScan = 0;
oldfileN = numel(scan.filen);

switch setall{Nsel}.automethod
    
    case 1 % spec file
% --- check dynamically if there are more scans added to spec file
        [fid,message] = fopen(file);
        fseek(fid,scan.fidPos(end),'bof');  % move fid to end of the last stored scan
        scanline = fgetl(fid);      % skip the currentline (head of the last stored scan);
        
        while feof(fid) == 0
            tempfid = ftell(fid);
            scanline = fgetl(fid);
            [fl, num] = sscanf(scanline, '#Z %s', 1);
            if ~isempty(fl)
                [T, RR] = strtok(scanline, '#Z ');
                kk = findstr(RR, ' '); 
                date = RR(kk(end-5):kk(end-1)); % read date

                scan.fidPos = [scan.fidPos,tempfid];
                nf = numel(scan.filen);
                scan.filen{nf+1} = fl;
                scan.date{nf+1} = date;
                flagNewScan = 1;
            end
        end
        fclose(fid);
        newfileN = numel(scan.filen);
        selection = length(scan.fidPos);
        scan.selection = cell(length(selection),1);
        scan.selectionIndex = selection;        % store the selected scan index

    case 2
        if isempty(findstr(file, 'LoadImageDir'))
            error('Error in SAXSLee_autoazimuthalavg.m, and there is no LoadImageDir')
            return
        end
        [FileList, scan] = listFileinDir(imagepath, setall{Nsel}.imageListString, 'date');
        newfileN = numel(scan.filen);
        if newfileN > oldfileN
            flagNewScan = 1;
        end
        scan.fidPos = numel(scan);
        selection = numel(FileList);
        scan.selection = {};
        scan.selectionIndex = selection;        % store the selected scan index
end
        

setall{Nsel}.scan = scan;
setappdata(hFigSAXSLee,'setall',setall);
assignin('base', 'setall', setall);
%setappdata(hFigSAXSLee,'settings',settings);
%settings = getappdata(hFigSAXSLee,'settings');

%if get(hSAXSLeetimerMonitor,'TasksExecuted') == 1 && flagNewScan == 1;
if flagNewScan == 1;
    for t = (oldfileN+1):newfileN
        fn = setall{Nsel}.scan.filen{t};
      
        pause(1)
        cdir = pwd;
        %eval(['cd ', settings.path]);
        eval(['cd ', setall{Nsel}.path]);
%        t = dir(fn);
        isfileok = 0;
        timeout = 0;
%        pause(1);

% Stop timer................
stop(hSAXSLeetimerAzimAvg)
crd = pwd;
      while ~isfileok
            mtest = fopen(fn);
            if mtest > 0
                isfileok = 1;
                fclose(mtest);
                break
            else
                cd ..
                pause(0.5);
                eval(sprintf('cd %s', crd));
                
                if timeout > 10
                    pause(0.5);
                end
                isfileok = 0;
                timeout = timeout + 1;
            end
            if timeout > 20
                fprintf('%s does not exist yet after 20 times of trial', fn);
                break;
            end
      end

      % you can check whether fn is an image or not.. 
      % for MarCCD image, often it is an temporary file for a short period
      % of time after data taken....
      
        if isfileok ~= 1
            fprintf('There is a problem with the file, %s.', fn);
            break
        end
        
        %strcmd = sprintf('%s %s %s', settings.averageCmd, file, fn);

        pause(1);
        
        switch setall{Nsel}.average.mode  % average method
            case 1          % using linux goldnormavg....
                strcmd = sprintf('%s %s %s', setall{Nsel}.averageCmd, file, fn);
                system(strcmd);
                eval(['cd ', cdir]);
            case 2              % using tools of SAXSimageviewer/GISAXSLeenew/saxsaverage
                ff{1} = imagepath;
                ff{2} = fn;
                saxsaverage('doaverage', {}, {}, {}, ff);
                eval(['cd ', cdir]);
        end
        
    % if hToolbarAutoImageOn is clicked, the following will push image to
    % SAXSimageviewer.
    if ~isempty(saxsimageviewerhandle) && ~strcmp(get(hToolbarAutoImageOn, 'State'), 'off')
        fn2 = fullfile(imagepath, fn);
        SAXSimageviewer(fn2);
    end

start(hSAXSLeetimerAzimAvg)    
    
    % if ToolbarMonitor is clicked, the following code will push to plot.    
    hToolbarMonitor = findobj(hFigSAXSLee,'Tag','toolbarMonitor');
    if strcmp(get(hToolbarMonitor, 'state'), 'on');   % if in-situ plot is selected....
        %settings = setall{Nsel};
        fnload = fullfile(averagedpath, fn);
        a = [];a = dir(fnload);cnt = 0 ;
        while (~isempty(a) && (cnt < 2))
            a = dir(fnload);
            cnt = cnt + 1;
            for kkk=1:1000;
            end
        end
        SAXSLee_scanplot;
    end
    end
end
%================================================================
% --- start callback function of monitor timer
%================================================================
function SAXSLeetimerAzimAvgStartFcn(hObject,eventdata,hEnableGroup,initEnable)
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
function SAXSLeetimerAzimAvgStopFcn(hObject,eventdata,hEnableGroup,initEnable)
for i=1:length(hEnableGroup)
    set(hEnableGroup(i),'Enable',initEnable{i});
end
SAXSLee_datalabel on