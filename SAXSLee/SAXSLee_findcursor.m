function [hdl, indx, xd, yd, data, tg, scanIndx, dothdl, txthdl] = SAXSLee_findcursor(varargin)
hFigSAXSLee = evalin('base', 'SAXSLee_Handle');

hAxes = findobj(hFigSAXSLee,'Tag','SAXSLee_Axes');
%settings = getappdata(hFigSAXSLee,'settings');
%scan = settings.scan;
hdl = [];indx = [];xd=[];yd=[];zd=[];tg=[];scanIndx=[];
t = findobj(hAxes, 'Tag', 'Dot');
if isempty(t)
    disp('error!! you did not select any curve');
    return
end    

hdl = t;
dothdl = t;
txthdl = t;
if mod(numel(dothdl), 2)
    error('Number of dot is not an even number')
end

for i=1:numel(t);
    tmp = get(t(i), 'userdata');
    hdl(i) = tmp(1); % handle of the line where dot is on.
    txthdl(i) = tmp(2); % handle of the text
end
% returns handles of cursors
if ~isempty(varargin)
    if strcmp(varargin{1}, 'A') || strcmp(varargin{1}, 'B') || strcmp(varargin{1}, 'any')
        hdl = [dothdl;txthdl];
        return
    end
end

if numel(dothdl)==2
    ydref = get(t(1), 'Ydata');
    tm = findobj(hAxes, 'type', 'line');
    for i=1:numel(tm);
       if ~strcmp(get(tm(i), 'Tag'), 'Dot')
           %xd = get(tm(i), 'Xdata');
           yd = get(tm(i), 'Ydata');
           try
               zd = getappdata(tm(i), 'yDataError');
           catch
               zd = [];
           end
           if find(yd == ydref)
               hdl = tm(i);
               break
           end
       end
    end


    [indx, xd, yd, xv, yv] = getindx(dothdl, hdl);
    data(:,1) = xv(:);
    data(:,2) = yv(:);
    if ~isempty(zd);
        data(:,3) = zd(:);
    end
else
    [~, hindex, cindex] = unique(hdl);
    lindex = hdl(hindex);
    [~, c] = sort(cindex);
    dothdl = dothdl(c);
    indx = cell(numel(lindex, 1));
    xd = indx;
    yd = indx;
    for i=1:numel(lindex)
        [tmp, q, intensity] = getindx(dothdl(((i-1)*2+1):((i-1)*2+2)), lindex(i));
        [tmp, ind] = sort(tmp, 'ascend');
        indx{i} = tmp;
        xd{i} = q(ind);
        yd{i} = intensity(ind);
    end
    hdl = lindex;
end

    function [indx, xr, yr, xv, yv] = getindx(t, handle)
        
        xdv = get(t, 'Xdata');
        %ydv = get(t, 'Ydata');
        xv = get(handle(1), 'xdata');
        yv = get(handle(1), 'ydata');
        indx = zeros(2,1);
        xr=zeros(2,1);yr=zeros(2,1);
        if numel(xdv) == 1;
            % array
            indx = find(xv == xdv);
            xr = xv(indx);
            yr = yv(indx);
            return
        end
        
        for k=1:numel(xdv)
            % cell
            indx(k) = find(xv == xdv{k});
            xr(k) = xv(indx(k));
            yr(k) = yv(indx(k));
        end
    end
end