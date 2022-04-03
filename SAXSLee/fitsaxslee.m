function fitsaxslee(varargin)
%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
%settings = getappdata(hFigSAXSLee,'settings');
%[hdl,indx, xv] = SAXSLee_findcursor;
if numel(varargin) == 2
    xd = varargin{1};
    yd = varargin{2};
    Rrange = linspace(pi/xd(end)/10, pi/xd(1)*2, 200);
else
    % when it is call from SAXSLee.m
    hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
    hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
    hdl = findobj(hAxes, 'type', 'line', '-not', {'-regexp', 'tag', 'BACK'});
    tag = get(hdl, 'tag');
    xd = get(hdl, 'xdata');
    yd = get(hdl, 'ydata');
    if iscell(xd)
        [indx,tf] = listdlg('PromptString',{'Select a data.',''},...
    'SelectionMode','Multiple','ListString', tag);
        if isempty(indx)
            return
        end
        xd = xd{indx};
        yd = yd{indx};
    end

    % q range...
    prompt = {'qmin:','qmax:'};
    dlg_title = 'Input';
    num_lines = 1;
    defaultans = {num2str(min(xd)),...
        num2str(max(xd)),...
        };
    answer = inputdlg(prompt,dlg_title,num_lines,defaultans);
    if isempty(answer)
        disp('Cancel is selected')
        return
    end
    qmin = str2double(answer{1});
    qmax = str2double(answer{2});
    qv = [qmin, qmax];
    [~, indx(1)] = min(abs(xd-qmin));
    [~, indx(2)] = min(abs(xd-qmax));
% 
%     [hdl, indx, xv] = SAXSLee_findcursor;
%     if numel(indx) ~=2
%         cprintf('err', 'Error: You should select two points to fit....\n')
% %        indx = [];
%         return
%     end


    %t = findobj(hAxes, 'Tag', 'Dot');
    %if numel(t) ~= 2
    %    disp('error!! you have to select two points');
    %    return
    %end

    %ydref = get(t(1), 'Ydata');
    %tm = findobj(hAxes, 'type', 'line');
    %for i=1:numel(tm);
    %    if ~strcmp(get(tm(i), 'Tag'), 'Dot')
    %        xd = get(tm(i), 'Xdata');
    %        yd = get(tm(i), 'Ydata');
    %        if find(yd == ydref)
    %            hdl = tm(i);
    %            break
    %        end
    %    end
    %end

    %[indx, xv, yv] = getindx(t, hdl);
%     [indx, sortI] = sort(indx);
%     xv = xv(sortI);
%     qv = sort(xv);
    Drange = linspace(2*pi/qv(2)/10, 2*pi/qv(1), 200);
    Rrange = Drange/2;

%     xd = get(hdl, 'xdata');
%     yd = get(hdl, 'ydata');
%     if iscell(xd)
%         if numel(xd) > 1
%             xd = xd{1};
%             yd = yd{1};
%         end
%     end
    xd = xd(indx(1):indx(2));
    yd = yd(indx(1):indx(2));

end





fm = spheretype(xd, Rrange);
iteration = 500;

%[y,ds,ox] = maxent(xd,yd,sqrt(abs(yd))*0.001,Rrange,iteration,[],fm);
[y,ds,ox] = maxent(xd,yd,sqrt(abs(yd))*0.001,Rrange,iteration,[],fm);
assignin('base', 'maxEnt_Int', y);
assignin('base', 'maxEnt_IandFit', [xd(:), yd(:), ox(:)]);
assignin('base', 'maxEnt_disr', [Rrange(:), ds(:)]);
assignin('base', 'maxEnt_ox', ox);
disp('fit done')
%
%    function [indx, xr, yr] = getindx(t, handle)
%        
%        xd = get(t, 'Xdata');
%        yd = get(t, 'Ydata');
%        xv = get(handle, 'xdata');
%        yv = get(handle, 'ydata');
%        indx = zeros(2,1);
%        xr=zeros(2,1);yr=zeros(2,1);
%        
%        for k=1:numel(xd)
%            indx(k) = find(xv == xd{k});
%            xr(k) = xv(indx(k));
%            yr(k) = yv(indx(k));
%        end
%    end
end