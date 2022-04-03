function varargout = plotControl(varargin)
% PLOTCONTROL MATLAB code for plotControl.fig
%      PLOTCONTROL, by itself, creates a new PLOTCONTROL or raises the existing
%      singleton*.
%
%      H = PLOTCONTROL returns the handle to a new PLOTCONTROL or the handle to
%      the existing singleton*.
%
%      PLOTCONTROL('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLOTCONTROL.M with the given input arguments.
%
%      PLOTCONTROL('Property','Value',...) creates a new PLOTCONTROL or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before plotControl_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to plotControl_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help plotControl

% Last Modified by GUIDE v2.5 25-Oct-2014 22:29:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @plotControl_OpeningFcn, ...
                   'gui_OutputFcn',  @plotControl_OutputFcn, ...
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


% --- Executes just before plotControl is made visible.
function plotControl_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to plotControl (see VARARGIN)

% Choose default command line output for plotControl
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes plotControl wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = plotControl_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ed_ymin_Callback(hObject, eventdata, handles)
% hObject    handle to ed_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_ymin as text
%        str2double(get(hObject,'String')) returns contents of ed_ymin as a double
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
xlo = get(gca, 'ylim');
xl = str2double(get(hObject, 'string'));
set(gca, 'ylim', [xl, xlo(2)]);

% --- Executes during object creation, after setting all properties.
function ed_ymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
xl = get(gca, 'ylim');
set(hObject, 'string', num2str(xl(1)));



function ed_ymax_Callback(hObject, eventdata, handles)
% hObject    handle to ed_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_ymax as text
%        str2double(get(hObject,'String')) returns contents of ed_ymax as a double
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
xlo = get(gca, 'ylim');
xl = str2double(get(hObject, 'string'));
set(gca, 'ylim', [xlo(1), xl]);


% --- Executes during object creation, after setting all properties.
function ed_ymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
xl = get(gca, 'ylim');
set(hObject, 'string', num2str(xl(2)));



function ed_xmin_Callback(hObject, eventdata, handles)
% hObject    handle to ed_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_xmin as text
%        str2double(get(hObject,'String')) returns contents of ed_xmin as a double
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
xlo = get(gca, 'xlim');
xl = str2double(get(hObject, 'string'));
set(gca, 'xlim', [xl, xlo(2)]);


% --- Executes during object creation, after setting all properties.
function ed_xmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_xmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
xl = get(gca, 'xlim');
set(hObject, 'string', num2str(xl(1)));



function ed_xmax_Callback(hObject, eventdata, handles)
% hObject    handle to ed_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_xmax as text
%        str2double(get(hObject,'String')) returns contents of ed_xmax as a double
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
xlo = get(gca, 'xlim');
xl = str2double(get(hObject, 'string'));
set(gca, 'xlim', [xlo(1), xl]);


% --- Executes during object creation, after setting all properties.
function ed_xmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_xmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
xl = get(gca, 'xlim');
set(hObject, 'string', num2str(xl(2)));



function ed_xlabel_Callback(hObject, eventdata, handles)
% hObject    handle to ed_xlabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_xlabel as text
%        str2double(get(hObject,'String')) returns contents of ed_xlabel as a double
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
xl = get(gca, 'xlabel');
set(xl, 'string', get(hObject, 'string'));


% --- Executes during object creation, after setting all properties.
function ed_xlabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_xlabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
xl = get(get(gca, 'xlabel'), 'string');
set(hObject, 'string', xl);




function ed_ylabel_Callback(hObject, eventdata, handles)
% hObject    handle to ed_ylabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_ylabel as text
%        str2double(get(hObject,'String')) returns contents of ed_ylabel as a double
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
xl = get(gca, 'ylabel');
set(xl, 'string', get(hObject, 'string'));


% --- Executes during object creation, after setting all properties.
function ed_ylabel_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_ylabel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
xl = get(get(gca, 'ylabel'), 'string');
set(hObject, 'string', xl);


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

function get_values(handles)
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');

xl = get(gca, 'xlim');
set(handles.ed_xmin, 'string', num2str(xl(1)));
set(handles.ed_xmax, 'string', num2str(xl(2)));
yl = get(gca, 'ylim');
set(handles.ed_ymin, 'string', num2str(yl(1)));
set(handles.ed_ymax, 'string', num2str(yl(2)));
xl = get(gca, 'xlabel');
yl = get(gca, 'ylabel');
set(handles.ed_xlabel, 'string', xl);
set(handles.ed_ylabel, 'string', yl);



function ed_labelfontsize_Callback(hObject, eventdata, handles)
% hObject    handle to ed_labelfontsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_labelfontsize as text
%        str2double(get(hObject,'String')) returns contents of ed_labelfontsize as a double
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
set(get(gca, 'xlabel'), 'fontsize', str2double(get(hObject, 'string')));
set(get(gca, 'ylabel'), 'fontsize', str2double(get(hObject, 'string')));

% --- Executes during object creation, after setting all properties.
function ed_labelfontsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_labelfontsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
xl = get(get(gca, 'ylabel'), 'fontsize');
set(hObject, 'string', num2str(xl));




function ed_fontsize_Callback(hObject, eventdata, handles)
% hObject    handle to ed_fontsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_fontsize as text
%        str2double(get(hObject,'String')) returns contents of ed_fontsize as a double
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
set(gca, 'fontsize', str2double(get(hObject, 'string')));


% --- Executes during object creation, after setting all properties.
function ed_fontsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_fontsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%hAxes = get_axes;
xl = get(gca, 'fontsize');
set(hObject, 'string', num2str(xl));



function ed_markersize_Callback(hObject, eventdata, handles)
% hObject    handle to ed_markersize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_markersize as text
%        str2double(get(hObject,'String')) returns contents of ed_markersize as a double
%hAxes = get_axes;
ms = str2double(get(hObject, 'string'));
dt = findobj(gca, 'type', 'line');
for i=1:numel(dt)
    set(dt(i), 'markersize', ms);
end


% --- Executes during object creation, after setting all properties.
function ed_markersize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_markersize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




function h = get_axes(varargin)
hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
h = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');



function ed_linewidth_Callback(hObject, eventdata, handles)
% hObject    handle to ed_linewidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_linewidth as text
%        str2double(get(hObject,'String')) returns contents of ed_linewidth as a double
%hAxes = get_axes;
ms = str2double(get(hObject, 'string'));
dt = findobj(gca, 'type', 'line');
for i=1:numel(dt)
    set(dt(i), 'linewidth', ms);
end

% --- Executes during object creation, after setting all properties.
function ed_linewidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_linewidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_resetlinestyle.
function pb_resetlinestyle_Callback(hObject, eventdata, handles)
% hObject    handle to pb_resetlinestyle (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
hLine = get(gcf, 'userdata');
if ~isempty(hLine)
    for i=1:length(hLine.SAXS)
        plotoption(hLine.SAXS(i), i);
        if isfield(hLine, 'WAXS')
            plotoption(hLine.WAXS(i), i);
        end
    end
    return
end
hLine = findobj(gca, 'type', 'line');
for i=1:length(hLine)
    plotoption(hLine(i), i);
end


% --- Executes on button press in pb_datasplit.
function pb_datasplit_Callback(hObject, eventdata, handles)
% hObject    handle to pb_datasplit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

factor = str2double(get(handles.edit_datasplitfactor, 'string'));
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = get_axes;
yscale = get(gca, 'yscale');
hLine = get(gcf, 'userdata');
% if gca is the SAXSLee
if ~isempty(hLine)
    if isfield(hLine, 'SAXS')
        for i=1:length(hLine.SAXS)
            scaleyd(hLine.SAXS(i), yscale, i, factor);
            if isfield(hLine, 'WAXS')
                scaleyd(hLine.WAXS(i), yscale, i, factor);
            end
        end
        return
    end
end
% if gca is a general matlab plot....
hLine = findobj(gca, 'type', 'line');
for i=1:length(hLine)
    scaleyd(hLine(i), yscale, i, factor);
end


function scaleyd(h, yscale, seqN, factor)
try
    yd = get(h, 'ydata');
catch
    return
end
    switch yscale
        case 'linear'
            yd = yd + seqN*factor;
        case 'log'
            yd = yd*10^(seqN*factor);
    end
set(h, 'ydata', yd);    
    
function edit_datasplitfactor_Callback(hObject, eventdata, handles)
% hObject    handle to edit_datasplitfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_datasplitfactor as text
%        str2double(get(hObject,'String')) returns contents of edit_datasplitfactor as a double


% --- Executes during object creation, after setting all properties.
function edit_datasplitfactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_datasplitfactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
