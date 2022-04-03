function [NoldL, hdl] = numDatasetonGraph(varargin)
% [NoldL, hdl] = numDatasetonGraph(varargin)
% Counts number of primary data (or set of SAXS/WAXS) on SAXSLee or any
% other figure.
% hdl is the return of the handles of the primary(SAXS) data.

if numel(varargin) == 1
    hAxes = varargin{1};
else
    %hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
    hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
    hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
end
NoldL=0;
lo = findobj(hAxes, 'type', 'line');
hdl = [];
for i=1:numel(lo)
    if getappdata(lo(i), 'isSAXS')
        NoldL = NoldL+1;
        hdl(NoldL) = lo(i);
    end
end
