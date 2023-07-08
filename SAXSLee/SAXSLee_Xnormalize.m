function varargout = SAXSLee_Xnormalize(varargin)
% SAXSLEE_XNORMALIZE M-file for SAXSLee_Xnormalize.fig
%      SAXSLEE_XNORMALIZE, by itself, creates a new SAXSLEE_XNORMALIZE or raises the existing
%      singleton*.
%
%      H = SAXSLEE_XNORMALIZE returns the handle to a new SAXSLEE_XNORMALIZE or the handle to
%      the existing singleton*.
%
%      SAXSLEE_XNORMALIZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAXSLEE_XNORMALIZE.M with the given input arguments.
%
%      SAXSLEE_XNORMALIZE('Property','Value',...) creates a new SAXSLEE_XNORMALIZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SAXSLee_Xnormalize_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SAXSLee_Xnormalize_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SAXSLee_Xnormalize

% Last Modified by GUIDE v2.5 05-Jan-2011 00:17:59

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SAXSLee_Xnormalize_OpeningFcn, ...
                   'gui_OutputFcn',  @SAXSLee_Xnormalize_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% End initialization code - DO NOT EDIT

% --- Executes just before SAXSLee_Xnormalize is made visible.
function SAXSLee_Xnormalize_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SAXSLee_Xnormalize (see VARARGIN)

% Choose default command line output for SAXSLee_Xnormalize
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using SAXSLee_Xnormalize.
if strcmp(get(hObject,'Visible'),'off')
    check_normcondition(handles);
end

% UIWAIT makes SAXSLee_Xnormalize wait for user response (see UIRESUME)
% uiwait(handles.SAXSLee_xnormalize);


% --- Outputs from this function are returned to the command line.
function varargout = SAXSLee_Xnormalize_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pb_donormalize.
function pb_donormalize_Callback(hObject, eventdata, handles)
% hObject    handle to pb_donormalize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

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


obj1 = handles.pm_whichcurve;
obj2 = handles.pm_bywhichvalue;
%contents = cellstr(get(obj,'String'));
%selby = contents{get(obj,'Value')};
sel1 = get(obj1,'Value');

switch sel1
    case 1
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
            if isempty(findstr(get(hLine(mm),'tag'), 'REF#'))
                hdl = [hdl, hLine(mm)];
                %xd = get(hLine(mm),'xdata');
                %yd = get(hLine(mm),'ydata');
                %zd = getappdata(hLine(mm),'yDataError');
                %tg = [get(hLine(mm),'tag'), '_bsub'];
                %[hLine(mm), nd] = backsub(xd, yd, zd, trans, tg, bx, by, bz);
                %plotoption(hLine(mm), 6+mm + NoldL);
                %savedata
            end
        end
    case 2
        [hdl, indx, xd, yd, data] = SAXSLee_findcursor;
        hdl = unique(hdl);
end
        
sel2 = get(obj2,'Value');
switch sel2
    case 1
        normval = str2double(get(handles.edit1, 'string'));
    case 2
        normval = str2double(get(handles.edit1, 'string'));
end

for i = 1:numel(hdl)
    xd = get(hdl(i), 'xdata');
    yd = get(hdl(i), 'ydata');
    zd = getappdata(hdl(i),'yDataError');
    
    % normalize
    if (sel2 == 1) || (sel2 == 2)
        normv = getappdata(hdl(i), 'normval');
        if isempty(normv) 
            normv = 1;
        end
        if normv == 0
            normv = 1;
        end
        normval = normv * normval;
        setappdata(hdl(i), 'normval', normval);
    else
        setappdata(hdl(i), 'normval', normval);
    end
    xd = xd/normval;
        
    set(hdl(i), 'xdata', xd);
    %savedata???
    nd = [xd(:), yd(:), zd(:)];
    tg = get(hdl(i),'tag');
    savedata(SAXSLeepath, nd, tg, normval);
end
            

function savedata(SAXSLeepath, nd, tg, normval)
    % save data
    filename = fullfile(SAXSLeepath, 'userXNorm', tg);
    if ~isdir(fullfile(SAXSLeepath, 'userXNorm'))
        mkdir(fullfile(SAXSLeepath, 'userXNorm'));
    end
    save(filename, 'nd', '-ascii');
    fprintf('%s%s%s is normlized by q = %f, and saved\n', 'userXNorm',filesep,tg, normval);


% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.SAXSLee_xnormalize)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.SAXSLee_xnormalize,'Name') '?'],...
                     ['Close ' get(handles.SAXSLee_xnormalize,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.SAXSLee_xnormalize)


% --- Executes on selection change in pm_whichcurve.
function pm_whichcurve_Callback(hObject, eventdata, handles)
% hObject    handle to pm_whichcurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pm_whichcurve contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_whichcurve


% --- Executes during object creation, after setting all properties.
function pm_whichcurve_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_whichcurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'All curves', 'Selected with cursor(s)'});


% --- Executes on selection change in pm_bywhichvalue.
function pm_bywhichvalue_Callback(hObject, eventdata, handles)
% hObject    handle to pm_bywhichvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_bywhichvalue contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_bywhichvalue
check_normcondition(handles);

% --- Executes during object creation, after setting all properties.
function pm_bywhichvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_bywhichvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'Number (put a number)'...
    , 'q at a cursor'...
    });

%check_normcondition(handles);


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_loadfile.
function pb_loadfile_Callback(hObject, eventdata, handles)
% hObject    handle to pb_loadfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


if strcmp(get(hObject, 'string'), 'Load')
    [filename, filepath] = uigetfile( ...
    {'*.*','All Files (*.*)'}, ...
    'Select Spec File');
    % If "Cancel" is selected then return
    if isequal([filename,filepath],[0,0])
        restorePath(prePath);
        return
    end
    
    % Otherwise construct the fullfilename and Check and load the file.
    specfile = fullfile(filepath,filename);
    [fid,message] = fopen(specfile,'r');        % open file
    if fid == -1                % return if open fails
        uiwait(msgbox(message,'File Open Error','error','modal'));
        % fclose(fid);
        restorePath(prePath);
        return;
    end
    fclose(fid);
    setappdata(gcf, 'normfile', specfile);
end


if strfind(get(hObject,'string'), 'Read cursor')
    [hdl, indx, xd, yd, data] = SAXSLee_findcursor;
    if numel(hdl) == 0
        disp('No cursor')
        return
    elseif numel(xd) == 1
        set(handles.edit1, 'string', num2str(xd));
        set(handles.edit2, 'string', '');
    elseif numel(xd) == 2
        csr = sort(xd);
        set(handles.edit1, 'string', num2str(csr(1)));
        set(handles.edit2, 'string', num2str(csr(2)));
    elseif numel(xd) > 2
        disp('Too many cursor')
        return
    end
end


function check_normcondition(varargin)
handles = varargin{1};
obj = handles.pm_bywhichvalue;
contents = cellstr(get(obj,'String'));
%selby = contents{get(obj,'Value')};
selby = get(obj,'Value');

set(handles.pb_loadfile, 'visible', 'off');
set(handles.text0, 'visible', 'off');
set(handles.edit1, 'enable', 'off');
set(handles.edit2, 'enable', 'off');

switch selby
    case 1
        set(handles.edit1, 'enable', 'on');
    case 2
        set(handles.edit1, 'enable', 'on');
        set(handles.pb_loadfile, 'visible', 'on');
        set(handles.pb_loadfile, 'string', 'Read cursor');        
        
end


% --- Executes on button press in pb_undo.
function pb_undo_Callback(hObject, eventdata, handles)
% hObject    handle to pb_undo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
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


obj1 = handles.pm_whichcurve;
obj2 = handles.pm_bywhichvalue;
%contents = cellstr(get(obj,'String'));
%selby = contents{get(obj,'Value')};
sel1 = get(obj1,'Value');

switch sel1
    case 1
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
            if isempty(findstr(get(hLine(mm),'tag'), 'REF#'))
                hdl = [hdl, hLine(mm)];
                %xd = get(hLine(mm),'xdata');
                %yd = get(hLine(mm),'ydata');
                %zd = getappdata(hLine(mm),'yDataError');
                %tg = [get(hLine(mm),'tag'), '_bsub'];
                %[hLine(mm), nd] = backsub(xd, yd, zd, trans, tg, bx, by, bz);
                %plotoption(hLine(mm), 6+mm + NoldL);
                %savedata
            end
        end
    case 2
        [hdl, indx, xd, yd, data] = SAXSLee_findcursor;
        hdl = unique(hdl);
end
        
sel2 = get(obj2,'Value');

for i = 1:numel(hdl)
    xd = get(hdl(i), 'xdata');
    yd = get(hdl(i), 'ydata');
    zd = getappdata(hdl(i),'yDataError');
    
    % normalize
    if (sel2 == 1) || (sel2 == 2)
        normv = getappdata(hdl(i), 'normval');
        if isempty(normv) 
            normv = 1;
        end
        if normv == 0
            normv = 1;
        end
        normval = normv;
        setappdata(hdl(i), 'normval', 1);
    else
        setappdata(hdl(i), 'normval', 1);
    end
    xd = xd*normval;
        
    set(hdl(i), 'xdata', xd);
    %savedata???
    nd = [xd(:), yd(:), zd(:)];
    tg = get(hdl(i),'tag');
    savedata(SAXSLeepath, nd, tg, normval);
end

% --- Executes on button press in pb_xscale.
function pb_xscale_Callback(hObject, eventdata, handles)
% hObject    handle to pb_xscale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
obj1 = handles.pm_whichcurve;
sel1 = get(obj1,'Value');

switch sel1
    case 1
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
            if isempty(findstr(get(hLine(mm),'tag'), 'REF#'))
                hdl = [hdl, hLine(mm)];
            end
        end
    case 2
        [hdl, indx, xd, yd, data] = SAXSLee_findcursor;
        hdl = unique(hdl);
end

normv = getappdata(hdl(1), 'normval');
xlim = get(hAxes, 'xlim');
xlim = xlim/normv;
set(hAxes, 'xlim', xlim);