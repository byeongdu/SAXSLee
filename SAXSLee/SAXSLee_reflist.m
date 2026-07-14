function varargout = SAXSLee_reflist(varargin)
% SAXSLEE_REFLIST MATLAB code for SAXSLee_reflist.fig
%      SAXSLEE_REFLIST, by itself, creates a new SAXSLEE_REFLIST or raises the existing
%      singleton*.
%
%      H = SAXSLEE_REFLIST returns the handle to a new SAXSLEE_REFLIST or the handle to
%      the existing singleton*.
%
%      SAXSLEE_REFLIST('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAXSLEE_REFLIST.M with the given input arguments.
%
%      SAXSLEE_REFLIST('Property','Value',...) creates a new SAXSLEE_REFLIST or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SAXSLee_reflist_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SAXSLee_reflist_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SAXSLee_reflist

% Last Modified by GUIDE v2.5 29-Nov-2011 21:56:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SAXSLee_reflist_OpeningFcn, ...
                   'gui_OutputFcn',  @SAXSLee_reflist_OutputFcn, ...
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


% --- Executes just before SAXSLee_reflist is made visible.
function SAXSLee_reflist_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SAXSLee_reflist (see VARARGIN)

% Choose default command line output for SAXSLee_reflist
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SAXSLee_reflist wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SAXSLee_reflist_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in ref_listbox.
function ref_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to ref_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ref_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ref_listbox


% --- Executes during object creation, after setting all properties.
function ref_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_load.
function pb_load_Callback(hObject, eventdata, handles)
% hObject    handle to pb_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% --- get current directory in order to restore after opening spec file
    prePath = pwd;
    % --- open file
    [filename, filepath] = uigetfile( ...
        'multiselect', 'on', ...
        {'*.*bsub*','background subtracted (*.*bavg*)';'*.avg','Averaged file (*.avg)';'*.*','All Files (*.*)'}, ...
        'Select Reference Data');
    % If "Cancel" is selected then return
    if isequal([filename,filepath],[0,0])
        restorePath(prePath);
        return
    end


    % Otherwise construct the fullfilename and Check and load the file.
    % reference scan number start from 2... 
    % load refscan
    try
        refscan = evalin('base', 'refscan');
        if ~isfield(refscan, 'fn')
            refscan = [];
        end
    catch
        refscan = [];
    end
    
    numdata = numel(refscan);
    if ~iscell(filename)
        filename = {filename};
    end
    for k=1:numel(filename)
        fn = fullfile(filepath, filename{k});
        refscan(numdata+k).fn = filename{k};
        refscan(numdata+k).fullfn = fn;
    end
    fnames = {refscan.fn};
    set(handles.ref_listbox, 'String', fnames);
    if (get(handles.ref_listbox, 'value') > numel(fnames))
        set(handles.ref_listbox, 'value', 1)
    end

    
    assignin('base', 'refscan', refscan);

function restorePath(prePath)
path_str = ['cd ','''',prePath,''''];
eval(path_str);


% --- Executes on button press in pb_removeselected.
function pb_removeselected_Callback(hObject, eventdata, handles)
% hObject    handle to pb_removeselected (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    try
        refscan = evalin('base', 'refscan');
    catch
        error('No refscan')
    end
    listv = get(handles.ref_listbox, 'value');
    for i=numel(listv):-1:1
        refscan(listv(i)) = [];
    end
    %set(handles.ref_listbox, 'String', '');
    set(handles.ref_listbox, 'String', {refscan.fn});
    assignin('base', 'refscan', refscan)
    


% --- Executes on button press in pb_refresh.
function pb_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to pb_refresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
settings = evalin('base', 'settings');
setpath = settings.path;
backsubpath = fullfile(setpath, 'BackSub');

try
    timestamp = getappdata(hObject, 'timestamp');
catch
    timestamp = 0;
end

try
    refscan = evalin('base', 'refscan');
    if ~isfield(refscan, 'fn')
        refscan = [];
        timestamp = 0;
    end
catch
    refscan = [];
    timestamp = 0;
end

fn = dir(backsubpath);
sel = [];

% In the backsub directory, only files starting with S counts.
for i=1:numel(fn)
    if fn(i).name(1) == 'S'
        sel = [sel, i];
    end
end

fnames = {fn(sel).name};
% In order not to duplicate filenames in the list, 
timemeasured = datenum({fn(sel).date});
if isempty(timestamp)
    timestamp = 0;
end
fnames(timemeasured < timestamp) = [];
N = numel(refscan);
for i=1:numel(fnames)
    refscan(N+i).fn = fnames{i};
    refscan(N+i).fullfn = fullfile(backsubpath, fnames{i});
end

f = {refscan.fn};
[~, indx] = unique(f);
refscan = refscan(indx);
setappdata(hObject,'timestamp', now)
set(handles.ref_listbox, 'String', {refscan.fn})
assignin('base', 'refscan', refscan);


% --- Executes on button press in rd_isSAXSWAXS.
function rd_isSAXSWAXS_Callback(hObject, eventdata, handles)
% hObject    handle to rd_isSAXSWAXS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rd_isSAXSWAXS


% --- Executes on button press in pb_plot.
function pb_plot_Callback(hObject, eventdata, handles)
% hObject    handle to pb_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hFigSAXSLee = SAXSLee;
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
hPopupmenuY = findall(hFigSAXSLee,'Tag','SAXSLee_PopupmenuY');
refscan = evalin('base', 'refscan');

if isempty(refscan)
    set(hPopupmenuY,'value', 1);
    set(hPopupmenuY,'String', ' ');
    return
end

if strfind(get(hObject, 'string'), 'Plot')
    set(hObject, 'string', 'Erase');
else
    rmdataplot(hAxes)
    set(hObject, 'string', 'Plot');
    setappdata(hFigSAXSLee,'refscan', []);
    return;
end

listv = get(handles.ref_listbox, 'value');
scan = {};
%for i=1:1:numel(listv)
    %scan{i} = refscan.dat{listv(i)};
scan = SAXSLee_loadandplot_reflinedata(refscan, listv, hAxes, 'REF');
%end
%setappdata(hFigSAXSLee,'refscan', refscan);
setappdata(hFigSAXSLee,'refscan', scan);

%SAXSLee_drawrefplot(scan, hAxes, hPopupmenuY);
% --- determine legend
curvelegend(hFigSAXSLee);


function rmdataplot(hAxes)
tm = findobj(hAxes, 'type', 'line');
for is = 1:numel(tm);
    if strfind(get(tm(is), 'Tag'), 'REF#')
        delete(tm(is));
    end
end

function rmbackplot(hAxes)
tm = findobj(hAxes, 'type', 'line');
for is = 1:numel(tm);
    if strfind(get(tm(is), 'Tag'), 'BACK')
        delete(tm(is));
    end
end
%set(hPopupmenuY,'value', 1);
%set(hPopupmenuY,'String', ' ');




% --- Executes on button press in pb_setback.
function pb_setback_Callback(hObject, eventdata, handles)
% hObject    handle to pb_setback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hFigSAXSLee = SAXSLee;
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');

try
    backscan = evalin('base', 'backscan');
catch
    backscan = [];
end
try
    refscan = evalin('base', 'refscan');
catch
    refscan = [];
    error('there is no refscan')
end

%if isempty(backscan)
%    set(hPopupmenuY,'value', 1);
%    set(hPopupmenuY,'String', ' ');
%    return
%end

if strfind(get(hObject, 'string'), 'Set the selected as background')
    set(hObject, 'string', 'Reset background');
else
    rmbackplot(hAxes)
    set(hObject, 'string', 'Set the selected as background');
    setappdata(hFigSAXSLee,'backscan', []);
    return;
end

listv = get(handles.ref_listbox, 'value');
scan = SAXSLee_loadandplot_reflinedata(refscan, listv, hAxes, 'BACK');
setappdata(hFigSAXSLee,'backscan', scan{1});
