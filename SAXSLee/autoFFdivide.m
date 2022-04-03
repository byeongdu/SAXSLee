function autoFFdivide(varargin)
% autoFFdivide Called by SAXSLee to plot scans.
%
% Copyright 2004, Byeongdu Lee
% background subtraction option
% 0 (default) just subtract after correcting transmittance
% 1 based on WAXS (using WAXS data to normalize SAXS)
%   in this case, one needs to provide q range to integrate.
% settings.backsuboption
% settings.bascksubIntQrange


hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
hAxes = findobj(hFigSAXSLee,'Tag','SAXSLee_Axes');
FFscan = getappdata(hFigSAXSLee,'FFscan');
hPopupmenuI0 = findobj(hFigSAXSLee,'Tag','SAXSLee_PopupmenuI0');
popupmenuI0Value = get(hPopupmenuI0,'string');
if isempty(FFscan)
    disp('No FF file is selected')
    return
end

hObject = findobj(0, 'Tag', 'toolbarAutoFFdivide');
if ~strcmp(get(hObject, 'State'), 'on');
    hLine = findobj(hAxes,'Type','line');
    for mm = 1:numel(hLine)
         if SAXSLee_isFFdivided(hLine(mm))
             delete(hLine(mm));
         end
    end
    curvelegend(hFigSAXSLee)
    return
end

settings = getappdata(hFigSAXSLee,'settings');

if isfield(settings, 'FFdivideoption');
    FFoption = settings.FFdivideoption;
else
    FFoption = 0;
end
if isfield(settings, 'FFdivideIntQrange');
    backsubIntQrange = settings.FFdivideIntQrange;
else
    backsubIntQrange = [];
end

lineObj = findobj(hAxes, 'type', 'line');
NoldL = numel(lineObj);
isSW = [];
SAXSdata = [];
WAXSdata = [];
for i=1:NoldL
    t = getappdata(lineObj(i), 'isSAXS');
    if t == 1
        SAXSdata = [SAXSdata, lineObj(i)];
        isSW = [isSW, getappdata(lineObj(i), 'isSAXSWAXS')];
        if getappdata(lineObj(i), 'isSAXSWAXS')
            wd = getappdata(lineObj(i), 'WAXShandle');
        else
            wd = NaN;
        end
        WAXSdata = [WAXSdata, wd];
    end
end

factor = str2double(popupmenuI0Value);


if isfield(settings, 'atBeamline')
    if strcmp(settings.atBeamline, '12IDB')
        Beamline = '12IDB';
    end
    if strcmp(settings.atBeamline, 'PLS9A')
        Beamline = 'PLS9A';
    end
else
    Beamline = 'Unknown';
end


bx = FFscan.colData(:,1);
by = FFscan.colData(:,2);
bz = FFscan.colData(:,3);
try
    Wbx = FFscan.colWData(:,1);
    Wby = FFscan.colWData(:,2);
    Wbz = FFscan.colWData(:,3);
catch
    Wbx = [];
end

if FFoption ~= 0;
    FFNom = integrateq(bx, by, backsubIntQrange);
else
    FFNom = 1;
end


for i = 1:numel(SAXSdata);
    [dt, tg] = pickdata(SAXSdata(i));
    xd = dt(:,1);
    yd = dt(:,2);
    zd = dt(:,3);
    if FFoption ~= 0;
        FFWxNom = integrateq(dt(:,1), dt(:,2), backsubIntQrange);
    else
        FFWxNom = 1;
    end

    tg = [tg, '_div'];
    [nn, nd] = FFdivide(xd, yd, zd, factor/FFWxNom*FFNom, tg, bx, by, bz);
    SAXSLee_copyPlotoption(SAXSdata(i), nn);
    dataType = 'SAXS';
    ud = get(SAXSdata(i), 'userdata');
    SAXSLee_saveresult(settings, Beamline, dataType, nd, tg, ud)
    if isSW(i)
        [dt, tg] = pickdata(WAXSdata(i));
        xd = dt(:,1);
        yd = dt(:,2);
        zd = dt(:,3);
        tg = [tg, '_div'];
        if ~isempty(Wbx)
            [wnn, nd] = FFdivide(xd, yd, zd, factor/FFWxNom*FFNom, tg, Wbx, Wby, Wbz);
            SAXSLee_copyPlotoption(WAXSdata(i), wnn);
            setappdata(wnn, 'SAXShandle', nn)
            setappdata(nn, 'WAXShandle', wnn)
            dataType = 'WAXS';
            ud = get(WAXSdata(i), 'userdata');
            SAXSLee_saveresult(settings, Beamline, dataType, nd, tg, ud)
        end
    end
end

    function rt = SAXSLee_isFFdivided(h)
        rt = getappdata(h, 'isFFdivided');
        if isempty(rt)
            rt = 0;
        end
    end
    
    function [colData, Tag] = pickdata(handle)
        xd = get(handle, 'Xdata');xd = xd(:);
        yd = get(handle, 'Ydata');yd = yd(:);
        try
        sig = getappdata(handle, 'yDataError');
        catch
            sig = [];
        end
        colData = [xd, yd, sig];
        Tag = get(handle, 'Tag');    
    end
%end
    function [hdl, nd] = FFdivide(xd, yd, zd, scale, tg, bx, by, bz)

            xd = xd(:);
            yd = yd(:);
            zd = zd(:);
            try
                qdiff = abs(bx(:) - xd);
            catch
                qdiff = 1;
            end
            
            if (~qdiff) | (numel(bx) ~= numel(xd))
                by2 = interp1(bx, by, xd);
                bz2 = interp1(bx, bz, xd);
                by = by2;
                bz = bz2;
            end
            by = scale*by;
            bz = scale*bz; % error propagation for scalor multiplication
            
            % dividing FF out
            yd = yd./by;
            % error propagation for FF division out.
            zd = yd.*sqrt((zd./yd).^2 + (bz./by).^2);

            hdl = line('Parent',hAxes,...
                'XData',xd,...
                'YData',yd,...
                'Tag',tg);
            setappdata(hdl, 'yDataError', zd);
            nd = [xd, yd, zd];
            setappdata(hdl, 'isFFdivided', 1);
    end


end
