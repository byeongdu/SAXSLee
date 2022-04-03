function SAXSLee_dataControlmenu(obj)

    hp = get(get(obj, 'parent'), 'parent');
    %hp = get(obj, 'parent');
    hcmenu = uicontextmenu('parent', hp);
    uimenu(hcmenu,'Label','Set as Blank Cell','Callback',@uimenu_setback);
    uimenu(hcmenu,'Label','Set as Form Factor','Callback',@uimenu_setFF);
    uimenu(hcmenu,'Label','Trim data','Callback',@uimenu_trimdata);
    uimenu(hcmenu,'Label','Power law slope','Callback',@uimenu_powerslope);
    uimenu(hcmenu,'Label','Remove','Callback',@uimenu_remove);
    uimenu(hcmenu,'Label','Sq to Gr','Callback',@uimenu_calculateGr);
%     uimenu(hcmenu,'Label','q_{t,z} cut(V)','Callback',{@uimenu_linecut, 'v1'});
%     uimenu(hcmenu,'Label','q_{r,z} cut(V)','Callback',{@uimenu_linecut, 'v2'});
%     uimenu(hcmenu,'Label','q_{2\theta_f} cut(V)','Callback',{@uimenu_linecut, 'tth'});
%     uimenu(hcmenu,'Label','q_{\alpha_f} cut(V)','Callback',{@uimenu_linecut, 'af'});
%     uimenu(hcmenu,'Label','Clean lines','Callback',@uimenu_cleanlines);
%     uimenu(hcmenu,'Label','Set current image as background','Callback',@uimenu_setbackground);
%     uimenu(hcmenu,'Label','Set current image as mask','Callback',@uimenu_setmask);
%     uimenu(hcmenu,'Label','Toggle Off','Callback',@gtrack_Off);
    % Locate line objects
    %himage = findall(gcf,'Type','axes');
    set(obj,'uicontextmenu',hcmenu)
    function uimenu_calculateGr(varargin)
        [hdl, indx, ~,~, data] = SAXSLee_findcursor;
        if hdl ~= gco
            cprintf('err', 'The red dots should be on the current data\n');
            return
        end
        indx = sort(indx);
        data = data(indx(1):indx(2), :);
        %delete(dothdl)
        r = linspace(2*pi/data(end, 1), 2*pi/data(1,1), 500);
        gr = sq2Gr(data(:,1), data(:,2)/mean(data(end-50:end, 2)), r);
        figure;
        plot(r, gr)
    function uimenu_trimdata(varargin)
        [hdl, indx, ~,~, data, ~, ~, dothdl] = SAXSLee_findcursor;
        if hdl ~= gco
            cprintf('err', 'The red dots should be on the current data\n');
            return
        end
        indx = sort(indx);
        data = data(indx(1):indx(2), :);
        delete(dothdl)
        set(hdl, 'xdata', data(:,1));
        set(hdl, 'ydata', data(:,2));
        if size(data, 2) > 2
            setappdata(hdl, 'yDataError', data(:,3));
        end
    function uimenu_remove(varargin)
        isSW = getappdata(gco, 'isSAXSWAXS');
        h = [];
        if isSW
            h = getappdata(gco, 'WAXShandle');
            if isempty(h)
                h = getappdata(gco, 'SAXShandle');
            end
        end
        delete([gco, h]);
        
    function uimenu_setback(varargin)
        %hFigSAXSLee = findall(0,'Tag','SAXSLee_Fig');
        hFigSAXSLee = gcbf;
        isSW = getappdata(gco, 'isSAXSWAXS');
        [Dt, T] = pickdata(gco);
        back.colData = Dt;
        back.Tag = T;
        ud = get(gco, 'userdata');
        if ~isempty(ud)
            fh = findobj('tag', 'SAXSLee_BackSub');
            if ~isempty(fh)
                h_ed_IC =findobj(fh, 'tag', 'ed_IC_cell_div_Time');
                h_ed_BS =findobj(fh, 'tag', 'ed_BS_cell_div_Time');
                set(h_ed_IC, 'string', sprintf('%0.5f', ud.ic/ud.exposuretime));
                set(h_ed_BS, 'string', sprintf('%0.5f', ud.phd/ud.exposuretime));
            end
        end
%        isSW = getappdata(gco, 'isSAXSWAXS');
        if isSW
            h = getappdata(gco, 'WAXShandle');
            if isempty(h)
                h = getappdata(gco, 'SAXShandle');
                back.colWData = Dt;
                back.Tag = T;
                [Dt, T] = pickdata(h);
                back.colData = Dt;
                back.Tag = T;
            else
                [Dt, T] = pickdata(h);
                back.colWData = Dt;
                back.WTag = T;
            end
        end
        setappdata(hFigSAXSLee,'backscan', back);
        
    function uimenu_setFF(varargin)
        hFigSAXSLee = findobj('Tag','SAXSLee_Fig');
        isSW = getappdata(gco, 'isSAXSWAXS');
        [Dt, T] = pickdata(gco);
        back.colData = Dt;
        back.Tag = T;
%        isSW = getappdata(gco, 'isSAXSWAXS');
        if isSW
            h = getappdata(gco, 'WAXShandle');
            if isempty(h)
                h = getappdata(gco, 'SAXShandle');
                back.colWData = Dt;
                back.Tag = T;
                [Dt, T] = pickdata(h);
                back.colData = Dt;
                back.Tag = T;
            else
                [Dt, T] = pickdata(h);
                back.colWData = Dt;
                back.WTag = T;
            end
        end
        setappdata(hFigSAXSLee,'FFscan', back);
        
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
