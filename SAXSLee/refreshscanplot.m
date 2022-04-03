function refreshscanplot(varargin)
% REFRESHSCANPLOT Called by SAXSLee to reload scan(s) and plot.
%
hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
hPopupmenuY = findall(hFigSAXSLee,'Tag','SAXSLee_PopupmenuY');
settings = getappdata(hFigSAXSLee,'settings');
specfile = settings.file;
refscan = getappdata(hFigSAXSLee,'refscan');
hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
%if isempty(file) | isempty(scan) | ~isfield(scan,'selection') | isempty(scan.selection{1})
%    return;
%end

% --- set x, y axis labels

% multiple settings.....

% --- get current directory in order to restore after opening spec file
prePath = pwd;
% --- go to the stored directory; 
if ~isempty(specfile)
    [pathstr,name,ext] = fileparts(specfile);
    path_str = ['cd ','''',pathstr,''''];
    try 
        eval(path_str);
    catch  % if error, go to current directory
        path_str = ['cd ','''',prePath,''''];
    end
end

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
% why? because 1 will be always background.
if isempty(refscan)
    refscan{1} = [];
end

if iscell(filename)
    % multiple files..
    numdata = numel(filename);
    fn = filename;
    kN = 2:numdata+1;
    refscan{1} = [];
else
    numdata = 1;
    fn{1} = filename;
    kN = 0;
    for i=1:numel(refscan)
        if isempty(refscan{i})
            kN = i;
            break
        else
            kN = 0;
        end
    end
    if kN == 0
        kN = numel(refscan) + 1;
    end
end

for i=1:numdata
    try
        data = load(fullfile(filepath, fn{i}));
    catch
        data = [];
        disp('Error in loading reference data')
    end
    refscan{kN(i)}.colData = data;
    refscan{kN(i)}.Tag = fn{i};
    refscan{kN(i)}.path = filepath;
end
setappdata(hFigSAXSLee,'refscan', refscan);
SAXSLee_drawrefplot(refscan, hAxes, hPopupmenuY);

    function restorePath(prePath)
    path_str = ['cd ','''',prePath,''''];
    eval(path_str);
    end
end
