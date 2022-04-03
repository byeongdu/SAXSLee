function varargout = SAXSLee_analysis(varargin)
% SAXSLEE_ANALYSIS M-file for SAXSLee_analysis.fig
%      SAXSLEE_ANALYSIS, by itself, creates a new SAXSLEE_ANALYSIS or raises the existing
%      singleton*.
%
%      H = SAXSLEE_ANALYSIS returns the handle to a new SAXSLEE_ANALYSIS or the handle to
%      the existing singleton*.
%
%      SAXSLEE_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAXSLEE_ANALYSIS.M with the given input arguments.
%
%      SAXSLEE_ANALYSIS('Property','Value',...) creates a new SAXSLEE_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SAXSLee_analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SAXSLee_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SAXSLee_analysis

% Last Modified by GUIDE v2.5 09-Mar-2017 19:12:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SAXSLee_analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @SAXSLee_analysis_OutputFcn, ...
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

% --- Executes just before SAXSLee_analysis is made visible.
function SAXSLee_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SAXSLee_analysis (see VARARGIN)

% Choose default command line output for SAXSLee_analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using SAXSLee_analysis.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

% UIWAIT makes SAXSLee_analysis wait for user response (see UIRESUME)
% uiwait(handles.SAXSLee_analysis);


% --- Outputs from this function are returned to the command line.
function varargout = SAXSLee_analysis_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pb_update.
function pb_update_Callback(hObject, eventdata, handles)
% hObject    handle to pb_update (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% clear annotation
try
    annoh = getappdata(gcbf, 'annotationhandle');
    if ~isempty(annoh)
        delete(annoh);
    end
catch
end
axes(handles.axes1);
cla;

popup_sel_index = get(handles.pm_typeofplot, 'Value');
switch popup_sel_index
    case 1
        doGuinier(handles);
    case 2
        doPorod(handles);
end


function doGuinier(handles)
    [NoldL, hdl] = numDatasetonGraph;
    %[~, indx] = SAXSLee_findcursor;
    qmin = str2double(get(handles.edqmin, 'string'));
    qmax = str2double(get(handles.edqmax, 'string'));
    %indx = unique(indx);
    
    for i = 1:NoldL
        xd = get(hdl(i), 'xdata');
        yd = get(hdl(i), 'ydata');
        zd = getappdata(hdl(i),'yDataError');
        [~, indx(1)] = min(abs(xd-qmin));
        [~, indx(2)] = min(abs(xd-qmax));
        if numel(indx) == 2
            xd = xd(indx(1):indx(2));
            yd = yd(indx(1):indx(2));
            zd = zd(indx(1):indx(2));
        end
        nh = line('xdata', xd.^2, 'ydata', log(abs(yd)));
        plotdata(hdl(i), nh);
    end    
    xlabel('q^2 (A^{-2})', 'Interpreter', 'tex');
    ylabel('ln(I(q)) (a.u.)', 'Interpreter', 'tex');


function doPorod(handles)
    [NoldL, hdl] = numDatasetonGraph;
%    [~, indx] = SAXSLee_findcursor;
    qmin = str2double(get(handles.edqmin, 'string'));
    qmax = str2double(get(handles.edqmax, 'string'));
%    indx = unique(indx);
    
    for i = 1:NoldL
        xd = get(hdl(i), 'xdata');
        yd = get(hdl(i), 'ydata');
        zd = getappdata(hdl(i),'yDataError');
        [~, indx(1)] = min(abs(xd-qmin));
        [~, indx(2)] = min(abs(xd-qmax));
        if numel(indx) == 2
            xd = xd(indx(1):indx(2));
            yd = yd(indx(1):indx(2));
            zd = zd(indx(1):indx(2));
        end
        nh = line('xdata', log10(abs(xd)), 'ydata', log10(abs(yd)));
        plotdata(hdl(i), nh);
    end    
    xlabel('ln(q) (A^{-1})', 'Interpreter', 'tex');
    ylabel('ln(I(q)) (a.u.)', 'Interpreter', 'tex');

function plotdata(oldline, newline)
    c = get(oldline, 'color');
    m = get(oldline, 'marker');
    set(newline,...
    'Color',c,...
    'LineStyle','-',...
    'Marker',m,...
    'MarkerSize',5);
    set(newline, 'tag', get(oldline, 'tag'));


















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
printdlg(handles.SAXSLee_analysis)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.SAXSLee_analysis,'Name') '?'],...
                     ['Close ' get(handles.SAXSLee_analysis,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.SAXSLee_analysis)


% --- Executes on selection change in pm_typeofplot.
function pm_typeofplot_Callback(hObject, eventdata, handles)
% hObject    handle to pm_typeofplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns pm_typeofplot contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_typeofplot


% --- Executes during object creation, after setting all properties.
function pm_typeofplot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_typeofplot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'Guinier', ...
    'Porod'});


% --- Executes on button press in pb_fit.
function pb_fit_Callback(hObject, eventdata, handles)
% hObject    handle to pb_fit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    annoh = getappdata(gcbf, 'annotationhandle');
    if ~isempty(annoh)
        delete(annoh);
    end
    annoh = getappdata(gcbf, 'fitlinehandle');
    if ~isempty(annoh)
        delete(annoh);
    end
catch
end


lh = findobj(handles.axes1, 'type', 'line');
yl = get(handles.axes1, 'ylim'); ysc = abs(yl(1)-yl(2));
%omf = str2double(get(handles.edqmin, 'string'));
%oml = str2double(get(handles.edqmax, 'string'));
omf = 1;
oml = 0;
fitmode = get(handles.pm_typeofplot, 'value');

%roi = omf:
annoh = zeros(size(lh));
tag = {};
npnt = 1;
for i=1:numel(lh)
    tg = get(lh(i), 'tag');
    if ~isempty(tg)
        xd = get(lh(i), 'xdata');
        yd = get(lh(i), 'ydata');
%         if numel(xd(omf:end-oml)) < 1;
%             cprintf('err', 'Error: number of datapoint is too small to do fit\n');
%             fprintf('The number of datapoint is %i, but you cut %i out\n', numel(xd), omf+oml);
%             return
%         end
        [p,s] = polyfit(xd, yd, 1);
        
        switch fitmode
            case 1
                Rg = sqrt(-1*p(1)*3);
                I0 = exp(p(2));
                rgr(npnt) = Rg;
                I0r(npnt) = I0;

                fitl(npnt) = line('xdata', xd, 'ydata', p(1)*xd+p(2), 'color', 'r');
                str = sprintf('Rg = %0.2f A for the file %s', Rg, tg);
                anno_str = sprintf('Rg = %0.2f A', Rg);
        
            case 2
                expn = p(1);
                I0 = exp(p(2));
                pExpn(npnt) = expn;
                pI0(npnt) = I0;
                
                c = get(lh(i), 'color');
                if sum(c == [1 0 0])==3;
                    c = [0 0 0];
                else
                    c = [1 0 0];
                end

                fitl(npnt) = line('xdata', xd, 'ydata', p(1)*xd+p(2), 'color', c);
                str = sprintf('Exponent = %0.2f for the file %s', expn, tg);
                anno_str = sprintf('Exponent = %0.2f ', expn);

        end
      
%         [pox(2), poy(2)] = ds2nfu(handles.axes1, xd(1), yd(1));
%         [pox(1), poy(1)] = ds2nfu(handles.axes1, xd(end), yd(1)-ysc/numel(lh)/2*npnt);
%         annoh(npnt) = annotation('textarrow', pox, poy, 'string', anno_str);
%        annoh(npnt) = annotation('textarrow', xd(end), yd(end), 'string', anno_str);
        annoh(npnt) = text(xd(end), yd(end), anno_str);
        fprintf('%s\n', str);
        tag{npnt} = tg;
        npnt = npnt + 1;
    end
end

setappdata(gcbf, 'annotationhandle', annoh)
setappdata(gcbf, 'fitlinehandle', fitl)    

switch fitmode
    case 1
        Guinierfit.filename = tag;
        Guinierfit.Rg = rgr;
        Guinierfit.I0 = I0r;
        assignin('base', 'Guinierfit', Guinierfit);        
    case 2
        Porod.filename = tag;
        Porod.expn = pExpn;
        Porod.I0 = pI0;
        assignin('base', 'Porodfit', Porod);        
end





function edqmin_Callback(hObject, eventdata, handles)
% hObject    handle to edqmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edqmin as text
%        str2double(get(hObject,'String')) returns contents of edqmin as a double


% --- Executes during object creation, after setting all properties.
function edqmin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edqmin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edqmax_Callback(hObject, eventdata, handles)
% hObject    handle to edqmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edqmax as text
%        str2double(get(hObject,'String')) returns contents of edqmax as a double


% --- Executes during object creation, after setting all properties.
function edqmax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edqmax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
