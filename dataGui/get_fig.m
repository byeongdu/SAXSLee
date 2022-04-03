function data = get_fig(handles)
xfig = get(findobj(handles, 'type', 'line'), 'xdata');
yfig = get(findobj(handles, 'type', 'line'), 'ydata');
xfig = vect2row(xfig)';
yfig = vect2row(yfig)';
data = [xfig, yfig];