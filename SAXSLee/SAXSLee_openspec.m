function SAXSLee_openspec(varargin)
% OPENSPEC Called by SAXSLee to load fids of scans in a selected spec file
%
prePath = pwd;

hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
settings = getappdata(hFigSAXSLee,'settings');
Nsel = get(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'value');
%setall = getappdata(hFigSAXSLee, 'setall');
try
    setall = evalin('base', 'setall');
    specfile = setall{Nsel}.file;
catch
    setall = {};
    specfile = '';
end
%setall = getappdata(hFigSAXSLee, 'setall');
%specfile = settings.file;
%scan = setall{Nsel}.scan;


if strcmp(get(varargin{1}, 'tag'), 'SAXSLee_MenuFileOpenCurrent')
    [~, b] = system('hostname');
    hostname = strtrim(b);
    specfile = '';
    if any(strcmp(hostname, {'purple', 'plum', 'grape', 'eggplant', 'green'}))
        currentspec12ID = '~/.currentspecdatafile';
        fid = fopen(currentspec12ID);
        if fid < 0
            error('~/.currentspecdatafile is not existing')
            return
        end
        while 1
            tline = fgetl(fid);
            if ~ischar(tline)
                break
            else
                specfile = tline;
            end
        end
        fclose(fid);
    else  % for windows, search current directory for specfile.
        a = dir('*');
        for i=1:numel(a)
            if ~a(i).isdir
                fid = fopen(a(i).name);
                rv = fread(fid, 2);
                fclose(fid);
                if numel(rv) >= 2
                    if strcmp(char(rv'), '#F')
                        specfile = a(i).name;
                        break
                    end
                end
            end
        end
        if isempty(specfile)
            message = {'A logfile is not found in the current directory.',...
            'Change user directory in the address bar on the main matlab terminal.'};
            uiwait(msgbox(message,'File Open Error','error','modal'));
            return
        else
            specfile = fullfile(pwd, filesep, specfile);
        end
    end
        
%    specfile = specfilename;

    % multiple settings.....
%     [filepath,name,ext] = fileparts(specfile);
%     %filename = [name,ext];
%     specfile = strcat(name,ext);

else% --- get current directory in order to restore after opening spec file
    % --- go to the stored directory; 
    if ~isempty(specfile)
        pathstr = fileparts(specfile);
        path_str = ['cd ','''',pathstr,''''];
        try 
            eval(path_str);
        catch  % if error, go to current directory
            %path_str = ['cd ','''',prePath,''''];
        end
    end
    % --- open file
    [filename, filepath] = uigetfile( ...
        {'*.*','All Files (*.*)'}, ...
        'Select Spec File');
    % If "Cancel" is selected then return
    if isequal([filename,filepath],[0,0])
        restorePath(prePath);
        return
    end
    % Otherwise construct the fullfilename and Check and load the file.

    specfile = fullfile(filepath,filename);
end




[fid,message] = fopen(specfile,'r');        % open file
if fid == -1                % return if open fails
    uiwait(msgbox(message,'File Open Error','error','modal'));
    % fclose(fid);
    restorePath(prePath);
    return;
end
scan = '';
scan.fidPos = [];
scan.filen = {};


% multiple settings.....
addYes = 1;
%specfiles = {};
[filepath,name,ext] = fileparts(specfile);
specfileNameonly = strcat(name,ext);
Nsel = numel(setall);
specfiles = cell(1, Nsel+1);

if Nsel > 0
    for i=1:numel(setall)
        %[~,name,ext] = fileparts(setall{i}.file);
        %fname = strcat(name,ext);
        if strcmp(specfile, setall{i}.file)
            setall{i}.settings = settings;
            addYes = 0;
        end
        %specfiles{i} = fname;
    end

    if addYes == 0
        error('The file is already loaded previously')
        return
    end
end
Nsel = Nsel + 1;
setall{Nsel}.file = specfile;
setall{Nsel}.scan = scan;
settings.path = filepath;
setappdata(hFigSAXSLee,'settings',settings);


% set timebar
s=dir(specfile);
filesize=s.bytes;
%posFigSAXSLee = get(hFigSAXSLee,'position');
hTimebar = timebar('Please do NOT close while loading scans...','Loading Scans...');
posFigSAXSLee         = get(hFigSAXSLee,'position');
posFigTimebarOld    = get(hTimebar,'position');
posFigTimebarNew    = [...
    posFigSAXSLee(1) + 0.5*(posFigSAXSLee(3)-posFigTimebarOld(3)),...
    posFigSAXSLee(2) + 0.5*(posFigSAXSLee(4)-posFigTimebarOld(4)),...
    posFigTimebarOld(3),...
    posFigTimebarOld(4)];
set(hTimebar,...
    'WindowStyle','modal',...
    'position',posFigTimebarNew);
stopFlag = 0;

Bline = [];
while feof(fid) == 0
    tempfid = ftell(fid);
    scanline = fgetl(fid);
    
    % Read the beamline information
    % #B 12IDB
    if isempty(Bline)
        file = sscanf(scanline, '#B %s', 1);
        if ~isempty(file)
            settings.atBeamline = file;
            Bline = file;
        end
    end
    
    file = sscanf(scanline, '#Z %s', 1);
    
    if ~isempty(file)
        nfid = tempfid;
        
        [~, R] = strtok(scanline, '#Z ');
        k = strfind(R, ' '); 
        date = R(k(end-5):k(end-1)); % read date
        
        if stopFlag == 1
            break;
        end
        scan.fidPos = [scan.fidPos,nfid];
        scan.filen{length(scan.fidPos)} = file;
        scan.date{length(scan.fidPos)} = date;
        try
            timebar(hTimebar,tempfid/filesize);
        catch
            stopFlag = 1;
            break;
        end
    end
end

fclose(fid);     

if stopFlag == 0
    close(hTimebar);
end

if isempty(scan.filen) || stopFlag == 1
    uiwait(msgbox('Invalid file or no scan in this file','File Open Error','error','modal'));
            restorePath(prePath);   
            resetfigSAXSLee;            
    return;
end


mm = pwd;
m = strfind(filesep, mm);
if numel(m) > 1
    m = [m,numel(mm)+1];
    pth = mm(1:m(1)-1);
else
    pth = mm;
end

for i=2:numel(m)
    pth = strcat(pth, '\\', mm(m(i-1)+1:m(i)-1));
end

qpath = 1;
if isfield(settings, 'atBeamline')
    if strcmp(settings.atBeamline, '12IDB') || strcmp(settings.atBeamline, '12IDC') || strcmp(settings.atBeamline, 'PLS9A');
        pth = filepath;
        qpath = 0;
    end
end
if qpath == 1
    rtn = input(sprintf('where are 2D data? [%s] ', pth), 's');
    if isempty(rtn)
        pth = pwd;
    end
end

settings.path = pth;
setall{Nsel}.scan = scan;
setall{Nsel}.settings = settings;

% if addYes == 1;
%     setall{Nsel+1} = settings;
% else
%     setall{Nsel}.settings = settings;
% end

for i=1:Nsel
    [~, name, ext] = fileparts(setall{i}.file);
    specfiles{i} = [name, ext];
end
        

set(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'string', specfiles);

setappdata(hFigSAXSLee, 'settings', settings);
assignin('base', 'setall', setall);
%assignin('base', 'settings', settings);

restorePath(prePath);
resetfigSAXSLee;
legend off;


%=========================================================
% --- restore to previous path
%=========================================================
function restorePath(prePath)
path_str = ['cd ','''',prePath,''''];
eval(path_str);

% function [NormCol, EngCol] = readfirstline(imgname, histfile)
%     [p,n,e,v] = fileparts(imgname);
%     cnt = specSAXSn2(histfile, sprintf('%s%s*', n, e), 1);    
%     for kk=1:numel(cnt)
%         disp(sprintf('Data of column %d: %f', kk, cnt(kk)));
%     end
%     EngCol = input('What is the number of the energy column?:  ');
%     if EngCol == 0
%         EngCol = 7;
%     else
%         EngCol = EngCol + 2;
%     end
%     NormCol = input('What is the number of the column for normalization?:  ');
%     if NormCol == 0
%         NormCol = 5;
%     else
%         NormCol = NormCol + 2;
%     end
