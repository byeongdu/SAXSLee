function plot_data(a, fig)
% plotting data loaded using load_data.m
% plot_data
if nargin < 2
    figure;
    hAxes = gca;
    leg = {};
    k = 0;
else
    figure(fig);
    hAxes = findobj(gcf, 'type', 'axes');
    leg = findobj(gcf, 'tag', 'legend');
    leg = get(leg, 'string');
    k = numel(leg);
end

cc = {'b', 'g', 'r', 'c', 'm', 'y', 'k'};
mc = {'.', 'o', 'x', '+', '*', 's', 'd', 'v', '^', '<', '>', 'p', 'h'};

na = numel(a);
if na < 50

    [x, y] = meshgrid(1:numel(cc), 1:numel(mc));
    x = x';y = y';
%    warning off last
    if isfield(a, 'data');
        for i=1:numel(a)
            mk = strcat(cc{x(i)}, mc{y(i)}, '-');
            %loglog(a(i).data(:,1), a(i).data(:,2), mk);
            hLine(i) = line('Parent',hAxes,...
                'XData',a(i).data(:,1),...
                'YData',a(i).data(:,2));% 'Tag',scan.selection{iSelection}.Tag);
            plotoption(hLine(i), i);
            tt = findstr(a(i).name, '_');
            lg = a(i).name;lg(tt) = ' ';
            leg{i+k} = lg;
        end
        legend(leg);
    end
else
%    tmp = 1;
    %cl = linspace(0, 1, fix(na/6)+1);cl = cl';
    %cl0 = zeros(size(cl));cl1 = ones(size(cl));
    %cc = [cl, cl0, cl0; cl1, cl0, cl;...
    %    flipud(cl), cl0, cl1;cl0,cl, cl1;...
    %    cl0,cl1,flipud(cl);cl,cl1,cl0];
    cc = jet(na);
    tic
    for i=1:na
%        warning off last
%        cn = floor(i/10) + 1;
%        cn = mod(cn, 7) + 1;
%        mk = strcat(cc{cn}, '-');
%        loglog(a(i).data(:,1), a(i).data(:,2), mk);hold on
        hLine(i) = line('Parent',hAxes,...
            'XData',a(i).data(:,1),...
            'ZData',a(i).data(:,2),...
            'YData',ones(size(a(i).data(:,2)))*i);% 'Tag',scan.selection{iSelection}.Tag);
        set(hLine(i), 'color', cc(i,:));
        tt = findstr(a(i).name, '_');
        lg = a(i).name;lg(tt) = ' ';
        set(hLine, 'Tag', lg);
        leg{i+k} = lg;
    end
    toc
    %legend(leg);   
    view([24,40])
    set(gca, 'xscale', 'log', 'zscale', 'log')
end    