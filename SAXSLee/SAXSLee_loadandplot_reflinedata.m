function [scan, sc2] = SAXSLee_loadandplot_reflinedata(refscan, iSelected, hAxes, headerTag, isSW, loadoption)
% [scan, hLine] = SAXSLee_loadandplot_reflinedata(refscan, iSelected, hAxes, headerTag, isSW, loadoption)
% Load and Plot
% scan = SAXSLee_loadandplot_reflinedata(refscan, iSelected, hAxes, headerTag, isSW, loadoption)
% Load data only.

if nargin < 5
    isSW = 1;
    loadoption = [];
end
if nargin< 6
    loadoption = [];
end
% loading files.
numofdatatoplot = numel(iSelected);

if isSW
    fnc = cell(numofdatatoplot, 2);
else
    fnc = cell(numofdatatoplot, 1);
end

for i=1:numofdatatoplot
    filename = refscan(iSelected(i)).fn;
    if ~isfield(refscan(iSelected(i)), 'fullfn')
        fullfilename = fullfile(refscan.path, filename);
    else
        fullfilename = refscan(iSelected(i)).fullfn;
    end
    
    switch isSW
        case 0
            fnc{i, 1} = fullfilename;
        case 1
            
            %check whether SAXS and WAXS directory structure are like 12IDB 
            filepath = fileparts(fullfilename);
            if ~strcmpi(headerTag, 'REF')
                SAXSdir = strfind(filepath, [filesep, 'SAXS', filesep]);
            else
                SAXSdir = 0;
            end
            if SAXSdir % 12IDB like...
                filepath(SAXSdir+1) = 'S';
                fnc{i, 1} = fullfile(filepath, ['S',filename(2:end)]);
                filepath(SAXSdir+1) = 'W';
                fnc{i, 2} = fullfile(filepath, ['W',filename(2:end)]);
            else  % otherwise both SAXS and WAXS are at the same directory.
                fnc{i, 1} = fullfile(filepath, ['S',filename(2:end)]);
                fnc{i, 2} = fullfile(filepath, ['W',filename(2:end)]);
            end
    end    
end
if isempty(loadoption) % for default...
    loadoption.xcol = 1;
    loadoption.ycol = 2;
    loadoption.yerrcol = 3;
end
scan = SAXSLee_loaddata(fnc, loadoption);
if nargout==1
    sc2 = [];
else
    % sc2 contains experimental parameters and added to lines by SAXSLee_plot.m
    try
        Ndata = size(fnc, 1);
        sc2 = cell(Ndata,1);
        for i=1:Ndata
            [phd, ic1, eng, expt] = parseAvgfile(fnc{i, 1});
            sc2{i}.phd = phd;
            sc2{i}.ic = ic1;
            sc2{i}.energy = eng;
            sc2{i}.exposuretime = expt;
        end
        sc2fn = fieldnames(sc2{1});
        for i=1:numel(scan)
            for j=1:numel(sc2fn)
                scan{i}.(sc2fn{j}) = sc2{i}.(sc2fn{j});
            end
        end
    catch
        sc2 = [];
    end
end
SAXSLee_plot(scan, sc2, hAxes, headerTag);
% for i=1:numel(scan)
%     setappdata(hLine(i), 'path', scan(i).path);
% end
%NoldL = numDatasetonGraph(hAxes);
%hLine = SAXSLee_plot(scan, NoldL, hAxes, headerTag);
