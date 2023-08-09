function varargout = SAXSLee_reflist2(varargin)
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

% Last Modified by GUIDE v2.5 19-Oct-2012 13:50:13

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
set(handles.ed_filter_backsub, 'string', '*.*avg')
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
        'multiselect', 'off', ...
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
    
    fn = fullfile(filepath, filename);

    % keep the loaded data....
    backrefscan = getappdata(hObject, 'backrefscan');
    numdata = numel(backrefscan);
    backrefscan(numdata+1).fn = filename;
    backrefscan(numdata+1).fullfn = fn;
    setappdata(hObject, 'backrefscan', backrefscan);
    
    % generate refscan....
    numdata = numel(refscan);
        
    refscan(numdata+1).fn = filename;
    refscan(numdata+1).fullfn = fn;
    fnames = {refscan.fn};
    set(handles.ref_listbox, 'String', fnames);
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
    


% --- Executes on button press in pb_refresh_backsub.
function pb_refresh_backsub_Callback(hObject, eventdata, handles)
% hObject    handle to pb_refresh_backsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    filterstr = get(handles.ed_filter_backsub, 'string');
    refscan = listbacksubdir(handles, filterstr);
    if isempty(refscan)
        set(handles.ref_listbox, 'String', '');
        handles.ref_listbox.Value = nan;
    else
        set(handles.ref_listbox, 'String', {refscan.fn});
        if (numel(refscan) > handles.ref_listbox.Value) | isnan(handles.ref_listbox.Value)
            handles.ref_listbox.Value = 1;
        end
    end
    assignin('base', 'refscan', refscan);


function refscan = listbacksubdir(handles, filterstr)
    hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
    settings = getappdata(hFigSAXSLee,'settings');
    %setpath = settings.path;
    [pth, backsubdir] = SAXSLee_getfolders(settings);
    backsubpath = fullfile(pth, filesep, backsubdir);

    refscan = [];
    if ~isempty(filterstr)
        fn = dir([backsubpath, filesep, filterstr]);
    else
        fn = dir(backsubpath);
    end

    % sort by time ......
    if numel(fn) < 2
        fnames = {fn.name};
    else
        if ischar(fn(1).date)
            [~, tmpind] = sort({fn.date});
        else
            [~, tmpind] = sort([fn.date]);
        end
        fnames = {fn(tmpind).name};
    end

    % loaded data.. not in backsub..
    backrefscan = getappdata(handles.pb_load, 'backrefscan');

    isSAXSWAXS = get(handles.rd_isSAXSWAXS, 'value');

    t = [];
    for i=1:numel(fnames)
        if numel(fnames{i}) < 3
            t = [t, i];
        else
            if isSAXSWAXS
                if fnames{i}(1) ~= 'S'
                    t = [t, i];
                end
            end
        end

    end
    if ~isempty(t)
        fnames(t) = [];
    end

    for i=1:numel(fnames)
        refscan(i).fn = fnames{i};
        refscan(i).fullfn = fullfile(backsubpath, fnames{i});
    end

    N = numel(fnames);

    for i=1:numel(backrefscan)
        refscan(N+i).fn = backrefscan(i).fn;
        refscan(N+i).fullfn = backrefscan(i).fullfn;
    end
    

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
isSAXSWAXS = get(handles.rd_isSAXSWAXS, 'value');
if isempty(refscan)
    set(hPopupmenuY,'value', 1);
    set(hPopupmenuY,'String', ' ');
    return
end
rmdataplot(hAxes)
% if strfind(get(hObject, 'string'), 'Plot')
%     set(hObject, 'string', 'Erase');
% else
%     rmdataplot(hAxes)
%     set(hObject, 'string', 'Plot');
%     setappdata(hFigSAXSLee,'refscan', []);
%     return;
% end

listv = get(handles.ref_listbox, 'value');
scan = {};
%for i=1:1:numel(listv)
    %scan{i} = refscan.dat{listv(i)};
[scan, ~] = SAXSLee_loadandplot_reflinedata(refscan, listv, hAxes, 'REF', isSAXSWAXS);
%end
%setappdata(hFigSAXSLee,'refscan', refscan);
setappdata(hFigSAXSLee,'refscan', scan);

%SAXSLee_drawrefplot(scan, hAxes, hPopupmenuY);
% --- determine legend
curvelegend(hFigSAXSLee);


function rmdataplot(hAxes)
tm = findobj(hAxes, 'type', 'line');
for is = 1:numel(tm)
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

setback(hObject, eventdata, handles, hFigSAXSLee, hAxes)
%listv = get(handles.ref_listbox_avg, 'value');
%backrefscan = getappdata(handles.pb_refresh_avg, 'backrefscan');
%scan = SAXSLee_loadandplot_reflinedata(backrefscan, listv, hAxes, 'BACK');
%setappdata(hFigSAXSLee,'backscan', scan{1});


% --- Executes on selection change in ref_listbox_avg.
function ref_listbox_avg_Callback(hObject, eventdata, handles)
% hObject    handle to ref_listbox_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ref_listbox_avg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ref_listbox_avg


% --- Executes during object creation, after setting all properties.
function ref_listbox_avg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_listbox_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_backsub.
function listbox_backsub_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_backsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_backsub contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_backsub


% --- Executes during object creation, after setting all properties.
function listbox_backsub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_backsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_refresh_avg.
function pb_refresh_avg_Callback(hObject, eventdata, handles)
% hObject    handle to pb_refresh_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%settings = evalin('base', 'settings');
%settings = getappdata(hFigSAXSLee,'settings');

    filterstr = get(handles.ed_filter_avg, 'string');
    backrefscan = listbacksubdir(handles, filterstr);

    if isempty(backrefscan)
        set(handles.ref_listbox_avg, 'string', '');
    else
        set(handles.ref_listbox_avg, 'String', {backrefscan.fn});
    end
    setappdata(handles.pb_refresh_avg, 'backrefscan', backrefscan);

% --- Executes on button press in pb_plot_avg.
function pb_plot_avg_Callback(hObject, eventdata, handles)
% hObject    handle to pb_plot_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hFigSAXSLee = SAXSLee;
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
hPopupmenuY = findall(hFigSAXSLee,'Tag','SAXSLee_PopupmenuY');
isSAXSWAXS = get(handles.rd_isSAXSWAXS, 'value');
%if isempty(refscan)
%    set(hPopupmenuY,'value', 1);
%    set(hPopupmenuY,'String', ' ');
%    return
%end
rmdataplot(hAxes)
if ~strfind(get(handles.pb_plot, 'string'), 'Plot')
    pb_plot_callback;
end

% if strfind(get(hObject, 'string'), 'Plot')
%     set(hObject, 'string', 'Erase');
% else
%     rmdataplot(hAxes)
%     set(hObject, 'string', 'Plot');
% %    setappdata(hFigSAXSLee,'refscan', []);
%     return;
% end

listv = get(handles.ref_listbox_avg, 'value');
scan = {};
%for i=1:1:numel(listv)
    %scan{i} = refscan.dat{listv(i)};
backrefscan = getappdata(handles.pb_refresh_avg, 'backrefscan');
[scan, ~] = SAXSLee_loadandplot_reflinedata(backrefscan, listv, hAxes, 'REF', isSAXSWAXS);
%end
%setappdata(hFigSAXSLee,'refscan', refscan);
%setappdata(hFigSAXSLee,'refscan', scan);

%SAXSLee_drawrefplot(scan, hAxes, hPopupmenuY);
% --- determine legend
curvelegend(hFigSAXSLee);


% --- Executes on button press in pb_plot.
function pushbutton14_Callback(hObject, eventdata, handles)
% hObject    handle to pb_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in ref_listbox.
function listbox5_Callback(hObject, eventdata, handles)
% hObject    handle to ref_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ref_listbox contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ref_listbox


% --- Executes during object creation, after setting all properties.
function listbox5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_load.
function pushbutton15_Callback(hObject, eventdata, handles)
% hObject    handle to pb_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pb_refresh_backsub.
function pb_refresh_Callback(hObject, eventdata, handles)
% hObject    handle to pb_refresh_backsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in rd_isSAXSWAXS.
function radiobutton2_Callback(hObject, eventdata, handles)
% hObject    handle to rd_isSAXSWAXS (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rd_isSAXSWAXS



function ed_filter_backsub_Callback(hObject, eventdata, handles)
% hObject    handle to ed_filter_backsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_filter_backsub as text
%        str2double(get(hObject,'String')) returns contents of ed_filter_backsub as a double
pb_refresh_backsub_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ed_filter_backsub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_filter_backsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_setback.
function pushbutton11_Callback(hObject, eventdata, handles)
% hObject    handle to pb_setback (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in ref_listbox_avg.
function listbox4_Callback(hObject, eventdata, handles)
% hObject    handle to ref_listbox_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ref_listbox_avg contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ref_listbox_avg


% --- Executes during object creation, after setting all properties.
function listbox4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ref_listbox_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_refresh_avg.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pb_refresh_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pb_plot_avg.
function pushbutton13_Callback(hObject, eventdata, handles)
% hObject    handle to pb_plot_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function ed_filter_avg_Callback(hObject, eventdata, handles)
% hObject    handle to ed_filter_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_filter_avg as text
%        str2double(get(hObject,'String')) returns contents of ed_filter_avg as a double
pb_refresh_avg_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function ed_filter_avg_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_filter_avg (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_setback1.
function pb_setback1_Callback(hObject, eventdata, handles)
% hObject    handle to pb_setback1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
hFigSAXSLee = SAXSLee;
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');

try
    backscan = evalin('base', 'backscan');
catch
    backscan = [];
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

setback(hObject, eventdata, handles,hFigSAXSLee,hAxes)
%listv = get(handles.ref_listbox, 'value');
%backrefscan = getappdata(handles.pb_refresh_backsub, 'backrefscan');
%scan = SAXSLee_loadandplot_reflinedata(backrefscan, listv, hAxes, 'BACK');
%setappdata(hFigSAXSLee,'backscan', scan{1});


function setback(hObject,eventdata,handles,hFigSAXSLee,hAxes)
isSAXSWAXS = get(handles.rd_isSAXSWAXS, 'value');
switch get(hObject, 'tag')
    case 'pb_setback1'
        listv = get(handles.ref_listbox, 'value');
        %backrefscan = getappdata(handles.pb_refresh_backsub, 'refscan');
        backrefscan = evalin('base', 'refscan');
        [scan, ~] = SAXSLee_loadandplot_reflinedata(backrefscan, listv, hAxes, 'BACK', isSAXSWAXS);
        setappdata(hFigSAXSLee,'backscan', scan{1});
    case 'pb_setback'
        listv = get(handles.ref_listbox_avg, 'value');
        backrefscan = getappdata(handles.pb_refresh_avg, 'backrefscan');
        [scan, ~] = SAXSLee_loadandplot_reflinedata(backrefscan, listv, hAxes, 'BACK', isSAXSWAXS);
        setappdata(hFigSAXSLee,'backscan', scan{1});
end
