function hLine = SAXSLee_plot(scan, scan2, hAxes, headerTag)
% SAXS and WAXS data format
%   .data
%   .fn
hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
h = findobj(hFigSAXSLee, 'type','uicontextmenu');
cla(hAxes);
delete(h);

Ndata = numel(scan);
if iscell(scan)
    sc = scan{1};
else
    sc = scan;
end
if isfield(sc, 'colWData')
    SAXSWAXS = 2;
else
    SAXSWAXS = 1;
end
if nargin < 4
    headerTag = '';
end

hLine = zeros(1, SAXSWAXS*Ndata);
if Ndata > 30
    colr = num2cell(colormap(jet(Ndata)), 2);
    %colr = colr(round(linspace(1,64,Ndata)));
    isMarker = 0;
else
    colr = plotoption;
    isMarker = 1;
end

for i=1:Ndata
    for SW=1:SAXSWAXS
        if SW==1
            if ~isfield(scan{i}, 'colData')
                fprintf('%s was not loaded.\n', scan{i}.Tag)
                continue
            end
            tmp = scan{i}.colData;
            cfile = scan{i}.Tag;
            wx = 0;
            if isfield(scan{i}, 'path')
                fpath = scan{i}.path;
            else
                fpath = '';
            end
        else
            if ~isfield(scan{i}, 'colData')
                fprintf('%s was not loaded.\n', scan{i}.WTag)
                continue
            end
            tmp = scan{i}.colWData;
            cfile = scan{i}.WTag;
            wx = Ndata;
            if isfield(scan{i}, 'Wpath')
                fpath = scan{i}.Wpath;
            else
                fpath = '';
            end
        end
        if strcmp(headerTag, 'REF')
            tgs = ['REF#', num2str(i), ': ', cfile];
        elseif strcmp(headerTag, 'BACK')
            tgs = ['BACK: ', cfile];
        elseif strcmp(headerTag, 'FF')
            tgs = ['FF: ', cfile];
        else
            tgs = cfile;
        end
   

        % remove underscore from the filename
        tgs(strfind(tgs, '_')) = ' ';
        % Plot on hAxes
        if isMarker
            hLine(i+wx) = line('Parent',hAxes,...
                'XData',tmp(:,1),...
                'YData',tmp(:,2),...
                'Tag',tgs,...
                'color', colr{i}{1},...
                'marker', colr{i}{2});
        else
            hLine(i+wx) = line('Parent',hAxes,...
                'XData',tmp(:,1),...
                'YData',tmp(:,2),...
                'Tag',tgs,...
                'color', colr{i,1});
        end
        setappdata(hLine(i+wx), 'yDataError', tmp(:,3));
        if wx > 0
            setappdata(hLine(i), 'isSAXSWAXS', 1);
            setappdata(hLine(i+wx), 'isSAXS', 0);
            setappdata(hLine(i+wx), 'isSAXSWAXS', 1);
            setappdata(hLine(i), 'WAXShandle', hLine(i+wx));
            setappdata(hLine(i), 'SAXShandle', hLine(i));
        else
            setappdata(hLine(i), 'isSAXSWAXS', 0);
            setappdata(hLine(i), 'isSAXS', 1);
        end
        if strcmp(headerTag, 'REF')
            setappdata(hLine(i), 'path', fpath);
            setappdata(hLine(i+wx), 'path', fpath);
        end
        if ~isempty(scan2)
            if iscell(scan2)
                scan2{i}.path = fpath;
                set(hLine(i+wx), 'userdata', scan2{i});
            end
        end
        SAXSLee_dataControlmenu(hLine(i+wx));
%        plotoption(hLine(i+wx), i + NoldL); This is too slow.
    end
end