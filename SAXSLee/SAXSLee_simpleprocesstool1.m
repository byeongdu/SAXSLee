function varargout = SAXSLee_simpleprocesstool1(varargin)
% SAXSLEE_SIMPLEPROCESSTOOL1 MATLAB code for SAXSLee_simpleprocesstool1.fig
%      SAXSLEE_SIMPLEPROCESSTOOL1, by itself, creates a new SAXSLEE_SIMPLEPROCESSTOOL1 or raises the existing
%      singleton*.
%
%      H = SAXSLEE_SIMPLEPROCESSTOOL1 returns the handle to a new SAXSLEE_SIMPLEPROCESSTOOL1 or the handle to
%      the existing singleton*.
%
%      SAXSLEE_SIMPLEPROCESSTOOL1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAXSLEE_SIMPLEPROCESSTOOL1.M with the given input arguments.
%
%      SAXSLEE_SIMPLEPROCESSTOOL1('Property','Value',...) creates a new SAXSLEE_SIMPLEPROCESSTOOL1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SAXSLee_simpleprocesstool1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SAXSLee_simpleprocesstool1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SAXSLee_simpleprocesstool1

% Last Modified by GUIDE v2.5 13-Mar-2017 12:02:43

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SAXSLee_simpleprocesstool1_OpeningFcn, ...
                   'gui_OutputFcn',  @SAXSLee_simpleprocesstool1_OutputFcn, ...
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


% --- Executes just before SAXSLee_simpleprocesstool1 is made visible.
function SAXSLee_simpleprocesstool1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SAXSLee_simpleprocesstool1 (see VARARGIN)

% Choose default command line output for SAXSLee_simpleprocesstool1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SAXSLee_simpleprocesstool1 wait for user response (see UIRESUME)
% uiwait(handles.SAXSLee_simpleprocesstool1);


% --- Outputs from this function are returned to the command line.
function varargout = SAXSLee_simpleprocesstool1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pb_integrate.
function pb_integrate_Callback(hObject, eventdata, handles)
% hObject    handle to pb_integrate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hdl, indexp, qROI] = get_LineandROI;
cprintf('_blue', 'Integrated data will be put into the variable SLout.\n');
SL_out = [];
k = 1;
SPECfile = [];
try
    s = evalin('base', 'setall');
catch
    s = [];
end
if ~isempty(s)
    SPECfile = s{1}.file;
end
if ~isempty(get(handles.ed_specfilename, 'string'))
    SPECfile = get(handles.ed_specfilename, 'string');
end

if ~isempty(SPECfile)
    fprintf('Your Log filename is %s.\n', SPECfile)
end

isLinecut = getappdata(gcbf, 'isLinecut');
if isempty(isLinecut)
    isLinecut = 0;
end
if size(indexp, 1) == numel(hdl)
    hdl_indexp_equal = 1;
else
    hdl_indexp_equal = 0;
end

for i = 1:numel(hdl)
    [xd, yd, zd] = get_data(hdl(i));
    if hdl_indexp_equal
        indx = indexp(i, :);
    else
        indx = indexp;
    end
    if numel(xd)<1
        continue
    end
    
    if min(xd) > min(qROI)
        continue;
    end
    if max(xd) < max(qROI)
        continue;
    end
    
    if numel(indx) == 2
        xd = xd(indx(1):indx(2));
        yd = yd(indx(1):indx(2));
        zd = zd(indx(1):indx(2));
    end
    % if xd(1) is not the same with qROI(1)..
    if indx(1) == indx(2)
        continue;
    end
%     if abs(xd(1)-qROI(1)) > 0.001*qROI(1)
%         continue;
%     end
    if ~isempty(xd)
        if numel(xd) > 1
            z = trapz(xd, yd);
        else
            z = yd;
        end
        dtname = get(hdl(i), 'tag');
        t = strfind(dtname, ' ');
        dtname(t) = '_';
        ind = APS_getfileindex(dtname);
        if ~isempty(SPECfile)
            c = get_fileinfo(SPECfile, dtname, isLinecut);
            SL_out.info{k} = c;
            c.intensity = [];
            c.name = [];
        end
        if ~isempty(ind)
            SL_out.fileindex(k) = ind;
        end
        SL_out.intensity(k) = z;
        SL_out.name{k} = dtname;
        k = k+1;
    end
end    
assignin('base', 'SLout', SL_out);
cprintf('_blue', 'Done.\n');
cprintf('_blue', 'If you want to extract a particular field from SLout,\n')
cprintf('_blue', 'try like, cellfun(@(x) x.Exposuretime, SLout)\n');

figure; 
if isfield(SL_out, 'info')
    t = cellfun(@(x) x.Time, SL_out.info);
    plot(t-t(end), SL_out.intensity, 'ro-');
    xlabel('Time (s)', 'fontsize', 15);
else
    plot(SL_out.fileindex, SL_out.intensity, 'ro-')
    xlabel('Fileindex', 'fontsize', 15);
end
ylabel('Integrated Intensity', 'fontsize', 15);
cprintf('_blue', 'If SPECFILE was provided, try t = cellfun(@(x) x.Time, SLout.info)\n');
cprintf('_blue', 'and plot(t-t(1), SLout.intensity)\n');


function c = get_fileinfo(SPECfile, imgname, isLinecut)

imgname(strfind(imgname, ' ')) = '_';
if isLinecut
    pdash = strfind(imgname, '-');
    imgname = imgname(pdash(2)+1:end);
    imgname(strfind(imgname, '-')) = '_';
end
[~, fb] = fileparts(imgname);
if (contains(fb, '#') && contains(fb, ':'))
    p = strfind(fb, ':');
    fb(1:p(1)+3) = [];
end
    
fb = [fb, '.*'];
c = specSAXSn2(SPECfile, fb);

function [hdl, indx, qROI] = get_LineandROI(varargin)
    hmin = findobj(gcbf, 'tag', 'edqmin');
    hmax = findobj(gcbf, 'tag', 'edqmax');
    qmin = str2double(get(hmin, 'string'));
    qmax = str2double(get(hmax, 'string'));
    %indx = unique(indx);
    hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
    hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
    hdl = findobj(hAxes, 'type', 'line', '-not', {'-regexp', 'tag', 'BACK'});
    qROI = [qmin, qmax];
%     if numel(hdl) > 0
%         i = 1;
%         xd = get(hdl(i), 'xdata');
%         [~, indx(i, 1)] = min(abs(xd-qmin));
%         [~, indx(i, 2)] = min(abs(xd-qmax));
%     end
    for i = 1:numel(hdl)
        xd = get(hdl(i), 'xdata');
        [~, indx(i, 1)] = min(abs(xd-qmin));
        [~, indx(i, 2)] = min(abs(xd-qmax));
    end
%doth = findobj(hAxes, 'tag', 'Dot');
% hdl = setdiff(hdl, doth);
% [~, indx, qROI] = SAXSLee_findcursor;
% indx = unique(indx);
% qROI = sort(qROI);
% if numel(indx) == 0;
%     indx = [];
% elseif ((numel(indx) == 1) | (numel(indx)>2))
%     error('Number of pointers is not 0 or 2')
% end

function [xd, yd, zd] = get_data(h)
    xd = get(h, 'xdata');
    if numel(xd)<1
        yd = [];
        zd = [];
        return
    end
    yd = get(h, 'ydata');
    zd = getappdata(h,'yDataError');

% --- Executes on button press in pb_invariant.
function pb_invariant_Callback(hObject, eventdata, handles)
% hObject    handle to pb_invariant (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hdl, indexp, qROI] = get_LineandROI;
cprintf('_blue', 'Invariant will be put into the variable SLout.\n');
SL_out = [];
k = 1;
SPECfile = [];
try
    s = evalin('base', 'setall');
catch
    s = [];
end
if ~isempty(s)
    SPECfile = s{1}.file;
end
if ~isempty(get(handles.ed_specfilename, 'string'))
    SPECfile = get(handles.ed_specfilename, 'string');
end

if ~isempty(SPECfile)
    fprintf('Your Log filename is %s.\n', SPECfile)
end
isLinecut = getappdata(gcbf, 'isLinecut');
if isempty(isLinecut)
    isLinecut = 0;
end
if size(indexp, 1) == numel(hdl)
    hdl_indexp_equal = 1;
else
    hdl_indexp_equal = 0;
end

for i = 1:numel(hdl)
    [xd, yd, zd] = get_data(hdl(i));
    if numel(xd)<2
        continue
    end
    if hdl_indexp_equal
        indx = indexp(i, :);
    else
        indx = indexp;
    end
    if min(xd) > min(qROI)
        continue;
    end
    if max(xd) < max(qROI)
        continue;
    end
    
    if numel(indx) == 2
        xd = xd(indx(1):indx(2));
        yd = yd(indx(1):indx(2));
        zd = zd(indx(1):indx(2));
    end
    % if xd(1) is not the same with qROI(1)..
%     if abs(xd(1)-qROI(1)) > 0.001*qROI(1)
%         continue;
%     end
    
    if ~isempty(xd)
        if numel(xd) > 1
            z = trapz(xd, yd.*xd.^2);
        else
            z = yd*xd^2;
        end
        dtname = get(hdl(i), 'tag');
        t = strfind(dtname, ' ');
        dtname(t) = '_';
        try
            ind = APS_getfileindex(dtname);
        catch
            ind = [];
        end
        if ~isempty(SPECfile)
            c = get_fileinfo(SPECfile, dtname, isLinecut);
            c.Q = [];
            c.name = [];
            SL_out.info{k} = c;
        end
        if ~isempty(ind)
            SL_out.fileindex(k) = ind;
        end
        SL_out.Q(k) = z;
        SL_out.name{k} = dtname;
        k = k+1;
    end
end    
assignin('base', 'SLout', SL_out);
cprintf('_blue', 'Done.\n');

if isfield(SL_out, 'info')
    if isfield(SL_out.info, 'Time')
        t = cellfun(@(x) x.Time, SL_out.info);
        figure;
        plot(t-t(end), SL_out.Q, 'ro-');
        xlabel('Time (s)', 'fontsize', 15);
    end
else
    if ~isempty(SL_out.fileindex)
        figure;
        plot(SL_out.fileindex, SL_out.Q, 'ro-')
        xlabel('Fileindex', 'fontsize', 15);
    end
end

ylabel('Invariant', 'fontsize', 15);
cprintf('_blue', 'If you want to extract a particular field from SLout,\n')
cprintf('_blue', 'try like, cellfun(@(x) x.Exposuretime, SLout)\n');
cprintf('_blue', 'If SPECFILE was provided, try t = cellfun(@(x) x.Time, SLout.info)\n');
cprintf('_blue', 'and plot(t-t(1), SLout.Q)\n');


function ed_specfilename_Callback(hObject, eventdata, handles)
% hObject    handle to ed_specfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ed_specfilename as text
%        str2double(get(hObject,'String')) returns contents of ed_specfilename as a double


% --- Executes during object creation, after setting all properties.
function ed_specfilename_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ed_specfilename (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_loadspecfile.
function pb_loadspecfile_Callback(hObject, eventdata, handles)
% hObject    handle to pb_loadspecfile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    prePath = pwd;
    % --- open file
    [filename, filepath] = uigetfile( ...
        {'*.*','SPEC data file (*.*)'}, ...
        'Select SPEC data file');
    % If "Cancel" is selected then return
    if isequal([filename,filepath],[0,0])
        restorePath(prePath);
        return
    end
    fullfilename = fullfile(filepath, filename);
set(handles.ed_specfilename, 'string', fullfilename);


% --- Executes when selected object is changed in uibuttongroup1.
function uibuttongroup1_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uibuttongroup1 
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
isLinecut = 0;
if strcmp(get(eventdata.NewValue, 'tag'), 'rb_datatype1')
    isLinecut = 1;
end
setappdata(gcbf, 'isLinecut', isLinecut)


% --- Executes on button press in pb_imageconversion.
function pb_imageconversion_Callback(hObject, eventdata, handles)
% hObject    handle to pb_imageconversion (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[hdl, indexp, qROI] = get_LineandROI;
cprintf('_blue', 'Converted image will be put into the variable SLout.\n');
SL_out = [];
k = 1;
SPECfile = [];
try
    s = evalin('base', 'setall');
catch
    s = [];
end
if ~isempty(s)
    SPECfile = s{1}.file;
end
if ~isempty(get(handles.ed_specfilename, 'string'))
    SPECfile = get(handles.ed_specfilename, 'string');
end

if ~isempty(SPECfile)
    fprintf('Your Log filename is %s.\n', SPECfile)
end
isLinecut = getappdata(gcbf, 'isLinecut');
if isempty(isLinecut)
    isLinecut = 0;
end
if size(indexp, 1) == numel(hdl)
    hdl_indexp_equal = 1;
else
    hdl_indexp_equal = 0;
end

for i = 1:numel(hdl)
    [xd, yd, zd] = get_data(hdl(i));
    if numel(xd)<2
        continue
    end
    if hdl_indexp_equal
        indx = indexp(i, :);
    else
        indx = indexp;
    end
    if numel(indx) == 2
        xd = xd(indx(1):indx(2));
        yd = yd(indx(1):indx(2));
        zd = zd(indx(1):indx(2));
    end
    if indx(1)==indx(2)
        continue;
    end
%     % if xd(1) is not the same with qROI(1)..
%     if abs(xd(1)-qROI(1)) > 0.001*qROI(1)
%         continue;
%     end
    
    SL_out.q = xd;
    if ~isempty(xd)
        SL_out.image(:,k) = yd(:);
        dtname = get(hdl(i), 'tag');
        t = strfind(dtname, ' ');
        dtname(t) = '_';
        ind = APS_getfileindex(dtname);
        if ~isempty(SPECfile)
            c = get_fileinfo(SPECfile, dtname, isLinecut);
            c.Q = [];
            c.name = [];
            SL_out.info{k} = c;
        end
        %SL_out{k}.Q = z;
        if ~isempty(ind)
            SL_out.fileindex(k) = ind;
        end
        SL_out.name{k} = dtname;
        k = k+1;
    end
end    
assignin('base', 'SLout', SL_out);
cprintf('_blue', 'Done.\n');
k = [SL_out.q(:), SL_out.image];
[fn, pa] = uiputfile(...
    {'*.txt','txt files (*.txt)'; ...
        '*.dat','dat files (*.dat)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Save as', 'image.txt');
    
if isequal(fn,0) || isequal(pa,0)
   disp('User pressed cancel')
else
    filen = fullfile(pa, fn);
    save(filen, 'k', '-ascii');
end
    
figure;
if isfield(SL_out, 'info')
    t = cellfun(@(x) x.Time, SL_out.info);
    imagesc(t-t(end), SL_out.q, (SL_out.image));
%    imagesc(t-t(end), SL_out.q, log10(SL_out.image));
    xlabel('Time (s)', 'fontsize', 15);
else
%    imagesc(SL_out.fileindex, SL_out.q, log10(SL_out.image));
    imagesc(SL_out.fileindex, SL_out.q, (SL_out.image));
    xlabel('Fileindex', 'fontsize', 15);
end
add_imagemenu
ylabel('q', 'fontsize', 15);
cprintf('_blue', 'If SPECFILE was provided, try t = cellfun(@(x) x.Time, SLout.info)\n');
cprintf('_blue', 'and imagesc(t-t(end), SLout.q, log10(SLout.image))\n');






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
