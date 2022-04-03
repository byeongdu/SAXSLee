function varargout = SAXSLee_normalize(varargin)
% SAXSLEE_NORMALIZE M-file for SAXSLee_normalize.fig
%      SAXSLEE_NORMALIZE, by itself, creates a new SAXSLEE_NORMALIZE or raises the existing
%      singleton*.
%
%      H = SAXSLEE_NORMALIZE returns the handle to a new SAXSLEE_NORMALIZE or the handle to
%      the existing singleton*.
%
%      SAXSLEE_NORMALIZE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAXSLEE_NORMALIZE.M with the given input arguments.
%
%      SAXSLEE_NORMALIZE('Property','Value',...) creates a new SAXSLEE_NORMALIZE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SAXSLee_normalize_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SAXSLee_normalize_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SAXSLee_normalize

% Last Modified by GUIDE v2.5 03-Jan-2011 14:59:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SAXSLee_normalize_OpeningFcn, ...
                   'gui_OutputFcn',  @SAXSLee_normalize_OutputFcn, ...
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

% --- Executes just before SAXSLee_normalize is made visible.
function SAXSLee_normalize_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SAXSLee_normalize (see VARARGIN)

% Choose default command line output for SAXSLee_normalize
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using SAXSLee_normalize.
if strcmp(get(hObject,'Visible'),'off')
    check_normcondition(handles);
end

% UIWAIT makes SAXSLee_normalize wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SAXSLee_normalize_OutputFcn(hObject, eventdata, handles)
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
        filen = getappdata(gcf, 'normfile');
        cln = str2double(get(handles.edit1, 'string'));
        for i = 1:numel(hdl)
            ct = specSAXSn2(filen, get(hdl(i),'tag') , 1);
            normval(i) = ct(cln);
        end
    case 3
        qv = str2double(get(handles.edit1, 'string'));
        normval = [];
    case 4
        qv(1) = str2double(get(handles.edit1, 'string'));
        qv(2) = str2double(get(handles.edit2, 'string'));
        normval = [];
    case 5
        qv(1) = str2double(get(handles.edit1, 'string'));
        qv(2) = str2double(get(handles.edit2, 'string'));
        normval = [];
end

for i = 1:numel(hdl)
    xd = get(hdl(i), 'xdata');
    yd = get(hdl(i), 'ydata');
    zd = getappdata(hdl(i),'yDataError');
    if isempty(normval)
        if numel(qv) == 1
            normval = interp1(xd, yd, qv);
            %yd = yd/yv;
            %zd = zd/yv;
        else
            [~,ind]=local_nearest(qv,xd);
            xv = xd(ind(1):ind(2));
            yv = yd(ind(1):ind(2));
            normval = integrate(xv, yv);
            %yd = yd/normv;
            %zd = zd/normv;
        end
    end
    normv = 1;
    % normalize
    if sel2 == 1
        normv = getappdata(hdl(i), 'normval');
        if isempty(normv) 
            normv = 1;
        end
        if normv == 0
            normv = 1;
        end
%    else
%        setappdata(hdl(i), 'normval', normval);
    end
    yd = yd/normval;
    zd = zd/normval;
    normval = normv * normval;
    setappdata(hdl(i), 'normval', normval);
        
    set(hdl(i), 'ydata', yd);
    setappdata(hdl(i), 'yDataError', zd);
    %savedata???
    nd = [xd(:), yd(:), zd(:)];
    tg = get(hdl(i),'tag');
    savedata(SAXSLeepath, nd, tg, normval);
end
            

function [xv,ind]=local_nearest(x,xl)
%Inputs:
% x   Selected x value
% xl  Line Data (x)
% y   Selected y value
% yl  Line Data (y)
%Find nearest value of [xl,yl] to (x,y)
%Special Case: Line has a single non-singleton value
	%Process the case where max == min
    
    if numel(x) == 1
        xl = abs(xl - x);
        [~,ind] = min(xl);
        xv = xl(ind);
    else
        x = sort(x);
        indx = [0,0];
        xl1 = (xl - x(1));
        [mx,ind] = min(abs(xl1));
        if mx ~= 0
            if xl1(ind) < 0
                ind = ind + 1;
            end
        end
        indx(1) = ind;
        
        xl2 = (xl - x(2));
        [mx,ind] = min(abs(xl2));
        if mx ~= 0
            if xl2(ind) > 0
                ind = ind - 1;
            end
        end
        indx(2) = ind;
        xv = xl(indx);
        ind = indx;
    end


function savedata(SAXSLeepath, nd, tg, normval)
    % save data
    filename = fullfile(SAXSLeepath, 'userNorm', tg);
    if ~isdir(fullfile(SAXSLeepath, 'userNorm'))
        mkdir(fullfile(SAXSLeepath, 'userNorm'));
    end
    save(filename, 'nd', '-ascii');
    fprintf('%s%s%s is normlized by %f, and saved\n', 'userNorm',filesep,tg, normval);


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
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


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
    , 'File (put a number of column)'...
    , 'I(q) at cursor'...
    , 'I(q) at between cursors'...
    , 'I(q) at between q values (put q values)'...
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


if strfind(get(hObject,'string'), 'Read cursors')
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
        set(handles.pb_loadfile, 'string', 'Load');        
    case 3
        set(handles.edit1, 'enable', 'on');
        set(handles.pb_loadfile, 'visible', 'on');
        set(handles.pb_loadfile, 'string', 'Read cursor');        
    case 4
        set(handles.text0, 'visible', 'on');
        set(handles.edit1, 'enable', 'on');
        set(handles.edit2, 'enable', 'on');
        set(handles.pb_loadfile, 'visible', 'on');
        set(handles.pb_loadfile, 'string', 'Read cursors');        
    case 5
        set(handles.text0, 'visible', 'on');
        set(handles.edit1, 'enable', 'on');
        set(handles.edit2, 'enable', 'on');
end
