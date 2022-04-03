function varargout = UserMathTools(varargin)
% USERMATHTOOLS MATLAB code for UserMathTools.fig
%      USERMATHTOOLS, by itself, creates a new USERMATHTOOLS or raises the existing
%      singleton*.
%
%      H = USERMATHTOOLS returns the handle to a new USERMATHTOOLS or the handle to
%      the existing singleton*.
%
%      USERMATHTOOLS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in USERMATHTOOLS.M with the given input arguments.
%
%      USERMATHTOOLS('Property','Value',...) creates a new USERMATHTOOLS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before UserMathTools_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to UserMathTools_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help UserMathTools

% Last Modified by GUIDE v2.5 28-Oct-2014 22:12:30

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @UserMathTools_OpeningFcn, ...
                   'gui_OutputFcn',  @UserMathTools_OutputFcn, ...
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


% --- Executes just before UserMathTools is made visible.
function UserMathTools_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to UserMathTools (see VARARGIN)

% Choose default command line output for UserMathTools
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes UserMathTools wait for user response (see UIRESUME)
% uiwait(handles.UserMathTools);


% --- Outputs from this function are returned to the command line.
function varargout = UserMathTools_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in lb_data1.
function lb_data1_Callback(hObject, eventdata, handles)
% hObject    handle to lb_data1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lb_data1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lb_data1
if ~isempty(get(hObject, 'selected'))
    set(handles.ed_scale1, 'enable', 'on');
    set(handles.rb_data1, 'enable', 'on');
else
    set(handles.ed_scale1, 'enable', 'off');
    set(handles.rb_data1, 'enable', 'off');
end

% --- Executes during object creation, after setting all properties.
function lb_data1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lb_data1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
[~, hdl] = numDatasetonGraph(hAxes);
dt = get(hdl, 'tag');
set(hObject, 'string', dt);
set(hObject, 'userdata', hdl);

% --- Executes on selection change in pu_data2.
function pu_data2_Callback(hObject, eventdata, handles)
% hObject    handle to pu_data2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pu_data2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pu_data2
if ~isempty(get(hObject, 'selected'))
    set(handles.ed_scale2, 'enable', 'on');
    set(handles.rb_data2, 'enable', 'on');
else
    set(handles.ed_scale2, 'enable', 'off');
    set(handles.rb_data2, 'enable', 'off');
end


% --- Executes during object creation, after setting all properties.
function pu_data2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pu_data2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
[~, hdl] = numDatasetonGraph(hAxes);
dt = get(hdl, 'tag');
set(hObject, 'string', dt);
set(hObject, 'userdata', hdl);



function ed_scale1_Callback(hObject, eventdata, handles)
% hObject    handle to ed_scale1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_scale1 as text
%        str2double(get(hObject,'String')) returns contents of ed_scale1 as a double


% --- Executes during object creation, after setting all properties.
function ed_scale1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_scale1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rb_data1.
function rb_data1_Callback(hObject, eventdata, handles)
% hObject    handle to rb_data1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_data1



function ed_scale2_Callback(hObject, eventdata, handles)
% hObject    handle to ed_scale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_scale2 as text
%        str2double(get(hObject,'String')) returns contents of ed_scale2 as a double


% --- Executes during object creation, after setting all properties.
function ed_scale2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_scale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rb_data2.
function rb_data2_Callback(hObject, eventdata, handles)
% hObject    handle to rb_data2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_data2



function ed_savefolder_Callback(hObject, eventdata, handles)
% hObject    handle to ed_savefolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_savefolder as text
%        str2double(get(hObject,'String')) returns contents of ed_savefolder as a double


% --- Executes during object creation, after setting all properties.
function ed_savefolder_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_savefolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'string', pwd);

% --- Executes on button press in pb_pickdir.
function pb_pickdir_Callback(hObject, eventdata, handles)
% hObject    handle to pb_pickdir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
folder_name = uigetdir(pwd,'Pick Folder to Save Data');
if isequal(folder_name,0)
    return
end
set(handles.ed_savefolder, 'string', folder_name);


% --- Executes on button press in pb_compute.
function pb_compute_Callback(hObject, eventdata, handles)
% hObject    handle to pb_compute (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
com = get(handles.uipanel1, 'userdata');
dtsel1 = []; desel2 = [];
if get(handles.rb_data1, 'value')
    dtsel1 = get(handles.lb_data1, 'value');
end
if get(handles.rb_data2, 'value')
    dtsel2 = get(handles.pu_data2, 'value');
end
if isequal([numel(dtsel1), numel(dtsel2)], [0,0])
    cprintf('err', 'Pick either or both of data1 and 2 using radio button\n')
    return
end

s1 = str2double(get(handles.ed_scale1, 'string'));
s2 = str2double(get(handles.ed_scale2, 'string'));
% Load the handles of data.
hdl = get(handles.lb_data1, 'userdata');

if numel(dtsel1) == 0
    dtsel1 = 0;
end
if numel(dtsel2) == 0
    dtsel2 = 0;
end
    
for i=1:numel(dtsel1)
    if ishandle(dtsel1(i))
        isSW = getappdata(dtsel1(i), 'isSAXSWAXS');
    end
    if ishandle(dtsel2)
        isSW2 = getappdata(dtsel2, 'isSAXSWAXS');
    end
    if (isSW==1) | (isSW2==1)
        isSW = 1;
    end
    
    for SW = 1:(isSW+1) % SAXS and WAXS
        if SW==1 % SAXS
            if dtsel1(1) ~= 0
                yd = get(hdl(dtsel1(i)), 'ydata');
                zd = getappdata(hdl(dtsel1(i)), 'yErrData');
            end
            if dtsel2 ~=0
                yd2 = get(hdl(dtsel2), 'ydata');
                zd2 = getappdata(hdl(dtsel2), 'yErrData');
            end
        else  %WAXS
            if dtsel1(1) ~= 0
                hd = getappdata(hdl(dtsel1(i)), 'WAXShandle');
                yd = get(hd, 'ydata');
                zd = getappdata(hd, 'yErrData');
            end
            if dtsel2 ~=0
                hd = getappdata(hdl(dtsel2), 'WAXShandle');
                yd = get(hd, 'ydata');
                yd2 = get(hd, 'ydata');
                zd2 = getappdata(hd, 'yErrData');
            end
            
        end
        switch com
            case '+'
                if dtsel1(1) == 0
                    yd = 0;
                    zd = 0;
                end
                if dtsel2 == 0
                    yd2 = 0;
                    zd2 = 0;
                end

                yd = s1*yd + s2*yd2;
                zd = sqrt((abs(s1)*zd).^2 + (abs(s2)*zd2).^2);
            case 'X'
                if dtsel1(1) == 0
                    yd = 1;
                    zd = 1;
                end
                if dtsel2 == 0
                    yd2 = 1;
                    zd2 = 1;
                end

                ydn = s1*yd *( s2*yd2 );
                zd = abs(ydn).*sqrt((s1*zd./yd).^2 + (s2*zd2./yd2).^2);
                yd = ydn;
            case '/'
                if dtsel1(1) == 0
                    yd = 1;
                    zd = 1;
                end
                if dtsel2 == 0
                    yd2 = 1;
                    zd2 = 1;
                end
                ydn = s1*yd /( s2*yd2 );
                zd = abs(ydn).*sqrt((s1*zd./yd).^2 + (s2*zd2./yd2).^2);
                yd = ydn;
        end
    
    end
end


% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)

set(hObject, 'userdata', get(eventdata.NewValue, 'string'))


% --- Executes during object creation, after setting all properties.
function uipanel1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject, 'userdata', '/')
