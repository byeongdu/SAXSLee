function SAXSLee_scanplot(varargin)
% SCANPLOT Called by SAXSLee to plot scans.
% No input required, but assuming 'settings' and 'scan' are available.
% Displays the selected data marked in 'scan', scan.selectedIndex

%hFigSAXSLee = findobj(0,'Tag','SAXSLee_Fig');
hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
hAxes = findobj(hFigSAXSLee,'Tag','SAXSLee_Axes');

Nsel = get(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'value');
setall = evalin('base', 'setall');
settings = setall{Nsel}.settings;
setappdata(hFigSAXSLee,'settings', settings);
%settings = getappdata(hFigSAXSLee,'settings');
%settings = setall{Nsel};

file = setall{Nsel}.file;
pth = fileparts(file);
%scan = setall{Nsel}.scan;
%sfilen = setall{Nsel}.scan.filen;
%imagepath = settings.path;
%averagedpath = fullfile(settings.path, settings.averageDir);
settings.path = pth;
averagedpath = fullfile(pth, settings.averageDir);

if strcmp(get(hAxes, 'Nextplot'), 'replace')
    %cla(hAxes);
    hLine = findobj(hAxes, 'type', 'line');
    removedots(hLine)
%    NoldL = 0;
else
%    NoldL = numel(findobj(hAxes, 'type', 'line'));
end

fn = cell(numel(setall{Nsel}.scan.selectionIndex), 1);

for iSelection = 1:numel(setall{Nsel}.scan.selectionIndex)
    % --- if ydata has negative data,then ydataError = 0
    %mpthSAXS = '';mpthWAXS = '';mpth = '';
    cfile = setall{Nsel}.scan.filen{setall{Nsel}.scan.selectionIndex(iSelection)};
    if isfield(settings, 'atBeamline')
        if strcmp(settings.atBeamline, '12IDB')
%            fn = cell(numel(setall{Nsel}.scan.selectionIndex), 2);
            % file extension is now changed to 'dat'
            [~,fbody,~] = fileparts(cfile);
            cfile = [fbody '.dat'];
            switch lower(cfile(1))
                case 's'
                    mpthSAXS = 'SAXS';
                    mpthWAXS = 'WAXS';
                    fn1 = fullfile(settings.path, mpthSAXS, settings.averageDir, cfile);
                    fn2 = fullfile(settings.path, mpthWAXS, settings.averageDir, ['W', cfile(2:end)]);
                    fn{iSelection, 1} = fn1;
                    fn{iSelection, 2} = fn2;
                    settings.averageFileExt = '.dat';
                case 'p' % PE
                    mpthSAXS = 'PE';
                    fn1 = fullfile(settings.path, mpthSAXS, settings.averageDir, cfile);
                    fn{iSelection, 1} = fn1;
                    settings.averageFileExt = '.dat';
                    if size(fn, 2) > 1
                        fn(:, 2) = [];
                    end
            end
        end
        if strcmp(settings.atBeamline, '12IDC')
%            fn = cell(numel(setall{Nsel}.scan.selectionIndex), 1);
            % file extension is now changed to 'dat'
            [~,fbody,~] = fileparts(cfile);
            cfile = [fbody '.dat'];
            mpthSAXS = 'SAXS';
            fn1 = fullfile(settings.path, mpthSAXS, settings.averageDir, cfile);
            fn{iSelection, 1} = fn1;
            settings.averageFileExt = '.dat';
        end
        if strcmp(settings.atBeamline, 'PLS9A')
            % file extension is now changed to 'dat'
            [~,fbody,~] = fileparts(cfile);
            cfile = [fbody '.dat'];
            fn1 = fullfile(settings.path, settings.averageDir, cfile);
            fn{iSelection, 1} = fn1;
            settings.averageFileExt = '.dat';
        end
    else
        if isfield(settings, 'averageFileExt')
            fExt = settings.averageFileExt;
            [~, fbody] = fileparts(cfile);
            cfile = [fbody, fExt];
        end
        fn{iSelection, 1} = fullfile(averagedpath, cfile);
    end
end
sc = SAXSLee_loaddata(fn);
% sc2 contains experimental parameters and added to lines by SAXSLee_plot.m
if strcmp(settings.atBeamline, '12IDB')
    sc2 = SAXSLee_loadmeta(fn);
    sc2fn = fieldnames(sc2{1});
    for i=1:numel(sc)
        for j=1:numel(sc2fn)
            sc{i}.(sc2fn{j}) = sc2{i}.(sc2fn{j});
        end
    end
else
    sc2 = [];
end
SAXSLee_plot(sc, sc2, hAxes);
%hdl = SAXSLee_plot(sc, NoldL, hAxes);

for i=1:numel(setall{Nsel}.scan.selectionIndex)
    setall{Nsel}.scan.selection{i} = sc{i};
end
%settings.setall{Nsel}.scan = setall{Nsel}.scan;
%setall{Nsel}.scan = scan;
setall{Nsel}.settings = settings;
%setappdata(hFigSAXSLee,'settings', settings);
%setappdata(hFigSAXSLee,'setall', setall);
%assignin('base', 'settings',settings);
assignin('base', 'setall', setall);

refscanplot;
hObject = findobj('Tag', 'toolbarAutobacksub');
if strcmp(get(hObject, 'State'), 'on')
    autobacksub
end

% --- set title
[~,filename,~] = fileparts(file);
title_str = {...
    ['File: ',titlestr(filename),',   Scan ',num2str(setall{Nsel}.scan.selectionIndex)]...
    };
set(get(hAxes,'Title'),'String',title_str);
set(get(hAxes,'XLabel'),'String', sprintf('q (%c^{-1})', char(197)), 'fontsize', 12, 'fontname', 'arial');
% --- determine legend
%curvelegend(hFigSAXSLee);


%assignin('base','hAxes',hAxes);
    function removedots(linehandle)
    tmp = get(linehandle, 'Userdata');
    %try
    delete(linehandle);

    %try
    if ~isempty(tmp)   % if there is dot (SAXSLee_datalabel.m) on hLine
        if iscell(tmp)
            for kk=1:numel(tmp)
                if numel(tmp{kk}) == 2
                    tmptxt = tmp{kk}(2);
                    %tmptu = get(tmptxt, 'userdata');
                    %tmpdot = tmptu(2);
                    delete(tmptxt);
                    %delete(tmpdot);
                    %delete(tmp{kk}(1));
                end
            end
        end
    end
    %catch
    %end
