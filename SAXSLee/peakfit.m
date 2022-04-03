function [cv, yl] = peakfit(arg_peakarea, arg_peakposition, arg_peakwidth, y, x, varargin)
% [cv, yl] = peakfit(arg_peakarea, arg_peakposition, arg_peakwidth, y, x, varargin)
% peakfit(arg_peakarea, arg_peakposition, arg_peakwidth, y, x)
% peakfit(arg_peakarea, arg_peakposition, arg_peakwidth, y, x, 'back',
% backdata)
% peakfit(arg_peakarea, arg_peakposition, arg_peakwidth, y, x, 'err',
% errdata)
%
% wavelength = 1
x = x(:);
y = y(:);
g = arg_peakwidth(1);
dsize = arg_peakwidth(2);
mstrain = arg_peakwidth(3);
w = peakwidth(arg_peakarea, 1, dsize, mstrain);
pw = [g*ones(length(w), 1), w(:)];
yl = zeros(size(x));
for i=1:numel(arg_peakarea)
    yline = pseudovoigt(x, [arg_peakarea(i), arg_peakposition(i), g, pw(i, 2), 0]);
    yl = yl + yline(:);
end

back = zeros(size(x));
err = y;
err(err == 0) = min(err > 0);

if numel(varargin) > 0
    for i=1:2:numel(varargin)
        if contains(varargin{i}, 'back')
            back = varargin{i+1}(:);
        end
        if contains(varargin{i}, 'err')
            err = varargin{i+1}(:);
        end
    end
end
% x should be an array of x values
% y should be an array of y values
    
yl = yl + back; % background added.
cv = sum((y - yl).^2./abs(err));
cv = 1/numel(p)*cv;
