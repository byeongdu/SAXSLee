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

% Last Modified by GUIDE v2.5 21-Dec-2017 10:37:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;

gui_Name = mfilename;
gui_State = struct('gui_Name',       gui_Name, ...
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
N = numel(findobj('-regexp', 'Name', 'Load Data from Dir'));
if N > 1
    str = sprintf(':%i', N);
else
    str = '';
end
set(gcf, 'name', ['Load Data from Dir', str]);

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


%     % Otherwise construct the fullfilename and Check and load the file.
%     % reference scan number start from 2... 
%     % load refscan
%     try
%         refscan = evalin('base', 'refscan');
%         if ~isfield(refscan, 'fn')
%             refscan = [];
%         end
%     catch
%         refscan = [];
%     end
%     
%     numdata = numel(refscan);
%         
    refscan = [];
    for i=1:numel(filename)
        if iscell(filename)
            fn = filename{i};
        else
            fn = filename(i);
        end
        fullfn = fullfile(filepath, fn);
        refscan(i).fn = fn;
        refscan(i).fullfn = fullfn;
        fnames = {refscan.fn};
    end
    
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
    


% --- Executes on button press in pb_saveasAbsIntensity.
function pb_saveasAbsIntensity_Callback(hObject, eventdata, handles)
% hObject    handle to pb_saveasAbsIntensity (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%hFigSAXSLee = SAXSLee;
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
%hPopupmenuY = findall(hFigSAXSLee,'Tag','SAXSLee_PopupmenuY');
refscan = evalin('base', 'refscan');
isSAXSWAXS = get(handles.rd_isSAXSWAXS, 'value');
option.xcol = str2double(get(handles.ed_Xcol, 'string'));
option.ycol = str2double(get(handles.ed_Ycol, 'string'));

if isempty(refscan)
    set(hPopupmenuY,'value', 1);
    set(hPopupmenuY,'String', ' ');
    return
end

%if strfind(get(hObject, 'string'), 'Plot')
%    set(hObject, 'string', 'Erase');
%end

listv = get(handles.ref_listbox, 'value');
scan = {};
SF = str2double(get(handles.ed_scalefactor, 'string'));
thickness = str2double(get(handles.ed_samplethickness, 'string'));

scan = SAXSLee_loadandplot_reflinedata(refscan, listv, [], '', isSAXSWAXS, option);
for i=1:numel(scan)
    if isfield(scan{i}, 'colData')
        scan{i}.colData(:,2:end)= scan{i}.colData(:,2:end)*SF/thickness;
    end
    if isfield(scan{i}, 'colWData')
        scan{i}.colWData(:,2:end)= scan{i}.colWData(:,2:end)*SF/thickness;
    end
end
SAXSLee_savedata(scan)
if numel(scan) == 1
    fprintf('File conversion is done.\n');
else
    fprintf('%i files are converted into Absolute intensity unit.\n', numel(scan));
end


function pb_refresh(hObject, eventdata, handles)
% This is obsolete function..
% left over from the previous version.
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
isSAXSWAXS = get(handles.rd_isSAXSWAXS, 'value');
option.xcol = str2double(get(handles.ed_Xcol, 'string'));
option.ycol = str2double(get(handles.ed_Ycol, 'string'));

if isempty(refscan)
    set(hPopupmenuY,'value', 1);
    set(hPopupmenuY,'String', ' ');
    return
end

%if strfind(get(hObject, 'string'), 'Plot')
%    set(hObject, 'string', 'Erase');
%end

listv = get(handles.ref_listbox, 'value');
scan = {};
%for i=1:1:numel(listv)
    %scan{i} = refscan.dat{listv(i)};
hLine = get(hFigSAXSLee, 'userdata');
if ~isfield(hLine, 'SAXS')
    hLine.SAXS = [];
end
[scan, hL] = SAXSLee_loadandplot_reflinedata(refscan, listv, hAxes, '', isSAXSWAXS, option);
if isSAXSWAXS
    if isfield(hLine, 'SAXS') & ~isfield(hLine, 'WAXS')
        hLine.WAXS = NaN*ones(size(hLine.SAXS));
    end
    hLine.SAXS = [hLine.SAXS, hL(1:length(hL)/2)];
    hLine.WAXS = [hLine.WAXS, hL(length(hL)/2+1:end)];
else
    hLine.SAXS = [hLine.SAXS, hL];
    if isfield(hLine, 'WAXS')
        hLine.WAXS = [hLine.WAXS, NaN*ones(size(hL))];
    end
end
%end
%setappdata(hFigSAXSLee,'refscan', refscan);
setappdata(hFigSAXSLee,'refscan', scan);
set(hFigSAXSLee, 'userdata', hLine);

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
    if strfind(get(tm(is), 'Tag'), 'BACK: ')
        delete(tm(is));
    end
end

function rmFFplot(hAxes)
tm = findobj(hAxes, 'type', 'line');
for is = 1:numel(tm);
    if strfind(get(tm(is), 'Tag'), 'FF: ')
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
refscan = evalin('base', 'refscan');
try
    backscan = evalin('base', 'backscan');
catch
    backscan = [];
end

if strfind(get(hObject, 'string'), 'Set the selected as background')
    set(hObject, 'string', 'Reset background');
else
    rmbackplot(hAxes)
    set(hObject, 'string', 'Set the selected as background');
    setappdata(hFigSAXSLee,'backscan', []);
    return;
end

listv = get(handles.ref_listbox, 'value');
[scan, hLine] = SAXSLee_loadandplot_reflinedata(refscan, listv, hAxes, 'BACK');
setappdata(hFigSAXSLee,'backscan', scan{1});


% --- Executes on button press in pb_Erase.
function pb_Erase_Callback(hObject, eventdata, handles)
% hObject    handle to pb_Erase (see GCBO)
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

%if strfind(get(hObject, 'string'), 'Plot')
%    set(hObject, 'string', 'Erase');
%end
hLine = get(hFigSAXSLee, 'userdata');
try
    tag = get(hLine.SAXS, 'tag');
catch
    hLine = [];
    set(hFigSAXSLee, 'userdata', hLine);
    return
end

if ~iscell(tag)
    tg{1} = tag;
else
    tg = tag;
end


listv = get(handles.ref_listbox, 'value');
rm = [];
for i=1:numel(listv)
    fn = refscan(listv(i)).fn;
    [~,fn,ext] = fileparts(fn);
    fn = [fn, ext];
    tgs = fn;
    tgs(strfind(tgs, '_')) = ' ';
    
    for k = 1:numel(hLine.SAXS)
        if strcmp(tgs, tg{k})
            rm = [rm, k];
        end
    end
    
%     if isSAXSWAXS
%         tgs(1) = 'W';
%         for k = 1:numel(hLine)
%             if strcmp(tgs, tg{k})
%                 rm = [rm, k];
%             end
%         end
%     end
end

if isempty(rm)
    disp('Selected one(s) is already erase')
    return
end

delete(hLine.SAXS(rm));
hLine.SAXS(rm) = [];
if isSAXSWAXS
    delete(hLine.WAXS(rm));
    hLine.WAXS(rm) = [];
end
set(hFigSAXSLee, 'userdata', hLine);  



function ed_CurrentDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to ed_CurrentDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_CurrentDirectory as text
%        str2double(get(hObject,'String')) returns contents of ed_CurrentDirectory as a double
dirname = get(hObject, 'string');
set(hObject, 'tooltipstring', dirname);
showDirectory(dirname, handles)

% --- Executes during object creation, after setting all properties.
function ed_CurrentDirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_CurrentDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_changedir.
function pb_changedir_Callback(hObject, eventdata, handles)
% hObject    handle to pb_changedir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
dirname = uigetdir(get(handles.ed_CurrentDirectory, 'tooltipstring'), ...
  'Choose Directory');
if ischar(dirname)
    showDirectory(dirname, handles)
end

function showDirectory(dirname, handles)

%     set(handles.ed_CurrentDirectory, 'string', ...
%       fixLongDirName(dirname), ...
%       'tooltipstring', dirname);
    set(handles.ed_CurrentDirectory, 'string', ...
      dirname, ...
      'tooltipstring', dirname);
    fileformat = get(handles.ed_filefilter, 'string');
    n = filefilter(dirname,fileformat, handles);

%     if ~isempty(n2)
%         n2 = strcat(repmat({'['}, 1, length(n2)), n2, ...
%             repmat({']'}, 1, length(n2)));
%         n = {n2{:}, n{:}};
%     end

    set(handles.ref_listbox, 'string', n, 'value', 1);
    
    refscan = [];
    for i=1:numel(n)
        if iscell(n)
            fn = n{i};
        else
            fn = n(i);
        end
        fullfn = fullfile(dirname, fn);
        refscan(i).fn = fn;
        refscan(i).fullfn = fullfn;
        fnames = {refscan.fn};
    end
    
%    set(handles.ref_listbox, 'String', fnames);
    assignin('base', 'refscan', refscan);
    hFigSAXSLee = evalin('base', 'SAXSLee_Handle');    
    settings = getappdata(hFigSAXSLee,'settings');
    settings.path = dirname;
    setappdata(hFigSAXSLee,'settings', settings);


%     if ~isempty(handles.imageID)
%       set(handles.SAXSImageViewer, 'selectiontype', 'normal');
%       set(handles.FileListBox, 'value', handles.imageID(1));
%       fileListBoxCallback(handles.FileListBox);
%     end
    
function n = filefilter(dirname,formatstring, handles)

    d = dir(fullfile(dirname, formatstring));
    d = d(~[d.isdir]);

%    sort files;
        sortstr = get(handles.pm_sortby, 'string');
        val = get(handles.pm_sortby, 'value');
        sortstring = sortstr{val};

    %sortstring = 'name';
    if numel(d) < 2
        n = {d.name};
    else
        if ischar(d(1).(sortstring))
            [~, tmpind] = sort({d.(sortstring)});
        else
            [~, tmpind] = sort([d.(sortstring)]);
        end
        tmpind = fliplr(tmpind);
        n = {d(tmpind).name};
    end

%     d2 = dir(dirname);
%     n2 = {d2.name};
%     n2 = n2([d2.isdir]);
%     ii1 = strcmp('.', n2); % logic of .
%     ii2 = strcmp('..', n2); % logic of ..
%     Log_dir = ii1 | ii2;
%     n2(Log_dir) = [];
        
function newdirname = fixLongDirName(dirname)
% Modify string for long directory names
    if length(dirname) > 20
      [~, tmp2] = strtok(dirname, filesep);
      if isempty(tmp2)
        newdirname = dirname;

      else
        % in case the directory name starts with a file separator.
        id = strfind(dirname, tmp2);
        tmp1 = dirname(1:id(1));
        [p, tmp2] = fileparts(dirname);
        if strcmp(tmp1, p) || isempty(tmp2)
          newdirname = dirname;

        else
          newdirname = fullfile(tmp1, '...', tmp2);
          tmp3 = '';
          while length(newdirname) < 20
            tmp3 = fullfile(tmp2, tmp3);
            [p, tmp2] = fileparts(p);
            if strcmp(tmp1, p)  % reach root directory
              newdirname = dirname;
              %break; % it will break because dirname is longer than 30 chars

            else
              newdirname = fullfile(tmp1, '...', tmp2, tmp3);

            end
          end
        end
      end
    else
      newdirname = dirname;
    end


function ed_filefilter_Callback(hObject, eventdata, handles)
% hObject    handle to ed_filefilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_filefilter as text
%        str2double(get(hObject,'String')) returns contents of ed_filefilter as a double
dirname = get(handles.ed_CurrentDirectory, 'tooltipstring');
showDirectory(dirname, handles)


% --- Executes during object creation, after setting all properties.
function ed_filefilter_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_filefilter (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_Xcol_Callback(hObject, eventdata, handles)
% hObject    handle to ed_Xcol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_Xcol as text
%        str2double(get(hObject,'String')) returns contents of ed_Xcol as a double


% --- Executes during object creation, after setting all properties.
function ed_Xcol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_Xcol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_Ycol_Callback(hObject, eventdata, handles)
% hObject    handle to ed_Ycol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_Ycol as text
%        str2double(get(hObject,'String')) returns contents of ed_Ycol as a double


% --- Executes during object creation, after setting all properties.
function ed_Ycol_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_Ycol (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_scalefactor_Callback(hObject, eventdata, handles)
% hObject    handle to ed_scalefactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_scalefactor as text
%        str2double(get(hObject,'String')) returns contents of ed_scalefactor as a double


% --- Executes during object creation, after setting all properties.
function ed_scalefactor_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_scalefactor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_samplethickness_Callback(hObject, eventdata, handles)
% hObject    handle to ed_samplethickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_samplethickness as text
%        str2double(get(hObject,'String')) returns contents of ed_samplethickness as a double


% --- Executes during object creation, after setting all properties.
function ed_samplethickness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_samplethickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pm_sortby.
function pm_sortby_Callback(hObject, eventdata, handles)
% hObject    handle to pm_sortby (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_sortby contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_sortby
ed_filefilter_Callback(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function pm_sortby_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_sortby (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'string', {'date', 'name'});
