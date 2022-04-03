function colormarker = plotoption(varargin)
% plotoption 
% colormarker = plotoption(varargin)
% No arguement:
%       plotoption will return cell array of color and marker choice;
% two arguements: [linehandle, colormarker number];
%       then, plotoption will change the color and marker of the line
% example;
% x = 1:10;y=sin(x);figure;t = plot(x, y);plotoption(t, 9);
%
markersize = 6;
hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
if ~isempty(hFigSAXSLee)
    SAXSLee_setting = getappdata(hFigSAXSLee,'SAXSLee_setting');
else
    SAXSLee_setting = [];
end

if ~isempty(SAXSLee_setting)
    if isfield(SAXSLee_setting, 'markersize')
        markersize = SAXSLee_setting.markersize;
    end
end
if numel(varargin) == 0
    colr = {'b', 'g', 'r','c','m','k'};
    %colr = num2cell(colormap(jet(5)), 2);
    markr = {'o', 'v', 'h', '.', 'd','<','>','s','x', '+', '*', 'p','^'};
    colormarker = cell(numel(colr)*numel(markr), 1);
    for i=1:numel(markr)
        for j=1:numel(colr)
            colormarker{(i-1)*numel(colr) + j} = {colr{j}, markr{i}};
        end
    end
    return
end    

colormarker = plotoption;
ncm = numel(colormarker);

if numel(varargin) == 2
    hLine = varargin{1};
    cm = varargin{2};
    if cm > ncm
        cm = mod(cm, ncm)+1;
    end
    c = colormarker{cm}{1};
    m = colormarker{cm}{2};
    if isempty(m)
        set(hLine,...
        'Color',c,...
        'LineStyle','-',...
        'MarkerSize',markersize);
    else
        set(hLine,...
        'Color',c,...
        'LineStyle','-',...
        'Marker',m,...
        'MarkerSize',markersize);
    end
end

