function varargout = SAXSLee_BackSub(varargin)
% SAXSLEE_BACKSUB MATLAB code for SAXSLee_BackSub.fig
%      SAXSLEE_BACKSUB, by itself, creates a new SAXSLEE_BACKSUB or raises the existing
%      singleton*.
%
%      H = SAXSLEE_BACKSUB returns the handle to a new SAXSLEE_BACKSUB or the handle to
%      the existing singleton*.
%
%      SAXSLEE_BACKSUB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAXSLEE_BACKSUB.M with the given input arguments.
%
%      SAXSLEE_BACKSUB('Property','Value',...) creates a new SAXSLEE_BACKSUB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SAXSLee_BackSub_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SAXSLee_BackSub_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SAXSLee_BackSub

% Last Modified by GUIDE v2.5 13-Aug-2018 11:41:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SAXSLee_BackSub_OpeningFcn, ...
                   'gui_OutputFcn',  @SAXSLee_BackSub_OutputFcn, ...
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


% --- Executes just before SAXSLee_BackSub is made visible.
function SAXSLee_BackSub_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SAXSLee_BackSub (see VARARGIN)

% Choose default command line output for SAXSLee_BackSub
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SAXSLee_BackSub wait for user response (see UIRESUME)
% uiwait(handles.SAXSLee_BackSub);


% --- Outputs from this function are returned to the command line.
function varargout = SAXSLee_BackSub_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pb_subtract_background.
function pb_subtract_background_Callback(hObject, eventdata, handles)
% hObject    handle to pb_subtract_background (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

u = get(get(handles.up_doption,'SelectedObject'), 'Value');
hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
hAxes = findobj(hFigSAXSLee,'Tag','SAXSLee_Axes');
f_user = str2double(get(handles.ed_fuser, 'string'));

% Background Subtraction
[fn, fn_in] = autobacksub(hFigSAXSLee, hAxes, f_user);
lineObj = findobj(hAxes, 'type', 'line', '-xor','-regexp', 'tag', '.avg_bsub');
set(lineObj, 'markersize', 0.1)

cabs = str2double(get(handles.ed_cabs, 'string'));
fIC = str2double(get(handles.ed_IC_cell_div_Time, 'string'));
fBS = str2double(get(handles.ed_BS_cell_div_Time, 'string'));
d_std = str2double(get(handles.edit_stdthickness, 'string'));

f = fBS/fIC;
%factor = cabs*f;
factor = cabs*d_std;
switch u
    case 1
        d = str2double(get(handles.edit_stdthickness, 'string'));
    case 2
        d = str2double(get(handles.ed_d1, 'string'));
    case 3
        lac = str2double(get(handles.ed_linearabscoeff, 'string'));
        d = [];
end

for i=1:numel(fn)
    % load data
    fileName = fn{i};
    %[pth, fb, ~] = fileparts(fileName);
    %avgfileName = fullfile(pth, [fb, '.avg']);
    avgfileName = fn_in{i};
    [phd, ic1, eng, expt]=parseAvgfile(avgfileName);
    T = phd/fBS*fIC/ic1;
    [~, data] = hdrload(fileName);
    if isempty(d)
        d = log(T)/(-lac);
    end
    data(:,2:3) = data(:, 2:3)*factor/d;
    try
        fid = fopen(fileName, 'w');
        %fprintf(fid, '%% Filename : %s\n', [fn, ext]);
        fprintf(fid, '%% Date & Time : %s\n', datestr(now));
        fprintf(fid, '%% X-ray Energy (keV) : %0.3f\n', eng);
        fprintf(fid, '%% Exposure Time (s) : %0.3f\n', expt);
        fprintf(fid, '%% Photodiode Value : %0.3f\n', phd);
        fprintf(fid, '%% Scalefactor for absolute intensity calibration : %0.3f\n', cabs);
        fprintf(fid, '%% Thickness of the standard(cm) : %0.5f\n', d_std);
        fprintf(fid, '%% Incident Flux compared to the value when the standard is measured : %0.5e\n', f);
        fprintf(fid, '%% Transmittance of the sample : %0.5e\n', T);
        fprintf(fid, '%% Sample Thickness (cm) : %0.5f\n', d);
%        fprintf(fid, '%% Multiply I(q) with the sample thickness (cm) to convert it into absolute units.\n');
        fprintf(fid, '%% \n');
        fprintf(fid, '%% q(A^-1)   I(q)    sqrt(I(q))\n');
        fclose(fid);
        dlmwrite(fileName,data,'delimiter','\t','precision','%.8f', '-append');
        fprintf('%s is processed\n', fileName);
        rtn = 1;
    catch
        rtn = 0;
        fprintf('Cannot write file on the disk.\n')
    end        
    
end


function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_cabs_Callback(hObject, eventdata, handles)
% hObject    handle to ed_cabs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_cabs as text
%        str2double(get(hObject,'String')) returns contents of ed_cabs as a double


% --- Executes during object creation, after setting all properties.
function ed_cabs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_cabs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


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

% if strfind(get(hObject, 'string'), 'Plot')
%     set(hObject, 'string', 'Erase');
% else
%     rmdataplot(hAxes)
%     set(hObject, 'string', 'Plot');
%     setappdata(hFigSAXSLee,'refscan', []);
%     return;
% end

listv = get(handles.ref_listbox, 'value');
%scan = {};
%for i=1:1:numel(listv)
    %scan{i} = refscan.dat{listv(i)};
[scan, sc2] = SAXSLee_loadandplot_reflinedata(refscan, listv, hAxes, 'REF', isSAXSWAXS);
fIC = str2double(get(handles.ed_IC_cell_div_Time, 'string'));
fBS = str2double(get(handles.ed_BS_cell_div_Time, 'string'));

for i=1:numel(sc2)
    phd = sc2{i}.phd;
    ic1 = sc2{i}.ic;
    T = phd/fBS*fIC/ic1;
    fprintf('Transmittance of %s is %0.4f.\n', scan{i}.Tag, T);
end    
%end
%setappdata(hFigSAXSLee,'refscan', refscan);
setappdata(hFigSAXSLee,'refscan', scan);

%SAXSLee_drawrefplot(scan, hAxes, hPopupmenuY);
% --- determine legend
curvelegend(hFigSAXSLee);

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


% --- Executes on button press in pb_refresh_backsub.
function pb_refresh_backsub_Callback(hObject, eventdata, handles)
% hObject    handle to pb_refresh_backsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
setall = evalin('base', 'setall');
hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
Nsel = get(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'value');
settings = setall{Nsel}.settings;
[pth, backsubdir] = SAXSLee_getfolders(settings);
backsubpath = fullfile(pth, filesep, backsubdir);

refscan = [];
filterstr = get(handles.ed_filter_backsub, 'string');
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

if isempty(refscan)
    set(handles.ref_listbox, 'String', '');
else
    set(handles.ref_listbox, 'String', {refscan.fn});
    if (get(handles.ref_listbox, 'value') > N)
        set(handles.ref_listbox, 'value', 1)
    end
end
assignin('base', 'refscan', refscan);

% --- Executes on button press in rd_isSAXSWAXS.
function rd_isSAXSWAXS_Callback(hObject, eventdata, handles)
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



function ed_linearabscoeff_Callback(hObject, eventdata, handles)
% hObject    handle to ed_linearabscoeff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_linearabscoeff as text
%        str2double(get(hObject,'String')) returns contents of ed_linearabscoeff as a double


% --- Executes during object creation, after setting all properties.
function ed_linearabscoeff_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_linearabscoeff (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_d1_Callback(hObject, eventdata, handles)
% hObject    handle to ed_d1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_d1 as text
%        str2double(get(hObject,'String')) returns contents of ed_d1 as a double


% --- Executes during object creation, after setting all properties.
function ed_d1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_d1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ed_d0_Callback(hObject, eventdata, handles)
% hObject    handle to ed_d0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_d0 as text
%        str2double(get(hObject,'String')) returns contents of ed_d0 as a double


% --- Executes during object creation, after setting all properties.
function ed_d0_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_d0 (see GCBO)
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



function ed_IC_cell_div_Time_Callback(hObject, eventdata, handles)
% hObject    handle to ed_IC_cell_div_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_IC_cell_div_Time as text
%        str2double(get(hObject,'String')) returns contents of ed_IC_cell_div_Time as a double


% --- Executes during object creation, after setting all properties.
function ed_IC_cell_div_Time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_IC_cell_div_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function ed_BS_cell_div_Time_Callback(hObject, eventdata, handles)
% hObject    handle to ed_BS_cell_div_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_BS_cell_div_Time as text
%        str2double(get(hObject,'String')) returns contents of ed_BS_cell_div_Time as a double


% --- Executes during object creation, after setting all properties.
function ed_BS_cell_div_Time_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_BS_cell_div_Time (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_showtransmittance.
function pb_showtransmittance_Callback(hObject, eventdata, handles)
% hObject    handle to pb_showtransmittance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function sc2 = load_info(handles)
contents = cellstr(get(handles.ref_listbox,'String'));
sel = contents{get(handles.ref_listbox,'Value')};
Ndata = numel(sel);
sc2 = cell(Ndata,1);

for i=1:Ndata
    [phd, ic1, eng, expt] = parseAvgfile(sel{i});
    sc2{i}.filename = sel{i};
    sc2{i}.phd = phd;
    sc2{i}.ic = ic1;
    sc2{i}.energy = eng;
    sc2{i}.exposuretime = expt;
end





function ed_fuser_Callback(hObject, eventdata, handles)
% hObject    handle to ed_fuser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_fuser as text
%        str2double(get(hObject,'String')) returns contents of ed_fuser as a double


% --- Executes during object creation, after setting all properties.
function ed_fuser_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_fuser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rb_doption0.
function rb_doption0_Callback(hObject, eventdata, handles)
% hObject    handle to rb_doption0 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rb_doption0



function edit_stdthickness_Callback(hObject, eventdata, handles)
% hObject    handle to edit_stdthickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_stdthickness as text
%        str2double(get(hObject,'String')) returns contents of edit_stdthickness as a double


% --- Executes during object creation, after setting all properties.
function edit_stdthickness_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_stdthickness (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
