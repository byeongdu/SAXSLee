function varargout = SAXSLee_twocurvefit(varargin)
% SAXSLEE_TWOCURVEFIT MATLAB code for SAXSLee_twocurvefit.fig
%      SAXSLEE_TWOCURVEFIT, by itself, creates a new SAXSLEE_TWOCURVEFIT or raises the existing
%      singleton*.
%
%      H = SAXSLEE_TWOCURVEFIT returns the handle to a new SAXSLEE_TWOCURVEFIT or the handle to
%      the existing singleton*.
%
%      SAXSLEE_TWOCURVEFIT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAXSLEE_TWOCURVEFIT.M with the given input arguments.
%
%      SAXSLEE_TWOCURVEFIT('Property','Value',...) creates a new SAXSLEE_TWOCURVEFIT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SAXSLee_twocurvefit_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SAXSLee_twocurvefit_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SAXSLee_twocurvefit

% Last Modified by GUIDE v2.5 09-Aug-2018 10:56:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SAXSLee_twocurvefit_OpeningFcn, ...
                   'gui_OutputFcn',  @SAXSLee_twocurvefit_OutputFcn, ...
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

% --- Executes just before SAXSLee_twocurvefit is made visible.
function SAXSLee_twocurvefit_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SAXSLee_twocurvefit (see VARARGIN)

% Choose default command line output for SAXSLee_twocurvefit
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using SAXSLee_twocurvefit.
if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

% UIWAIT makes SAXSLee_twocurvefit wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SAXSLee_twocurvefit_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pb_typeofreference.
function pb_typeofreference_Callback(hObject, eventdata, handles)
% hObject    handle to pb_typeofreference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes1);
cla;

popup_sel_index = get(handles.popupmenu1, 'Value');
% ROI old.
[~, hdl] = numDatasetonGraph;
% [~, indx] = SAXSLee_findcursor;
% indx = unique(indx);
% ROI
    hmin = findobj(gcbf, 'tag', 'edqmin');
    hmax = findobj(gcbf, 'tag', 'edqmax');
    qmin = str2double(get(hmin, 'string'));
    qmax = str2double(get(hmax, 'string'));

switch popup_sel_index
    case 1 % water
            % The differential scattering cross section of water at q=0
            % is rho^2*k*T*chi = 1.65E-2 cm^-1 at 293K.
            % here the scaling factor is calculated assuming the same
            % capillary that was used for the water will be used for the
            % sample as well, then one needs no thickness correction.
        for i = 1:numel(hdl)
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
            nh = line('xdata', xd, 'ydata', yd);
            p = polyfit(xd, yd, 1);
            plotdata(hdl(i), nh);
            xd = linspace(0, max(xd), 100);
            nf = line('xdata', xd, 'ydata', xd*p(1)+p(2));
            fprintf('I(0) = %0.5f\n', p(2));
            set(nf, 'color', 'r')
        end    
        xlabel('q (A^{-1})', 'Interpreter', 'tex');
        ylabel('I(q) (a.u.)', 'Interpreter', 'tex');
        scalefactor = 1.65E-2/p(2);
        set(handles.txtscalefactor, 'string', sprintf('%0.3e', scalefactor));

        fprintf('\n')
        fprintf('In order to convert your data to absolute scale(cm^-1), \n')
        fprintf('        multiply data by the scale factor.\n')
        fprintf('        If you used the flow cell, that is enough.\n')
        fprintf('Note that this assume that you use the same container for sample and water standard.\n')
        fprintf('\n')
        fprintf('Otherwise,\n')
        fprintf('        1. multiply data with the scale factor.\n')
        fprintf('        2. divide them with a ratio of the thicknesses of sample and the water standard.\n')

    case 2 % Glassy carbon L17
        % Using the glassy carbon whose thickness is 1mm.
        % therefore, once the scalefactor is multiplied to user's data, the
        % user need to measure thicknessess of their samples and divide
        % data by the thickness (in cm).

    %[filename, pathname] = uigetfile('*.*', 'Pick a reference');
    %if isequal(filename,0) || isequal(pathname,0)
    %   disp('User pressed cancel')
    %   return
    %else
    %    refname = fullfile(pathname, filename);
    %   disp(['User selected ', refname])
    %end
    %ref = load(refname);
        load L17_12IDB.mat;
        ref = L17_12IDB;
        ref(:,2) = ref(:,2)*0.1;% thickness of the standard is 0.1cm 
        for i = 1:numel(hdl)
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
            while (xd(1)<ref(1,1))
                xd(1) = [];yd(1) = []; zd(1) = [];
                if numel(xd) < 1
                    error('q range is issue')
                end
            end
            while (xd(end)>ref(end,1))
                xd(end) = [];yd(end) = []; zd(end) = [];
                if numel(xd) < 1
                    error('q range is issue')
                end
            end
            nh = line('xdata', log(abs(xd)), 'ydata', log(abs(yd)));
            dt = interp1(ref(:,1), ref(:,2), xd);
            datavarargin{1} = dt;
            % Initialize parameter to fit ======
            NLPstart = 1;
            % ==================================

            options = optimset('fminsearch');
            options = optimset(options, 'TolX',0.0000001);
            %options = optimset(options, 'PlotFcns',@optimplotx);
            %options = optimset(options, 'OutputFcn',@BLFit_outfun);
            options = optimset(options, 'MaxIter',500);

            %INLP = fminsearchcon(@(x) fitschultz(x,y, Rmat, roi),NLPstart,LB,UB, [], [], [], options);
            INLP = fminsearchcon(@(x) fitfunc(x,yd, datavarargin),NLPstart,1E-9,1E9, [], [], [], options);
        
            plotdata(hdl(i), nh);
            %xd = linspace(0, max(xd), 100);size(xd), size(dt)
            nf = line('xdata', log(abs(xd)), 'ydata', log(abs(dt/INLP)));
            set(nf, 'color', 'r')
            fprintf('Scalefactor = %0.5f\n', INLP);
            scalefactor = INLP;
            set(handles.txtscalefactor, 'string', sprintf('%0.3e', scalefactor));

        end    
        fprintf('In order to convert your data to absolute scale(cm^-1),\n')
        fprintf('        1. multiply data with the scale factor.\n')
        fprintf('        2. divide them by the thickness of sample in cm unit.\n')

end
    fprintf('Or, use the tool: Tools > Absolute Intensity Calibration > Convert Data into Abs Unit.\n')
    xlabel('log(q) (A^{-1})', 'Interpreter', 'tex');
    ylabel('log(I(q)) (a.u.)', 'Interpreter', 'tex');

function cv = fitfunc(p, y,  datavarargin)
%nr = schultz(p(2), p(3), Rmat.R);
%Rmat.nr = nr;
dt = datavarargin{1};
Iq = dt(:);
%Iq = p(1)*Imat*nr/sum(nr) + p(4)*back;
y = p(1)*y(:);
%fit.distr = nr;
N = numel(y);
P = 1;
terms = ((y-Iq).^2)./abs(y);
cv = 1/(N-P)*sum(terms);

%cv = chi_squared(Iq, y, 2, sqrt(Iq));

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


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end

set(hObject, 'String', {'Solvent I(0)', 'Glassy Carbon L17'});


% --- Executes on button press in pb_loadreference.
function pb_loadreference_Callback(hObject, eventdata, handles)
% hObject    handle to pb_loadreference (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



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
