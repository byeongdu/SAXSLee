function SAXSLee_transmittance_callback(varargin)
hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
t = guihandles(hFigSAXSLee); % slowest.... Need to improve...
hPopupmenuI0 = t.SAXSLee_PopupmenuI0;
hAxes = t.SAXSLee_Axes;
backTB = t.toolbarRefScan;
FFTB = t.toolbarshowFF;


popupmenuI0Value = str2double(get(hPopupmenuI0,'string'));
backscan = getappdata(hFigSAXSLee,'backscan');
FFscan = getappdata(hFigSAXSLee,'FFscan');
if ~strcmp(get(backTB, 'State'), 'on');
    onBack = 0;
else
    onBack = 1;
end
if ~strcmp(get(FFTB, 'State'), 'on');
    onFF = 0;
else
    onFF = 1;
end


if (~isempty(backscan) & onBack)
    rescaleRefdataplot(hAxes, backscan, popupmenuI0Value, 'BACK: ');
else
    %disp('Define background before applying the transmittance.')
end
if (~isempty(FFscan) & onFF)
    rescaleRefdataplot(hAxes, FFscan, popupmenuI0Value, 'FF: ');
else
    %disp('Define Form Factor before applying the transmittance.')
end


function rescaleRefdataplot(hAxes, back, scale, reftype)
if nargin < 4
    reftype = 'BACK: ';
end

tm = findobj(hAxes, 'type', 'line', '-regexp', 'tag', reftype);

% t = strfind(get(tm, 'Tag'), reftype);
% isback = ~cellfun('isempty', t);
% if sum(isback)
%     tm = tm(isback);
% else
%     [~, tg, ext] = fileparts(back.Tag);
%     tg = [tg, ext];
%     tm(1) = plotRefdata(hAxes, back.colData, reftype, tg);
%     [~, tg, ext] = fileparts(back.WTag);
%     tg = [tg, ext];
%     tm(2) = plotRefdata(hAxes, back.colWData, reftype, tg);
% end

for is = 1:numel(tm);
    yd = get(tm(is), 'ydata');
    xd = get(tm(is), 'xdata');
    isSAXS = getappdata(tm(is), 'isSAXS');
    if isempty(isSAXS)
        isSAXS = 1;
    end
    if isSAXS
    %if strfind(get(tm(is), 'Tag'), [reftype, 'S'])
        yd = back.colData(:,2)*scale;
    %elseif strfind(get(tm(is), 'Tag'), [reftype, 'W'])
    else
        if numel(back.colWData(:,2)) == numel(xd);
            yd = back.colWData(:,2);
        elseif numel(back.colData(:,2)) == numel(xd)
            yd = back.colData(:,2);
        end
        yd = yd*scale;
%         try
%             yd = back.colWData(:,2)*scale;
%         catch
%             % This may indicate that data is not SAXS/WAXS and not labeled.
%             yd = back.colData(:,2)*scale;
%         end
    end
    set(tm(is), 'ydata', yd);
end
