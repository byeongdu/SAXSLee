function varargout = BackgroundTools(varargin)
% BACKGROUNDTOOLS MATLAB code for BackgroundTools.fig
%      BACKGROUNDTOOLS, by itself, creates a new BACKGROUNDTOOLS or raises the existing
%      singleton*.
%
%      H = BACKGROUNDTOOLS returns the handle to a new BACKGROUNDTOOLS or the handle to
%      the existing singleton*.
%
%      BACKGROUNDTOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BACKGROUNDTOOLS.M with the given input arguments.
%
%      BACKGROUNDTOOLS('Property','Value',...) creates a new BACKGROUNDTOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before BackgroundTools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to BackgroundTools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help BackgroundTools

% Last Modified by GUIDE v2.5 19-Dec-2015 19:25:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @BackgroundTools_OpeningFcn, ...
                   'gui_OutputFcn',  @BackgroundTools_OutputFcn, ...
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


% --- Executes just before BackgroundTools is made visible.
function BackgroundTools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to BackgroundTools (see VARARGIN)

% Choose default command line output for BackgroundTools
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes BackgroundTools wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = BackgroundTools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ed_constback_Callback(hObject, eventdata, handles)
% hObject    handle to ed_constback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_constback as text
%        str2double(get(hObject,'String')) returns contents of ed_constback as a double
    const = str2double(get(hObject, 'string'));
    hl = getappdata(hObject, 'hd');
    yd = get(hl, 'ydata');
    yd = const*ones(size(yd));
    set(hl, 'ydata', yd);


% --- Executes during object creation, after setting all properties.
function ed_constback_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_constback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_loadbkg.
function pb_loadbkg_Callback(hObject, eventdata, handles)
% hObject    handle to pb_loadbkg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- open file
[filename, filepath] = uigetfile( ...
    'multiselect', 'off', ...
    {'*.dat','Data Files (*.dat)';'*.avg','Averaged Files (*.avg)';'*.*','All Files (*.*)'}, ...
    'Select Backgroud Data');
% If "Cancel" is selected then return
if isequal([filename,filepath],[0,0])
    return
end
fn = fullfile(filepath, filename);
scan = SAXSLee_loaddata(fn);
hFigSAXSLee = SAXSLee;
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
setappdata(hFigSAXSLee,'backscan', scan{1});
NoldL = numDatasetonGraph(hAxes);
hLine = SAXSLee_plot(scan, NoldL, hAxes, 'BACK');


% --- Executes on button press in pb_drawown.
function pb_drawown_Callback(hObject, eventdata, handles)
% hObject    handle to pb_drawown (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

drawContinousBack('start')


% --- Executes when selected object is changed in uipanel2.
function uipanel2_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel2 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)
set(handles.pb_drawown, 'enable', 'off');
set(handles.ed_constback, 'enable', 'off');
set(handles.pb_loadbkg, 'enable', 'off');

switch get(hObject, 'tag')
    case 'rb_drawown'
        set(handles.pb_drawown, 'enable', 'on');
    case 'rb_const'
        set(handles.ed_constback, 'enable', 'on');
        const = str2double(get(handles.ed_constback, 'string'));
        hl = generateconstbkg(const);
        if isempty(hl)
            return;
        end
        setappdata(handles.ed_constback, 'hd', hl);
    case 'rb_loadbkg'
        set(handles.pb_loadbkg, 'enable', 'on');
end

function bkghandle = generateconstbkg(const)
    Hfig = findall(0,'Tag','SAXSLee_Fig');
    if ~isempty(Hfig)
        isSAXSLee = 1;
        hAxes = findobj(Hfig,'Tag','SAXSLee_Axes');
    else
        Hfig = gcf;
        hAxes = gca;
    end

    [NoldL, hdl] = numDatasetonGraph(hAxes);
    if NoldL < 0
        hdl = findobj(hAxes, 'type', 'line');
    end
    if isempty(hdl)
        cprintf('red', 'There is no data displayed yet.\n');
        bkghandle = [];
        return
    end
    hdl = hdl(1);
    xdo = get(hdl, 'xdata');xdo = xdo(:); 
    bkg = const*ones(size(xdo));
    if isSAXSLee
        scan{1}.colData = [xdo, bkg, zeros(size(bkg))];
        scan{1}.Tag = 'lnbkg';
        NoldL = numDatasetonGraph(hAxes);
        setappdata(Hfig,'backscan', scan{1});
        bkghandle = SAXSLee_plot(scan, NoldL, hAxes, 'BACK');        
    else
        bkghandle = line('parent', hAxes, ...
            'xdata', xd, ...
            'ydata', bkg, ...
            'color', 'r', ...
            'tag', 'back');
    end


% --- Executes on button press in radiobutton7.
function radiobutton7_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton7
hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
SAXSLee_setting = getappdata(hFigSAXSLee,'SAXSLee_setting');
SAXSLee_setting.backdivideoption = 1;
[dt, indx] = SAXSLee_findcursor;
indx = sort(indx);

if numel(indx) == 2
    %error('At least two points should be selected');
    xd = get(dt(1), 'xdata');
    qroi = xd(indx);
    SAXSLee_setting.backdivideIntQrange = qroi;
    setappdata(hFigSAXSLee,'SAXSLee_setting', SAXSLee_setting);
    set(handles.ed_back_Llimit, 'string', qroi(1));
    set(handles.ed_back_Rlimit, 'string', qroi(2));
else
    set(handles.ed_back_Llimit, 'string', 0.1);
    set(handles.ed_back_Rlimit, 'string', 0.2);
end

set(handles.ed_back_Rlimit, 'enable', 'on');
set(handles.ed_back_Llimit, 'enable', 'on');

% --- Executes on button press in radiobutton8.
function radiobutton8_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton8
hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
SAXSLee_setting = getappdata(hFigSAXSLee,'SAXSLee_setting');
SAXSLee_setting.backdivideoption = 0;
SAXSLee_setting.backdivideIntQrange = [];
setappdata(hFigSAXSLee,'SAXSLee_setting', SAXSLee_setting);
set(handles.ed_back_Rlimit, 'enable', 'off');
set(handles.ed_back_Llimit, 'enable', 'off');



function ed_back_Llimit_Callback(hObject, eventdata, handles)
% hObject    handle to ed_back_Llimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_back_Llimit as text
%        str2double(get(hObject,'String')) returns contents of ed_back_Llimit as a double
hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
backscan = getappdata(hFigSAXSLee,'backscan');
if isfield(backscan, 'handle')
    backdatahandle = backscan.handle;
else
    backdatahandle = [0,0];
end

if isempty(backscan)
    disp('No back file is selected')
    return
end
bx = backscan.colData(:,1);
by = backscan.colData(:,2);
bz = backscan.colData(:,3);
try
    Wbx = backscan.colWData(:,1);
    Wby = backscan.colWData(:,2);
    Wbz = backscan.colWData(:,3);
catch
    Wbx = [];
end

SAXSLee_setting = getappdata(hFigSAXSLee,'SAXSLee_setting');
%SAXSLee_setting.backdivideoption = 0;
if ~isfield(SAXSLee_setting, 'backdivideIntQrange')
    SAXSLee_setting.backdivideIntQrange = [];
end

if isfield(SAXSLee_setting.backdivideIntQrange, 'SAXS')
    SAXS_backROI = SAXSLee_setting.backdivideIntQrange.SAXS;
    WAXS_backROI = SAXSLee_setting.backdivideIntQrange.WAXS;
else
    SAXS_backROI = [];
    WAXS_backROI = [];
end

Llimit = str2double(get(hObject, 'string'));

[~, xind] = min(abs(bx-Llimit));
if xind < numel(bx)
%    SAXS_backROI(1) = xind;
    SAXS_backROI(1) = Llimit;
else
    SAXS_backROI(1) = NaN;
end
[~, xind] = min(abs(Wbx-Llimit));
if xind > 1
%    WAXS_backROI(1) = xind;
    WAXS_backROI(1) = Llimit;
else
    WAXS_backROI(1) = NaN;
end


SAXSLee_setting = getappdata(hFigSAXSLee,'SAXSLee_setting');
%SAXSLee_setting.backdivideoption = 0;

if SAXS_backROI(1) > 0
    if backdatahandle(1) ~= 0;
        line(bx(xind), by(xind), 'linestyle', 'none', 'marker', '*', 'markersize', 12, 'parent', hAxes);
    end
end
if WAXS_backROI(1) > 0
    if backdatahandle(2) ~= 0;
        line(Wbx(xind), Wby(xind), 'linestyle', 'none', 'marker', '*', 'markersize', 12, 'parent', hAxes);
    end
end
SAXSLee_setting.backdivideIntQrange.SAXS = SAXS_backROI;
SAXSLee_setting.backdivideIntQrange.WAXS = WAXS_backROI;
SAXSLee_setting.backdivideoption = 1;
setappdata(hFigSAXSLee, 'SAXSLee_setting', SAXSLee_setting);

% --- Executes during object creation, after setting all properties.
function ed_back_Llimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_back_Llimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_back_Rlimit_Callback(hObject, eventdata, handles)
% hObject    handle to ed_back_Rlimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_back_Rlimit as text
%        str2double(get(hObject,'String')) returns contents of ed_back_Rlimit as a double
hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
backscan = getappdata(hFigSAXSLee,'backscan');
if isfield(backscan, 'handle')
    backdatahandle = backscan.handle;
else
    backdatahandle = [0,0];
end

if isempty(backscan)
    disp('No back file is selected')
    return
end
bx = backscan.colData(:,1);
by = backscan.colData(:,2);
bz = backscan.colData(:,3);
try
    Wbx = backscan.colWData(:,1);
    Wby = backscan.colWData(:,2);
    Wbz = backscan.colWData(:,3);
catch
    Wbx = [];
end

SAXSLee_setting = getappdata(hFigSAXSLee,'SAXSLee_setting');
%SAXSLee_setting.backdivideoption = 0;
if ~isfield(SAXSLee_setting, 'backdivideIntQrange')
    SAXSLee_setting.backdivideIntQrange = [];
end
if isfield(SAXSLee_setting.backdivideIntQrange, 'SAXS')
    SAXS_backROI = SAXSLee_setting.backdivideIntQrange.SAXS;
    WAXS_backROI = SAXSLee_setting.backdivideIntQrange.WAXS;
else
    SAXS_backROI = [];
    WAXS_backROI = [];
end

Llimit = str2double(get(hObject, 'string'));
[~, xind] = min(abs(bx-Llimit));
if xind < numel(bx)
    %SAXS_backROI(2) = xind;
    SAXS_backROI(2) = Llimit;
else
    SAXS_backROI(2) = 0;
end
[~, xind] = min(abs(Wbx-Llimit));
if xind > 1
    %WAXS_backROI(2) = xind;
    WAXS_backROI(2) = Llimit;
else
    WAXS_backROI(2) = NaN;
end

SAXSLee_setting = getappdata(hFigSAXSLee,'SAXSLee_setting');
%SAXSLee_setting.backdivideoption = 0;
wbh = [];
if SAXS_backROI(2) > 0
    if backdatahandle(1) ~= 0;
        sbh = line(bx(xind), by(xind), 'linestyle', 'none', 'marker', '*', 'markersize', 12, 'parent', hAxes);
    end
else
    sbh = [];
end
if WAXS_backROI(2) > 0
    if backdatahandle(2) ~= 0
        wbh = line(Wbx(xind), Wby(xind), 'linestyle', 'none', 'marker', '*', 'markersize', 12, 'parent', hAxes);
    end
else
    wbh = [];
end
SAXSLee_setting.backdivideIntQrange.SAXS = SAXS_backROI;
SAXSLee_setting.backdivideIntQrange.WAXS = WAXS_backROI;
SAXSLee_setting.backROIhandle.SAXS = sbh;
SAXSLee_setting.backROIhandle.WAXS = wbh;
SAXSLee_setting.backdivideoption = 1;
setappdata(hFigSAXSLee, 'SAXSLee_setting', SAXSLee_setting);


% --- Executes during object creation, after setting all properties.
function ed_back_Rlimit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_back_Rlimit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
