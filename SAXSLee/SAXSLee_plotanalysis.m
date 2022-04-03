function varargout = SAXSLee_plotanalysis(varargin)
% SAXSLEE_PLOTANALYSIS MATLAB code for SAXSLee_plotanalysis.fig
%      SAXSLEE_PLOTANALYSIS, by itself, creates a new SAXSLEE_PLOTANALYSIS or raises the existing
%      singleton*.
%
%      H = SAXSLEE_PLOTANALYSIS returns the handle to a new SAXSLEE_PLOTANALYSIS or the handle to
%      the existing singleton*.
%
%      SAXSLEE_PLOTANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAXSLEE_PLOTANALYSIS.M with the given input arguments.
%
%      SAXSLEE_PLOTANALYSIS('Property','Value',...) creates a new SAXSLEE_PLOTANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SAXSLee_plotanalysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SAXSLee_plotanalysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SAXSLee_plotanalysis

% Last Modified by GUIDE v2.5 21-Mar-2015 14:03:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SAXSLee_plotanalysis_OpeningFcn, ...
                   'gui_OutputFcn',  @SAXSLee_plotanalysis_OutputFcn, ...
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


% --- Executes just before SAXSLee_plotanalysis is made visible.
function SAXSLee_plotanalysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SAXSLee_plotanalysis (see VARARGIN)

% Choose default command line output for SAXSLee_plotanalysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SAXSLee_plotanalysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SAXSLee_plotanalysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pb_Kratkyplot.
function pb_Kratkyplot_Callback(hObject, eventdata, handles)
% hObject    handle to pb_Kratkyplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dt = findobj(gca, 'type', 'line');
for i=1:numel(dt)
    xd = get(dt(i), 'xdata');
    yd = get(dt(i), 'ydata');
    set(dt(i), 'ydata', yd.*xd.^2);
end
yl = get(gca, 'ylabel');
set(yl, 'string', 'I(q)xq^2','fontsize', 12);
set(gcbf, 'userdata', 'Kratky')

% --- Executes on button press in pb_guinierplot.
function pb_guinierplot_Callback(hObject, eventdata, handles)
% hObject    handle to pb_guinierplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dt = findobj(gca, 'type', 'line');
for i=1:numel(dt)
    xd = get(dt(i), 'xdata');
    yd = get(dt(i), 'ydata');
    set(dt(i), 'xdata', xd.^2);
    set(dt(i), 'ydata', log(yd));
end
yl = get(gca, 'ylabel');
set(yl, 'string', 'ln(I(q))','fontsize', 12);
xl = get(gca, 'xlabel');
set(xl, 'string', 'q^2','fontsize', 12);
set(gcbf, 'userdata', 'Guinier')

% --- Executes on button press in pb_porodplot.
function pb_porodplot_Callback(hObject, eventdata, handles)
% hObject    handle to pb_porodplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dt = findobj(gca, 'type', 'line');
for i=1:numel(dt)
    xd = get(dt(i), 'xdata');
    yd = get(dt(i), 'ydata');
    set(dt(i), 'ydata', yd.*xd.^4);
end
yl = get(gca, 'ylabel');
set(yl, 'string', 'I(q) x q^4','fontsize', 12);
set(gcbf, 'userdata', 'Porod')

% --- Executes on button press in pb_OZplot.
function pb_OZplot_Callback(hObject, eventdata, handles)
% hObject    handle to pb_OZplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dt = findobj(gca, 'type', 'line');
for i=1:numel(dt)
    xd = get(dt(i), 'xdata');
    yd = get(dt(i), 'ydata');
    set(dt(i), 'ydata', 1./yd);
    set(dt(i), 'xdata', xd.^2);
end
yl = get(gca, 'ylabel');
set(yl, 'string', '1/I(q)','fontsize', 12);
xl = get(gca, 'xlabel');
set(xl, 'string', 'q^2','fontsize', 12);
set(gcbf, 'userdata', 'OZ')

% --- Executes on button press in pb_DBplot.
function pb_DBplot_Callback(hObject, eventdata, handles)
% hObject    handle to pb_DBplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dt = findobj(gca, 'type', 'line');
for i=1:numel(dt)
    xd = get(dt(i), 'xdata');
    yd = get(dt(i), 'ydata');
    set(dt(i), 'ydata', 1./sqrt(yd));
    set(dt(i), 'xdata', xd.^2);
end
yl = get(gca, 'ylabel');
set(yl, 'string', 'I(q)^{-1/2}','fontsize', 12);
xl = get(gca, 'xlabel');
set(xl, 'string', 'q^2','fontsize', 12);
set(gcbf, 'userdata', 'DB')


% --- Executes on button press in pb_fit.
function pb_fit_Callback(hObject, eventdata, handles)
% hObject    handle to pb_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

[hdl, indx, xv] = SAXSLee_findcursor;
if ~isempty(hdl)
    if ~iscell(indx)
        if numel(indx) ~=2
            cprintf('err', 'Error: You should select two points to fit....\n')
            return
        end
    end
else
    hdl = findobj(gca, 'type', 'line');
    xl = get(gca, 'xlim');
    xd = get(hdl, 'xdata');
    if iscell(xd)
        xd = xd{1};
    end
    [~, indx(1)] = min(abs(xd-xl(1)));
    [~, indx(2)] = min(abs(xd-xl(2)));
end    

plottype = get(gcbf, 'userdata');
dt = findobj(gca, 'type', 'line');
dtdot = findobj(gca, 'type', 'line', 'tag', 'Dot');
dt = setdiff(dt, dtdot);
dtdot = findobj(gca, 'type', 'line', 'tag', 'SAXSLeeFit');
dt = setdiff(dt, dtdot);
delete(dtdot);

Slope = zeros(size(dt));
Interc = zeros(size(dt));
resstr = [];
for i=1:numel(dt)
    lindex = find(hdl == dt(i), 1);
    if ~isempty(lindex)
        if iscell(indx)
            idx = indx{i};
        else
            idx = indx;
        end
    else
        if iscell(indx)
            idx = indx{1};
        else
            idx = indx;
        end
    end
    idx = sort(idx, 'ascend');
    xd = get(dt(i), 'xdata');
    yd = get(dt(i), 'ydata');
    xd = xd(idx(1):idx(2));
    yd = yd(idx(1):idx(2));
    P = polyfit(xd, yd, 1);
    Slope(i) = P(1);
    Interc(i) = P(2);
    d = line(xd, xd*Slope(i)+Interc(i));set(d, 'color', 'r');
    set(d, 'tag', 'SAXSLeeFit');
%resstr = {};
    switch plottype
        case 'Kratky'
        case 'Guinier'
            Rg = sqrt(-3*Slope(i));
            I0 = exp(Interc(i));
            resstr{1} = 'Guinier fit result: % saved as SAXSLee_plotanalysis_result.txt';
            resstr{2} = 'File,      Rg,     I0';
            resstr{i+2} = sprintf('%s, %0.3f, %0.8f', get(dt(i), 'tag'), Rg, I0);
        case 'Porod'
            %resstr{i+1} = sprintf('%s, %0.3f, %0.8f', get(dt(i), 'tag'), Slope(i), Interc(i));
        case 'OZ'
            xsi = sqrt(Slope(i));
            I0 = 1/Interc(i);
            resstr{1} = 'OZ fit result: % saved as SAXSLee_plotanalysis_result.txt';
            resstr{2} = 'File,      \xsi,     I0';
            resstr{i+2} = sprintf('%s, %0.3f, %0.8f', get(dt(i), 'tag'), xsi, I0);
        case 'DB'
            xsi = sqrt(Slope(i));
            I0 = 1/Interc(i).^2;
            resstr{1} = 'DB fit result: % saved as SAXSLee_plotanalysis_result.txt';
            resstr{2} = 'File,      \xsi,     I0';
            resstr{i+2} = sprintf('%s, %0.3f, %0.8f', get(dt(i), 'tag'), xsi, I0);
    end
end
if ~isempty(resstr)
    msgbox(resstr, 'Fit result');
    fid = fopen('SAXSLee_plotanalysis_result.txt', 'w');
    for i=1:numel(resstr)
        fprintf(fid, '%s\n', resstr{i});
    end
    fclose(fid);
else
    msgbox('No fit available', 'Error');
end

function ed_fitresult_Callback(hObject, eventdata, handles)
% hObject    handle to ed_fitresult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_fitresult as text
%        str2double(get(hObject,'String')) returns contents of ed_fitresult as a double


% --- Executes during object creation, after setting all properties.
function ed_fitresult_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_fitresult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
