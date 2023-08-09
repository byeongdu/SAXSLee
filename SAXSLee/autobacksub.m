function [fn, fn_input] = autobacksub(varargin)
% autobacksub Called by SAXSLee to plot scans.
%
% Copyright 2004, Byeongdu Lee
% background subtraction option
% 0 (default) just subtract after correcting transmittance
% 1 based on WAXS (using WAXS data to normalize SAXS)
%   in this case, one needs to provide q range to integrate.
% SAXSLee_setting.backsuboption
% SAXSLee_setting.bascksubIntQrange
backoption = [];
f_user = [];
if numel(varargin) < 2
    hFigSAXSLee = evalin('base', 'SAXSLee_Handle');
    hAxes = findobj(hFigSAXSLee,'Tag','SAXSLee_Axes');
else
    hFigSAXSLee = varargin{1};
    hAxes = varargin{2};
    
    if numel(varargin) == 3
        f_user = varargin{3};
        backoption = 0;
    end
end

%hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
%hAxes = findall(hFigSAXSLee,'Tag','SAXSLee_Axes');
backscan = getappdata(hFigSAXSLee,'backscan');
hPopupmenuI0 = findobj(hFigSAXSLee,'Tag','SAXSLee_PopupmenuI0');
popupmenuI0Value = get(hPopupmenuI0,'string');
if isempty(backscan)
    disp('No back file is selected')
    return
end


SAXSbackFile = backscan.Tag;
WAXSbackFile = [];
SAXSbackFile(SAXSbackFile == ' ') = '_';
t = find(SAXSbackFile == ':');
SAXSbackFile(1:t+1) = [];
if isfield(backscan, 'WTag')
    WAXSbackFile = backscan.WTag;
    WAXSbackFile(WAXSbackFile == ' ') = '_';
    t = find(WAXSbackFile == ':');
    WAXSbackFile(1:t+1) = [];
end    

if nargout == 0 
    % when this is called by SAXSLee
    hObject = findall(0, 'Tag', 'toolbarAutobacksub');
    if ~strcmp(get(hObject, 'State'), 'on')
        hLine = findobj(hAxes,'Type','line');
        for mm = 1:numel(hLine)
             if SAXSLee_isbacksub(hLine(mm))
                 delete(hLine(mm));
             end
        end
        curvelegend(hFigSAXSLee)
        return
    end
else
    % when this is called by SAXSLee_BackSub.m
end

SAXSLee_setting = getappdata(hFigSAXSLee,'SAXSLee_setting');
settings = getappdata(hFigSAXSLee,'settings');
%Nsel = get(findobj(hFigSAXSLee, 'tag', 'SAXSLee_PopupmenuX'), 'value');
%setall = evalin('base', 'setall');
%file = setall{Nsel}.file;
%scan = setall{Nsel}.scan;




if isempty(backoption)
    if isfield(SAXSLee_setting, 'backdivideoption')
        backoption = SAXSLee_setting.backdivideoption;
    else
        backoption = 0;
    end
end

lineObj = findobj(hAxes, 'type', 'line', '-xor','-regexp', 'tag', 'BACK:');
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

if isempty(f_user)
    trans = str2double(popupmenuI0Value);
else
    trans = f_user;
end

if isfield(settings, 'atBeamline')
    Beamline = settings.atBeamline;
else
    Beamline = 'Unknown';
end

bx = backscan.colData(:,1);
by = backscan.colData(:,2);
bz = backscan.colData(:,3);
try
    Wbx = backscan.colWData(:,1);
    Wby = backscan.colWData(:,2);
    Wbz = backscan.colWData(:,3);
catch
    Wbx = [];
end



isNormbySAXS = -1;
if backoption ~= 0
    if isfield(SAXSLee_setting.backdivideIntQrange, 'SAXS')
        if ~isempty(SAXSLee_setting.backdivideIntQrange.SAXS)
            if sum(isnan(SAXSLee_setting.backdivideIntQrange.SAXS))==0
                isNormbySAXS = 1;
            else
                isNormbySAXS = 0;
            end
        end
    end
end
if isNormbySAXS==1
    normd = backscan.colData;
    backsubIntQrange = SAXSLee_setting.backdivideIntQrange.SAXS;
elseif isNormbySAXS == 0
    normd = backscan.colWData;
    backsubIntQrange = SAXSLee_setting.backdivideIntQrange.WAXS;
    isNormbySAXS = 0;
end
%     if max(backsubIntQrange) > max(bx);
%         % Norm data is WAXS
%         normd = backscan.colWData;
%     else
%         normd = backscan.colData;
%     end
    
    if backoption ~= 0
        backNom = integrateq(normd(:,1), normd(:,2), backsubIntQrange);
    else
        backNom = 1;
    end
   
%    backNom = integrateq(bx, by, backsubIntQrange);
% else
%     backNom = 1;
% end

fn = cell(numel(SAXSdata), 2);
fn_input = cell(numel(SAXSdata), 2);

for i = 1:numel(SAXSdata)
    [dt, datatg] = pickdata(SAXSdata(i));
    Sxd = dt(:,1);
    Syd = dt(:,2);
    Szd = dt(:,3);
    tg = [datatg, '_bsub'];
    try
        fpath = getappdata(lineObj(i), 'path');
    catch
        fpath ='';
    end
    if isSW(i)
        [Wdt, dataWtg] = pickdata(WAXSdata(i));
        Wxd = Wdt(:,1);
        Wyd = Wdt(:,2);
        Wzd = Wdt(:,3);
        Wtg = [dataWtg, '_bsub'];
    end
%     if max(backsubIntQrange) > max(dt(:,1));
%         % Norm data is WAXS
%         normd = Wdt;
%     else
%         normd = dt;
%     end
    if isNormbySAXS
        normd = [Sxd, Syd];
    else
        normd = [Wxd, Wyd];
    end
    if backoption ~= 0
        dataNom = integrateq(normd(:,1), normd(:,2), backsubIntQrange);
    else
        dataNom = 1;
    end

    backfactor = trans/backNom*dataNom;
    [nn, nd] = backsub(Sxd, Syd, Szd, backfactor, tg, bx, by, bz);
    SAXSLee_copyPlotoption(SAXSdata(i), nn);
    dataType = 'SAXS';
    ud = get(SAXSdata(i), 'userdata');
    
    
    if isempty(ud) % ref data
        if ~isempty(fpath)
            settings.backsubtractedDir = '';
            settings.path = fpath;
        end
        fn{i, 1} = SAXSLee_saveresult(settings, Beamline, dataType, nd, tg);    
    else
        ud.SAXS_background_Filename = SAXSbackFile;
        fn{i, 1} = SAXSLee_saveresult(settings, Beamline, dataType, nd, tg, ud);    
    end
    if ~isempty(ud)
        [pth, backsubdir] = SAXSLee_getfolders(settings, ud.path, dataType);
    else
        pth = fpath;
        backsubdir = '';
    end
    datatg(datatg == ' ') = '_';
    t = find(datatg == ':');
    datatg(1:t+1) = [];
    fn_input{i, 1} = fullfile(pth, backsubdir, datatg);    
    
    
    if isSW(i)
        if ~isempty(Wbx)
            [wnn, nd] = backsub(Wxd, Wyd, Wzd, backfactor, Wtg, Wbx, Wby, Wbz);
            SAXSLee_copyPlotoption(WAXSdata(i), wnn);
            setappdata(wnn, 'SAXShandle', nn)
            setappdata(nn, 'WAXShandle', wnn)
            dataType = 'WAXS';
            ud = get(WAXSdata(i), 'userdata');
            if isempty(ud)
                fn{i, 2} = SAXSLee_saveresult(settings, Beamline, dataType, nd, Wtg);
            else
                ud.WAXS_background_Filename = WAXSbackFile;
                fn{i, 2} = SAXSLee_saveresult(settings, Beamline, dataType, nd, Wtg, ud);
            end
            if ~isempty(backsubdir)
                if ~isempty(ud)
                    [pth, backsubdir] = SAXSLee_getfolders(settings, ud.path, dataType);
                end
            end
            dataWtg(dataWtg == ' ') = '_';
            t = find(dataWtg == ':');
            dataWtg(1:t+1) = [];
            fn_input{i, 2} = fullfile(pth, backsubdir, dataWtg);    
        end
    end
end


    function rt = SAXSLee_isbacksub(h)
        rt = getappdata(h, 'isbacksubtracted');
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

    function [hdl, nd] = backsub(xd, yd, zd, trans, tg, bx, by, bz)
            xd = xd(:);
            yd = yd(:);
            zd = zd(:);
            isIntpNeeded = 0;
            if numel(xd) ~= numel(bx)
                isIntpNeeded = 1;
            else
                if any(xd~=bx)
                    isIntpNeeded = 1;
                end
            end
            
            if ~isIntpNeeded
                yd = yd - trans*by;
                zd = sqrt(zd.^2 + bz.^2);
            else
                by2 = interp1(bx, by, xd);
                bz2 = interp1(bx, bz, xd);
                yd = yd - trans*by2;
                zd = sqrt(zd.^2 + bz2.^2);
            end
            

            hdl = line('Parent',hAxes,...
                'XData',xd,...
                'YData',yd,...
                'Tag',tg);
            setappdata(hdl, 'yDataError', zd);
            nd = [xd, yd, zd];
            setappdata(hdl, 'isbacksubtracted', 1);
    end

end
