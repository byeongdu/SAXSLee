function drawContinousBack(varargin)
% function drawContinousBack(arg, figurehandle)
% A function to draw arbitrary background.
%
% When this background drawing is done, it will return 
% FigUdata = get(gcf, 'userdata')
%    set(Hfig, 'WindowButtonDownFcn', FigUdata.WBD);
%    set(Hfig, 'WindowButtonMotionFcn', FigUdata.WBMF);
isSAXSLee = 0;
if numel(varargin) == 1;
    arg = varargin{1};
    Hfig = findall(0,'Tag','SAXSLee_Fig');
    if ~isempty(Hfig)
        isSAXSLee = 1;
    else
        Hfig = gcf;
    end
end

if numel(varargin) == 2;
    arg = varargin{1};
    Hfig = varargin{2};
    if strcmp(get(Hfig, 'Tag'), 'SAXSLee_Fig')
        isSAXSLee = 1;
    end
end

% When the windowbuttonDownFcn or WindowButtonMotionFcn is fired.
if numel(varargin) > 2;
    arg = varargin{3};
    Hfig = varargin{4};
    if strcmp(get(Hfig, 'Tag'), 'SAXSLee_Fig')
        isSAXSLee = 1;
    end
end

if isSAXSLee
    hAxes = findall(Hfig,'Tag','SAXSLee_Axes');
else
    figure(Hfig);
    hAxes = gca;
end

switch arg
    case 'start'
%        Hfig = gcf;
        Userdata = get(Hfig, 'userdata');
        Userdata.WBD = get(Hfig, 'WindowButtonDownFcn');
        Userdata.WBMF = get(Hfig, 'WindowButtonMotionFcn');
        if ~isfield(Userdata, 'Hline')
            Userdata.Hline = [];
            Userdata.posiold = [];
            Userdata.Hfig = Hfig;
        else
            try
                delete(Userdata.Hline)
            catch
                h = findobj(Hfig, 'tag', 'lnbkg');
                delete(h);
            end
            Userdata.Hline = [];
            Userdata.posiold = [];
            Userdata.Hfig = Hfig;
            
        end
        set(Hfig, 'userdata', Userdata);
        set(Hfig, 'WindowButtonDownFcn', {@drawContinousBack, 'down', Hfig});
        %set(Hfig, 'WindowButtonMotionFcn', 'drawContinousBack(''downmove'');');
        set(Hfig, 'WindowButtonMotionFcn', {@drawContinousBack, 'downmove', Hfig});

    case 'down'
        FigUdata = get(Hfig, 'userdata');
        ButtonDownOnImage(Hfig, FigUdata);
    case 'downmove'
        FigUdata = get(Hfig, 'userdata');
        MotionFcn(Hfig, FigUdata);
end

function ButtonDownOnImage(Hfig, FigUdata)
%figureHandle = gcbf;
%FigUdata = get(Hfig, 'userdata');
if strcmp(get(Hfig, 'selectiontype'), 'alt')
    delete(FigUdata.Hline(end));
    FigUdata.Hline(end) = [];
    if ~isempty(FigUdata.Hline)
        xold = (get(FigUdata.Hline(end), 'xdata'));
        yold = (get(FigUdata.Hline(end), 'ydata'));
        FigUdata.posiold = [xold(2), yold(2)];
    else
        FigUdata.posiold = [];
    end
%    set(Hfig, 'userdata', FigUdata);
elseif strcmp(get(Hfig, 'selectiontype'), 'extend') || strcmp(get(Hfig, 'selectiontype'), 'open')
    % When double click.
    set(Hfig, 'WindowButtonDownFcn', '');
    set(Hfig, 'WindowButtonMotionFcn', '');
    %set(Hfig, 'WindowButtonDownFcn', FigUdata.WBD);
    %set(Hfig, 'WindowButtonMotionFcn', FigUdata.WBMF);
    
    
    %FigUdata.Hline = [];
    
    Hdata = findobj(gcbf, 'type', 'line', 'tag', 'lnbkg');
    xdata = get(Hdata, 'xdata');%xdata = xdata(:);
    ydata = get(Hdata, 'ydata');%ydata = ydata(:);
    if numel(Hdata) == 1;
        xdata = xdata(:);
        ydata = ydata(:);
    elseif numel(Hdata) > 1
        xdata = [xdata{:}]';
        ydata = [ydata{:}]';
    end
    
    [xv, xi] = unique(xdata);
    yv = ydata(xi);

    % xd is required............
    b = findobj(hAxes, 'type', 'line');
    a = findobj(hAxes, 'tag', 'lnbkg');
    Hdata = setdiff(b, a);
    hand_data = contains_replace(get(Hdata, 'tag'), 'data');
%     if exist('contains', 'file') == 2
%         hand_data = contains(get(Hdata, 'tag'), 'data');
%     else
%         hand_data = zeros(size(Hdata));
%         for i=1:numel(Hdata)
%             hand_data(i) = ~isempty(strfind(get(Hdata(i), 'tag'), 'data'));
%         end
%     end
    xdo = get(Hdata(hand_data), 'xdata');
    xdo = xdo(:); 
    
    if numel(xdo) < 1
        disp('Please select a line of data')
        set(Hfig, 'userdata', FigUdata);
        return
    end
    
    if ~isempty(FigUdata.Hline)
        delete(FigUdata.Hline);
        FigUdata.Hline(end) = [];
    end
    t = [];
     for i=1:length(FigUdata.Hline)
         if ~ishandle(FigUdata.Hline(i))
             t = [t,i];
         end
     end
     FigUdata.Hline(t) = [];
    
    
    % ---------------------------
    % Interpolate the selected spots
    % -------------------------------------
    if iscell(xdo)
        xdo = xdo{end};
    else
        xdo = xdo(:);
    end
    if strcmp(get(hAxes, 'YScale'), 'log')
        yv = log(yv);
    end
    if strcmp(get(hAxes, 'Xscale'), 'log')
        xv = log(xv);
        if iscell(xdo)
            xdo = xdo{1};
        end
        xd = xdo+eps;
        xd = log(xd);
    else
        xd = xdo;
    end
    bkg = interp1(xv, yv, xd);
    if strcmp(get(gca, 'Yscale'), 'log');
        bkg = exp(bkg);
    end
    if strcmp(get(gca, 'Xscale'), 'log');
        xd = exp(xd);
    end
    % ------------------------------------
    
%    
    scan = {};
    if isSAXSLee
        hAxes = findobj(Hfig,'Tag','SAXSLee_Axes');
        scan{1}.colData = [xd(:), bkg(:), zeros(size(bkg(:)))];
        scan{1}.Tag = 'lnbkg';
        NoldL = numDatasetonGraph(hAxes);
        setappdata(Hfig,'backscan', scan{1});
        SAXSLee_plot(scan, NoldL, hAxes, 'BACK');        
    else
        bkghandle = line('parent', hAxes, ...
            'xdata', xd, ...
            'ydata', bkg, ...
            'color', 'r', ...
            'tag', 'back');
    end

    
    
elseif strcmp(get(Hfig, 'selectiontype'), 'normal')
    %axesHandle = findobj(Hfig, 'type', 'axes');
    posi = get(hAxes, 'CurrentPoint');
    posi = [posi(1,1), posi(1,2)];
    FigUdata.Hline = drawline(FigUdata.Hline, posi, posi);
    if isempty(FigUdata.posiold)
        FigUdata.posiold = posi;
    else
        FigUdata.posiold = posi;
    end
end

set(Hfig, 'userdata', FigUdata);
end

function MotionFcn(Hfig, FigUdata)
if isempty(FigUdata.Hline)
    return
end
if isempty(FigUdata.posiold)
    return
end

axesHandle = findobj(Hfig, 'type', 'axes');
posi = get(axesHandle, 'CurrentPoint');
posi = [posi(1, 1), posi(1,2)];
moveline(FigUdata.Hline(end), posi);
%set(Hfig, 'userdata', FigUdata);
end

function Hline = drawline(Hline, posiold, posinew)
    if ~isempty(posiold)
        k = line('parent', hAxes, ...
            'xdata', [posiold(1), posinew(1)],...
            'ydata', [posiold(2), posinew(2)]);
        set(k, 'tag', 'lnbkg');
        Hline = [Hline, k];
    end
end

function moveline(H, posinew)
    if ~isempty(posinew)
        xold = (get(H, 'xdata'));
        yold = (get(H, 'ydata'));
        set(H, 'xdata', [xold(1), posinew(1)]);
        set(H, 'ydata', [yold(1), posinew(2)]);
    end
end
end