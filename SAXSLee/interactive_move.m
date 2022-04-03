function interactive_move(varargin)
%
%function interactive_move(tag)
%
%Click and drag curves interactively
%Automatically select the pointed curve
%
%- Focus on figure first
%- Enable with interactive_move
%- Click outside of axes (gray area) to disable
%- Press x or y while draging to constraint x or y movements
%
%Copyright J.P. Rueff, Aout 2004, modified Juin 2005
% Modified 
% Byeongdu Lee, 10/23/2014, to be able to scale either log or linear.


%---handle initialization
onaxis = gca;
onfig = gcf;
handles = guidata(onaxis);
handles.macro_active=0;
%handles.lineObj = findobj(onaxis, 'Type', 'line');
handles.lineObj=[findobj(onaxis, 'Type', 'line');findobj(onaxis, 'Type', 'patch')];
handles.currentlineObj=0;
handles.key='';
guidata(onaxis,handles);

if nargin==0,tag=1;else tag=varargin{1};end

%---define callback routine on setup
if tag==1
%     disp('interactive_move enable')
    handles.init_state = uisuspend(onfig);guidata(onaxis,handles); %--save initial state

    set(onaxis,'XLimMode','manual','YLimMode','manual');

    set(onfig, 'windowbuttondownfcn', {@myclick,1});
    set(onfig, 'windowbuttonmotionfcn', {@myclick,2});
    set(onfig, 'windowbuttonupfcn', {@myclick,3});
    set(onfig, 'keypressfcn', {@myclick,4});
    %---define callback routine on delete
else
%      disp('interactive_move disable')
    set(onaxis,'NextPlot','replace')
    uirestore(handles.init_state);
end

%--------function to handle event
function myclick(h,event,type)

%handles=guidata(onaxis);

switch type
    case 1 %---Button down
        if strcmp(get(onfig, 'selectiontype'), 'alt')
            if isfield(handles, 'preObj');
                set(handles.preObj, 'xdata', handles.xData);
                set(handles.preObj, 'ydata', handles.yData);
                return
            end
        end
        out=get(onaxis,'CurrentPoint');
        handles.lineObj=[findobj(onaxis, 'Type', 'line');findobj(onaxis, 'Type', 'patch')];
        set(onaxis,'NextPlot','replace')
        set(onfig,'Pointer','crosshair');
        handles.xscale = get(onaxis, 'xscale');
        handles.yscale = get(onaxis, 'yscale');
        handles.macro_active=1;
        handles.xpos0=out(1,1);%--store initial position x
        handles.ypos0=out(1,2);%--store initial position y
        xl=get(onaxis,'XLim');yl=get(onaxis,'YLim');
        
        
        if ((handles.xpos0 > xl(1) & handles.xpos0 < xl(2)) & ...
                (handles.ypos0 > yl(1) & handles.ypos0 < yl(2))) %--disable if outside axes
            [handles.currentlineObj,handles.currentlinestyle] = ...
                line_pickup(handles.lineObj,[out(1,1) out(1,2)]);%--choose the right curve via line_pickup
            if handles.currentlineObj~=0 %--if curve foundd
                handles.xData = get(handles.lineObj(handles.currentlineObj), 'XData');%--assign x data
                handles.yData = get(handles.lineObj(handles.currentlineObj), 'YData');%--assign y data 
            end
            handles.currentTitle=get(get(onaxis, 'Title'), 'String');
            guidata(onaxis,handles)
            
            title(['[' num2str(out(1,1)) ',' num2str(out(1,2)) ']']);
        else
            interactive_move(0);
            SAXSLee_plotControl;
        end    
    case 2%---Button Move
        if handles.macro_active
            out=get(onaxis,'CurrentPoint');
            set(onfig,'Pointer','crosshair');
            title(['[' num2str(out(1,1)) ',' num2str(out(1,2)) ']']);
            
            if handles.currentlineObj~=0
                switch handles.key
                    case ''%--if no key pressed
                        xd = scaledata(handles.xData, handles.xscale, handles.xpos0, out(1,1));
                        yd = scaledata(handles.yData, handles.yscale, handles.ypos0, out(1,2));
                        set(handles.lineObj(handles.currentlineObj),'XData',xd);%-move x data
                        set(handles.lineObj(handles.currentlineObj),'YData',yd);%-move y data    
                        %handles.xData-(handles.xpos0-out(1,1));%-update x data
                        %handles.yData-(handles.ypos0-out(1,2));%-update y data
                        title(['[' num2str(out(1,1)) ',' num2str(out(1,2)) '], offset=[' num2str(handles.xpos0-out(1,1)) ',' num2str(handles.ypos0-out(1,2)) ']']);
                    case 'x'%--if x pressed
                        xd = scaledata(handles.xData, handles.xscale, handles.xpos0, out(1,1));
                        set(handles.lineObj(handles.currentlineObj),'XData',xd);%--move x data
                        %handles.xData-(handles.xpos0-out(1,1));%-update x data
                        title(['[' num2str(out(1,1)) ',' num2str(out(1,2)) '], offset=[' num2str(handles.xpos0-out(1,1)) ',0]']);
                    case 'y'%--if y pressed
                        yd = scaledata(handles.yData, handles.yscale, handles.ypos0, out(1,2));
                        set(handles.lineObj(handles.currentlineObj),'YData',yd);%--move y data
                        %handles.yData-(handles.ypos0-out(1,2));%-updata y data
                        title(['[' num2str(out(1,1)) ',' num2str(out(1,2)) '], offset=[0,' num2str(handles.ypos0-out(1,2)) ']']);
                    case 'a'%--if a pressed, move all curves
                        for i=1:length(handles.lineObj)
                            handles.yData=get(handles.lineObj(i), 'YData');
                            yd = scaledata(handles.yData, handles.yscale, handles.ypos0, out(1,2));
                            set(handles.lineObj(i),'YData',yd);%--move y data
    %                        handles.yData-(handles.ypos0-out(1,2));%-updata y data
                            title(['[' num2str(out(1,1)) ',' num2str(out(1,2)) '], offset=[0,' num2str(handles.ypos0-out(1,2)) ']']);
                        end
                end              
            end
            
            guidata(onaxis,handles)
        end
        
    case 3 %----Button up (cleanup some variable)
        set(onfig,'Pointer','arrow');
        set(onaxis,'NextPlot','add')
        if handles.currentlineObj~=0
            if ~isempty(findobj(handles.lineObj(handles.currentlineObj)))
                findobj(handles.lineObj(handles.currentlineObj))
                set(handles.lineObj(handles.currentlineObj),...
                    'LineStyle',handles.currentlinestyle)
            else
                handles.lineObj = [];
                handles.currentlineObj = 1;
            end
            
        end
        handles.preObj = handles.lineObj(handles.currentlineObj);
        handles.macro_active=0;
        handles.key='';
        title(handles.currentTitle);
        guidata(onaxis,handles)
        
    case 4 %----Button press
        handles.key=get(onfig,'CurrentCharacter');
        guidata(onaxis,handles)
end
end
    
    function data = scaledata(data, type, pos_old, pos)
    
    switch type
        case 'log'
            p = pos_old/pos;
            data = data/p;
        case 'linear'
            p = pos_old - pos;
            data = data - p;
    end
    end
    
    %---------function to pickup to pointed curve
    function [col,lstyle]=line_pickup(list_line_obj,pos)
    
    col=0;
    lstyle='-';
    
    %-define searching windows
    xl=get(onaxis,'XLim');
    xwin=abs(xl(1)-xl(2))/1000;
    yl=get(onaxis,'YLim');
    ywin = abs(yl(1)-yl(2))/100;
    
    %-load all datasets
    for i=1:length(list_line_obj)
        xData{i}=get(list_line_obj(i), 'XData');
        yData{i}=get(list_line_obj(i), 'YData');
        xbadind = zeros(size(xData{i}));
        ybadind = zeros(size(yData{i}));
        switch get(onaxis, 'xscale')
            case 'linear'
                xp = pos(1,1);
            case 'log'
                xp = log10(pos(1,1)); 
                    xData{i} = log10(xData{i});
                    xData{i}(isnan(xData{i})) = [];
                    xbadind = isnan(xData{i});
        end
        switch get(onaxis, 'yscale')
            case 'linear'
                yp = pos(1,2);
            case 'log'
                yp = log10(pos(1,2));
                    yData{i} = log10(yData{i});
                    ybadind = isnan(yData{i});
        end
        badind = (xbadind | ybadind);
        xData{i}(badind) = [];
        yData{i}(badind) = [];
    end
    
%     %--look for matches in x and y direction
    min_distance = 1E10;
    candidate = [];
    for i=1:length(list_line_obj)
        %candidate{i}=find((abs(pos(1,2)-yData{i})<ywin) & (abs(pos(1,1)-xData{i})<xwin));
        t = min(abs(yp-yData{i}).^2 + abs(xp-xData{i}).^2);
        if t<min_distance
            min_distance = t;
            candidate = i;
        end
    end
    
    %---find the right guy
    col = candidate;
    lstyle=get(list_line_obj(col),'LineStyle');
    if lstyle==':'
        set(list_line_obj(col),'LineStyle','-');
    else
        set(list_line_obj(col),'LineStyle',':');
    end
    end
end
    