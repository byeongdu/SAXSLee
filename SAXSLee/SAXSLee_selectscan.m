function SAXSLee_selectscan(varargin)
% SELECTSCAN Called by SAXSLee to open scan listbox and load scans to plot.
% if varargin is empty, this opens a dialog to ask to pick (a) scan(s) to
% plot.
% if input is -1, the most latest scan will be automatically selected.
%t = clock;ct = fix(t);
%fprintf('You clicked the select button at %i:%i:%i, SAXSLee_selectscan.m\n', ct(4:6));
hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
Nsel = get(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'value');
selScanFilter = get(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PushbuttonSelectScanFilter'), 'string');
settings = getappdata(hFigSAXSLee,'settings');
setall = evalin('base', 'setall');
istoolbarlegendon = get(findobj(hFigSAXSLee, 'tag', 'toolbarLegend'), 'State');
%settings = setall{Nsel};

file = setall{Nsel}.file;
scan = setall{Nsel}.scan;
if isempty(file) || isempty(scan.fidPos)
    return;
end

loadtype = 0;
if contains_replace(file, 'LoadDir')
    loadtype = 1;
end
if contains_replace(file, 'LoadImageDir')
    loadtype = 2;
end

if loadtype == 0
    % check dynamically if there are more scans added to spec file
    [fid,~] = fopen(file);

    fseek(fid,scan.fidPos(end),'bof');  % move fid to end of the last stored scan
    fgetl(fid);      % skip the currentline (head of the last stored scan);
    while feof(fid) == 0
        tempfid = ftell(fid);
        scanline = fgetl(fid);
        [fl, ~] = sscanf(scanline, '#Z %s', 1);
        if (~isempty(scanline) && ~isempty(fl))
            [~, R] = strtok(scanline, '#Z ');
            k = strfind(R, ' ');
            date = R(k(end-5):k(end-1)); % read date

            if flag == 1
                break;
            end
            scan.fidPos = [scan.fidPos,tempfid];
            scan.filen{length(scan.fidPos)} = fl;
            scan.date{length(scan.fidPos)} = date;
        end
    end

    fclose(fid);
    %settings.scan = scan;
    %setappdata(hFigSAXSLee,'settings',settings);
    %settings = getappdata(hFigSAXSLee,'settings');
    [~,filename,fileext] = fileparts(file);

else
    %setall = getappdata(hFigSAXSLee, 'setall');
    filename = file;
    fileext = '';
    if loadtype == 1
        setN = str2double(strtok(file, 'LoadDir'));
    elseif loadtype == 2
        setN = str2double(strtok(file, 'LoadImageDir'));
    end
    scan = setall{setN}.scan;
    %scan = settings.scan;
end
%t = clock;ct = fix(t);
%fprintf('The specfile is read at %i:%i:%i\n', ct(4:6));

indx = ones(size(scan.filen));
showindex = 1:numel(indx);
if ishandle(varargin{1})

    try             % highlight the current selection or last scan
        highlightScanIndex = sort(scan.selectionIndex);
    catch
        highlightScanIndex = length(scan.fidPos);
    end
    %HLindex = showindex;
    %HLindex(highlightScanIndex) = 1;
    if ~isempty(selScanFilter)
        filefilter = strsplit(selScanFilter);
        for nfilter = 1:numel(filefilter)
            indx = indx & contains_replace(scan.filen, filefilter{nfilter});
        end
        %hIndx = indx & HLindex;
        %highlightScanIndex = find(hIndx == 1);
        showindex = find(indx == 1);
        [~, highlightScanIndex] = intersect(showindex, highlightScanIndex);
    end
    if isempty(showindex)
        error('There found no file including the filter string');
    end

    [selection,ok] = listdlg(...
        'PromptString',['File: ',filename,fileext],...
        'SelectionMode','multiple',...
        'Name','Select Scan',...
        'OKString','Plot',...
        'ListSize',[300 400],...
        'ListString',scan.filen(showindex),...
        'InitialValue',highlightScanIndex);
    if isempty(selection) || ok == 0
        return;
    end
else
    scan.Nscan = numel(scan.filen);
    selection = length(scan.fidPos);
    scan.selection = cell(length(selection),1);
    if selection == scan.selectionIndex
        return
    else
        scan.selectionIndex = showindex(selection);        % store the selected scan index
    end
end

% when files are selected from the dialog box,
% load data and plot them.
try
    scan.selection = cell(length(selection),1);
    scan.selectionNumber = [];
    scan.selectionIndex = showindex(selection);        % store the selected scan index (can be different
                                            % from the real scan number is spec file, because of
                                            % the reset of scan number in spec)
    %settings.scan = scan;
catch
end
setall{Nsel}.scan = scan;
setall{Nsel}.settings = settings;
setappdata(hFigSAXSLee,'settings',settings);
%setappdata(hFigSAXSLee,'setall',setall);
assignin('base', 'setall', setall);
%t = clock;ct = fix(t);
%fprintf('Ready to plot at %i:%i:%i\n', ct(4:6));

SAXSLee_scanplot;
if strcmp(istoolbarlegendon, 'on')
    legend(findobj(hFigSAXSLee, 'type', 'axes'),'off')
    curvelegend(hFigSAXSLee);
end
%t = clock;ct = fix(t);
%fprintf('Loading and Plotting data are finished at %i:%i:%i\n', ct(4:6));
%fprintf('SAXSLee_selectscan.m is done\n');
zoom out;