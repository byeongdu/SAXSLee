function resetfigSAXSLee(varargin)
% Reset all the plots in SAXSLee
hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
hPopupmenuX = findall(hFigSAXSLee,'Tag','SAXSLee_PopupmenuX');
hPopupmenuY = findall(hFigSAXSLee,'Tag','SAXSLee_PopupmenuY');
hPopupmenuPlotStyle = findall(hFigSAXSLee,'Tag','SAXSLee_PopupmenuPlotStyle');
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
settings = getappdata(hFigSAXSLee,'settings');

resettoolbar(hFigSAXSLee);
cla(hAxes);
%set(hPopupmenuX,'String','X Axis','Value',1);
%set(hPopupmenuY,'String','Y Axis','Value',1);

file = settings.file;
[filepath,filename,fileext] = fileparts(file);
set(hAxes,'Title',text('String',['File: ',titlestr([filename,fileext])]));
set(hAxes,'XLabel',text('String',''));
set(hAxes,'YLabel',text('String',''));
set(hFigSAXSLee,'Name',['SAXSLee - ',filename,fileext]);

hTimerMonitor   = timerfindall('Tag','SAXSLeetimerMonitor');
if ~isempty(hTimerMonitor)
    if isvalid(hTimerMonitor)
        stop(hTimerMonitor);
    end
    delete(hTimerMonitor);
end