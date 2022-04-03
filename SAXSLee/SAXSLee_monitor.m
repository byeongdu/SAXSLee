function SAXSLee_monitor
% OPENSPEC Called by SAXSLee to load fids of scans in a selected spec file
%

hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
hToolbarMonitor = findobj(hFigSAXSLee,'Tag','toolbarMonitor');
%hToolbarMonitorAvg = findobj(hFigSAXSLee,'Tag','toolbarMonitorAvg');
hSAXSLeetimerMonitor   = timerfindobj('Tag','SAXSLeetimerMonitor');
delete(hSAXSLeetimerMonitor);
hToolbarLegend = findobj(hFigSAXSLee,'Tag','toolbarLegend');


if strcmp(get(hToolbarLegend, 'state'), 'on');
    %curvelegend(hFigSAXSLee);
    set(hToolbarLegend, 'state', 'off');
    legend off
end


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
    
% When auto azimuthal average is on, the monitor toolbar works passively,
% which means it functions like a radio button showing on or off.
% Then auto-plot will be done by the azimuthal average code, which is
% SAXSLee_autoazimuthalaverage.m
%
% When auto azimuthal average is off, this functions actively, meaning that
% it will run timer to load and plot.

%if strcmp(get(hToolbarMonitorAvg, 'state'), 'off')
if strcmp(get(hToolbarMonitor, 'state'), 'on')
    % turn legend off

    %if strcmp(get(hToolbarMonitor, 'state'), 'off')
    hSAXSLeetimerMonitor=timer('Tag','SAXSLeetimerMonitor');
    set(hSAXSLeetimerMonitor,'StartDelay', 1,...
        'TimerFcn', @SAXSLee_monitorFcn,...
        'ErrorFcn', @SAXSLee_monitorErrFcn,...
        'StartFcn', {@SAXSLeetimerMonitorStartFcn,hEnableGroup,initEnable},...
        'StopFcn',  {@SAXSLeetimerMonitorStopFcn,hEnableGroup,initEnable},...
        'ExecutionMode','FixedSpacing',...
        'BusyMode','drop',...
        'TasksToExecute',inf,...
        'Period',1);
    %    'Period',settings.monitorPeriod);
        
    %end
    %    set(hToolbarMonitor,'CData',icons.iconmonitor.pause);
%        SAXSLeetimerMonitorStartFcn(hEnableGroup,initEnable)
        start(hSAXSLeetimerMonitor);
else
%    set(hToolbarMonitor,'CData',icons.iconmonitor.play);
%       SAXSLeetimerMonitorStopFcn(hEnableGroup,initEnable)
    hSAXSLeetimerMonitor = timerfindobj('Tag', 'SAXSLeetimerMonitor');
    if ~isempty(hSAXSLeetimerMonitor)
        try
            stop(hSAXSLeetimerMonitor)
        catch
            
        end
        delete(hSAXSLeetimerMonitor);
    end
    return;
end
    



%================================================================
% --- scan monitor function
%================================================================
function SAXSLee_monitorFcn(varargin)

update_SAXSLee_openspec;


function SAXSLee_monitorErrFcn(varargin)
disp('ERRRRRR')
        
%================================================================
% --- start callback function of monitor timer
%================================================================
function SAXSLeetimerMonitorStartFcn(varargin)
hEnableGroup = varargin{3};
hFigSAXSLee = findobj('Tag','SAXSLee_Fig');
resettoolbar(hFigSAXSLee);
set(hEnableGroup,'Enable','off');
%SAXSLee_datalabel off

% % remove datalabels
% hdl = SAXSLee_findcursor('any');
% if ~isempty(hdl)
%     delete(hdl);
% end


%================================================================
% --- stop callback function of monitor timer
%================================================================
function SAXSLeetimerMonitorStopFcn(varargin)
hEnableGroup = varargin{3};
set(hEnableGroup,'Enable','on');
for i=1:length(hEnableGroup)
    set(hEnableGroup(i),'Enable','on');
end
%SAXSLee_datalabel on