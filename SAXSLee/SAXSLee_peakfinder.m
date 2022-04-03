function SAXSLee_peakfinder(varargin)
% For simple object such as spherical, cylinderical or lamella stures,
% it may be possible to obtain excess electron density profile along
% radial, cross sectional and normal to the plane directions, respectively.
% This program is to convert I(q) to A(q) and finally to get rho(r),
% where users may arbitrary decide phase of amplitudes.
% Look at also Lipid.m

warning off
verNumber = '1.0';
init(varargin)
hSL = gcbf;
if isempty(hSL)
    hSL = gcf;
end
hSLaxes = findobj(hSL, 'type', 'axes');

function init(varargin)
f = figure;
%set(f, 'MenuBar', 'none');
%tbh = uitoolbar(f);
%set(f, 'uitoggletool', 'on');
set(f, 'Tag', 'SAXSLee_peakfinder')
set(f, 'Name', 'Pick Peaks');

hMenubar = findall(gcf,'tag','figMenuFile');
set(findall(hMenubar), 'visible', 'off')
hMenubar = findall(gcf,'tag','figMenuView');
set(findall(hMenubar), 'visible', 'off')
hMenubar = findall(gcf,'tag','figMenuEdit');
set(findall(hMenubar), 'visible', 'off')
hMenubar = findall(gcf,'tag','figMenuHelp');
set(findall(hMenubar), 'visible', 'off')
hMenubar = findall(gcf,'tag','figMenuInsert');
set(findall(hMenubar), 'visible', 'off')
hMenubar = findall(gcf,'tag','figMenuTools');
set(findall(hMenubar), 'visible', 'off')
hMenubar = findall(gcf,'tag','figMenuDesktop');
set(findall(hMenubar), 'visible', 'off')
%get(findall(hMenubar),'tag')
%hToolbar = findall(gcf,'tag','FigureToolBar');
%set(hToolbar, 'visible', 'off');
%% Menu
hMenuFile = uimenu(f,...
    'Label','&File',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFile');
hMenuFileOpen = uimenu(hMenuFile,...
    'Label','&Load Data from SAXSLee...',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileOpen',...
    'Accelerator','L',...
    'callback',@loaddata);
hMenuFileOpen2 = uimenu(hMenuFile,...
    'Label','&Load Data from indexing...',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileOpen',...
    'Accelerator','L',...
    'callback',{@loaddatafromindexing, varargin{1}});
hMenuFileSave = uimenu(hMenuFile,...
    'Label','&Save Result...',...
    'Position',3,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileSave',...
    'Accelerator','S',...
    'callback',@saveResults);
hMenuFileSave = uimenu(hMenuFile,...
    'Label','&Save d-spacings for autoindexing...',...
    'Position',3,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileSave',...
    'callback',@savedspacings);
hMenuFileSaveInflip = uimenu(hMenuFile,...
    'Label','&Save as Inflip...',...
    'Position',4,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileSaveInflip',...
    'Accelerator','I',...
    'callback',@saveinflip);
hMenuProc = uimenu(f,...
    'Label','&Process',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuProc');
hMenuSetFindPeaks = uimenu(hMenuProc,...
    'Label','&Locate Peaks...',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuSetPeaks');
hMenuSetFindPeaks1 = uimenu(hMenuSetFindPeaks,...
    'Label','&Load HKLs...',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_Menuloadhkls',...
    'callback',@loadhkls);
hMenuSetFindPeaks2 = uimenu(hMenuSetFindPeaks,...
    'Label','&Locate peaks manually...',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuSetfindPeaks2',...
    'callback',@setfindpeaks);
hMenuSetFindPeaks2 = uimenu(hMenuSetFindPeaks,...
    'Label','&Locate peaks automatically...',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuSetfindPeaks2',...
    'callback',@setfindpeaksauto);
hMenuFindMinima = uimenu(hMenuProc,...
    'Label','&Show Selected Peaks...',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFindMinima',...
    'callback',@generatebackground);
hMenuPeakShape = uimenu(hMenuProc,...
    'Label','&Peak Shapes...',...
    'Position',3,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuLC1');
hMenuPeakShape1 = uimenu(hMenuPeakShape,...
    'Label','&Draw Gaussian Peaks...',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuLC1',...
    'callback',@drawGaussianPeaks);
hMenuPeakShape2 = uimenu(hMenuPeakShape,...
    'Label','&Draw Pseudo-voigt Peaks...',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuCalAq',...
    'callback',@drawVoigtPeaks);
hMenuCalAq = uimenu(hMenuProc,...
    'Label','&Fit Peaks...',...
    'Position',5,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuCalAq',...
    'callback',@fitPeaks);
hMenuCalAq = uimenu(hMenuProc,...
    'Label','&Stop Fit Peaks...',...
    'Position',6,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuCalAq',...
    'callback',@stopfitPeaks);
hMenuClearall = uimenu(hMenuProc,...
    'Label','&Clear All...',...
    'Position',7,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuCalAq',...
    'callback',@clearall);

%% Graph
hA1 = subplot(2, 1, 1);
hA2 = subplot(2, 1, 2);

set(hA1, 'box', 'on', 'tag', 'IqAxes');
set(hA2, 'box', 'on', 'tag', 'PeakAxes');
end
%% functions
function loaddata(varargin)
    SAXSLee_Handle = evalin('base', 'SAXSLee_Handle');
    hL = findobj(SAXSLee_Handle, 'type', 'line', '-xor', '-regexp', 'tag', 'BACK');
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    delete(findobj(hA1, 'tag', 'rawdata'));
    xd = get(hL, 'xdata');
    yd = get(hL, 'ydata');
    hNL = line(hA1, xd, yd, 'tag', 'rawdata');
    set(hA1, 'xscale', 'linear');
    set(hA1, 'yscale', 'log');
    xlabel(hA1, sprintf('q (1/%c)', char(197)), 'fontsize', 14);
    ylabel(hA1, sprintf('I(q) (a.u.)'), 'fontsize', 14);
end

function loaddatafromindexing(varargin)
    try
        if numel(varargin)>2
            figh = varargin{3}{1};
        else
            figh = [];
        end
    catch
        figh = [];
    end
    if isempty(figh)
        figh = findall(0, 'tag', 'Indexing_Plot');
    end
    ax = findobj(figh, 'type', 'axes');
    hL = findobj(ax, ...
        'type', 'line', ...
        'tag', 'indexingdata');

    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    delete(findobj(hA1, 'tag', 'rawdata'));
    xd = get(hL, 'xdata');
    yd = get(hL, 'ydata');
    hNL = line(hA1, xd, yd, 'tag', 'rawdata');
    set(hA1, 'xscale', 'linear');
    set(hA1, 'yscale', 'log');
    xlabel(hA1, sprintf('q (1/%c)', char(197)), 'fontsize', 14);
    ylabel(hA1, sprintf('I(q) (a.u.)'), 'fontsize', 14);
end

function saveResults(varargin)
    [~, m, data_lab] = combineFitResults(varargin);
    %data_lab = data_lab(data_lab_sel);    
    [filename, pathname] = uiputfile(...
        {'*.txt';'*.dat'},...
        'Save as');
    if isequal(filename,0) || isequal(pathname,0)
        disp('User selected Cancel')
        return
    else
        disp(['User selected ',filename])
    end
    fn = fullfile(pathname, filename);
    str = '%';
    for i=1:numel(data_lab)
        str = sprintf('%s %s', str, data_lab{i});
    end
    fid = fopen(fn, 'w');
    fwrite(fid, str);
    fprintf(fid, '\n');
    fclose(fid);
    dlmwrite(fn, m, '-append');
end


function savedspacings(varargin)
    [~, m, data_lab] = combineFitResults(varargin);
    %data_lab = data_lab(data_lab_sel);    
    [filename, pathname] = uiputfile(...
        {'*.txt';'*.dat'},...
        'Save as');
    if isequal(filename,0) || isequal(pathname,0)
        disp('User selected Cancel')
        return
    else
        disp(['User selected ',filename])
    end
    fn = fullfile(pathname, filename);
    maxd = m(1, 1);
    f = 1/maxd*5;
    maxd = maxd*f;
    m(:,1) = m(:,1)*f;
    if size(m, 2) == 7
        sig1 = m(:,4)./m(:,3);
        sig2 = m(:,5)./m(:,3);
        sig = max([sig1(:), sig2(:)], [], 2);
    else
        sig = m(:,4)./m(:,3);
    end
    Npeak = length(m(:,1));
    fid = fopen(fn, 'w');
    fprintf(fid, '**** %s with factor %0.3e ****\n', filename, f);
    fprintf(fid, '%i  %s\n', Npeak, '3 1 1 1 1 0 0');
    fprintf(fid, '%0.3f %0.3f %0.3f 0.0 %0.3f 0 0\n', maxd*3, maxd*3, maxd*3, 5*maxd^3);
    fprintf(fid, '%s\n', '0 0 0 0');
    fprintf(fid, '%s\n', '1.0 0 0 0 0');
    for i=1:Npeak
        fprintf(fid, '%0.3f %0.3f\n', m(i, 1), sig(i)*m(i, 1));
    end
    fclose(fid);
end


function saveinflip(varargin)
    mode = getappdata(gcf, 'FitMode');
    if mode ~= 'hkls'
        error('To save as inflip file, use indexing.m and load as hkls first.')
    end
    p = combineFitResults(varargin);
    peak = [p(:,2), p(:,1)];
    saveasinflip(peak)
end


function [p, m, data_lab] = combineFitResults(varargin)
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    hA2 = findobj(gcbf, 'tag', 'PeakAxes');
    fit = evalin('base', 'fit');

    h = findobj(hA1, 'tag', 'foundpeaks');
    h2 = findobj(hA2, 'tag', 'backsubdata');
    a = get(h, 'userdata');
    if numel(h) > 1
        %m = cell2mat(get(h, 'userdata'));
        m = cell2mat(cellfun(@(x) x(1), a, 'Uniformoutput', false));
        %[~, ind] = min(abs(m-xInd));
    elseif numel(h) == 1
        m = a(1);
    else
        m = [];
    end
    m = sort(m);
    param = [];
    if isfield(fit, 'peakshape')
        data_lab = {'d_spacing(A)', 'Fit_peakArea',  'Fit_peakCenter'};
        switch fit.peakshape
            case 'gfit'
                %p = reshape(fit.param, 5, numel(fit.param)/5)';
                data_lab = [data_lab, 'Fit_GaussianWidth'];
            case 'vfit'
                %p = reshape(fit.param, 6, numel(fit.param)/6)';
                data_lab = [data_lab, 'Fit_GaussianWidth', 'Fit_LorentzWidth'];
        end
        for i=1:numel(h)
            hIq = getappdata(h2(i), 'sim_Iq_handle');
            p = get(hIq, 'userdata');
            if numel(p) == 7
                p(5) = [];
            end
            param = [param;p];
        end
        p = param;
        [Y,I] = sort(p(:,2),1,'ascend'); % sort by the peak center;
        for j = 1:size(p,2), Y(:,j) = p(I,j); end
        m = [2*pi./Y(:,2), Y];
        data_lab = [data_lab, 'Fit_background_slope', 'Fit_background_intercept', 'Area'];
    end
end


    function loadhkls(varargin)
        if strcmp(get(gcbo, 'checked'), 'on')
            setfindpeaks(varargin{1})
            set(gcbo, 'checked', 'off');
        else
            hA1 = findobj(gcbf, 'tag', 'IqAxes');
            yl = get(hA1, 'ylim');
            hkls = evalin('base', 'indexing_hkls');
            hklold = inf;
            for i=1:size(hkls, 1)
                xInd = hkls(i, 1);
                yInd = hkls(i, 2);
                if xInd==hklold
                    continue
                end
                hklold = xInd;
                h = line(gca, [xInd, xInd], [yl(1), yInd], 'color', 'r', 'parent', hA1);
                set(h, 'tag', 'foundpeaks');
                set(h, 'userdata', xInd);
            end
            setfindpeaks(varargin{1})
            set(gcbo, 'checked', 'on');
            setappdata(gcf, 'FitMode', 'hkls')
        end
    end

    function setfindpeaks(varargin)
        obj = varargin{1};
        if strcmp(get(obj, 'tag'), 'SSL_MenuSetfindPeaks2')
            % manual peak selection is chosen.
            setappdata(gcf, 'FitMode', 'manual')
        end
        if strcmp(get(obj, 'checked'), 'on')
            set(gcbo, 'checked', 'off');
            state = get(gcf, 'userdata');
            uirestore(state);
            set(gcf,'Pointer','arrow');

        else
            state = uisuspend(gcf);
            set(gcf, 'userdata', state);
            set(gcbo, 'checked', 'on');
            set(gcf,'Pointer','crosshair');
            hA1 = findobj(gcbf, 'tag', 'IqAxes');
            set(hA1, 'buttondownfcn', @setbtndwnfcn)
        end
    end
    function setfindpeaksauto(varargin)
        if strcmp(get(gcbo, 'checked'), 'on')
            setfindpeaks(varargin{1})
            set(gcbo, 'checked', 'off');
        else
            hA1 = findobj(gcbf, 'tag', 'IqAxes');
            hl = findobj(hA1, 'tag', 'rawdata');
            xd = get(hl, 'xdata');
            yd = get(hl, 'ydata');
            xl = get(hA1, 'xlim');
            yl = get(hA1, 'ylim');
            s = inputdlg('Sensitivity to find peaks','Resolution', 1, {'20'});
            peak=fpeak(xd(:),yd(:),str2double(s{1}),[xl, yl]);
            hklold = 0;
            for i=1:size(peak, 1)
                xInd = peak(i, 1);
                yInd = peak(i, 2);
                if xInd==hklold
                    continue
                end
                hklold = xInd;
                h = line(gca, [xInd, xInd], [yl(1), yInd], 'color', 'r', 'parent', hA1);
                set(h, 'tag', 'foundpeaks');
                set(h, 'userdata', xInd);
            end
            setfindpeaks(varargin{1})
            set(gcbo, 'checked', 'on');
            set(hA1, 'buttondownfcn', @setbtndwnfcn)
            setappdata(gcf, 'FitMode', 'manual')
        end
    end
    function setbtndwnfcn(varargin)
        % get mouse position
        st = get(gcbf, 'Selectiontype');
        pt = get(gca, 'CurrentPoint');
        xInd = (pt(1, 1));
        yInd = (pt(1, 2));
        switch st
            case 'extend'
%                 pt = get(gca, 'CurrentPoint');
%                 xInd = (pt(1, 1));
%                 yInd = (pt(1, 2));
                h = findobj(gca, 'tag', 'foundpeaks');
                a = get(h, 'userdata');
                if numel(h) > 1
                    %m = cell2mat(get(h, 'userdata'));
                    m = cell2mat(cellfun(@(x) x(1), a, 'Uniformoutput', false));
                    [~, ind] = min(abs(m-xInd));
                elseif numel(h) == 1
                    ind = 1;
                else
                    ind = [];
                end
                ud = get(h(ind), 'userdata');
                if xInd < ud
                    ud(2) = xInd;
                    if numel(ud) < 3
                        ud(3) = 0;
                    end
                elseif xInd > ud
                    if numel(ud) < 2
                        ud(2) = 0;
                    end
                    ud(3) = xInd;
                end
                hw = line(gca, [xInd, xInd], [1E-10, yInd], 'color', 'm', 'linestyle', '--');
                set(hw, 'tag', 'foundpeaks_wd');

                set(h(ind), 'userdata', ud);
            case 'normal'
                h = line(gca, [xInd, xInd], [1E-10, yInd], 'color', 'r');
                set(h, 'tag', 'foundpeaks');
                set(h, 'userdata', xInd);
                
            case 'alt'
                h = findobj(gca, 'tag', 'foundpeaks');
                a = get(h, 'userdata');
                if numel(h) > 1
                    %m = cell2mat(get(h, 'userdata'));
                    m = cell2mat(cellfun(@(x) x(1), a, 'Uniformoutput', false));
                    [~, ind] = min(abs(m-xInd));
                elseif numel(h) == 1
                    ind = 1;
                else
                    ind = [];
                end
                delete(h(ind))
        end
        

    end

function drawGaussianPeaks(varargin)
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    hA2 = findobj(gcbf, 'tag', 'PeakAxes');
    delete(findobj(hA1, 'tag', 'sim_gauss_peak'));
    delete(findobj(hA1, 'tag', 'sim_voigt_peak'));
    delete(findobj(hA2, 'tag', 'sim_Iq'));

    h = findobj(hA2, 'tag', 'backsubdata');
    q = get(h, 'xdata');
%    back = getappdata(gcbf, 'backgrounddata');
    %q = q(:);Iq = zeros(size(q));
    FWHM = [];
%     if isempty(back)
%         back = zeros(size(q));
%     end
    peakp = cell(size(h));
    for i=1:numel(h)
        ud = get(h(i), 'userdata');
        peakp{i} = ud;
        if numel(ud) > 1
            FWHM = [FWHM, abs(ud(3)-ud(2))];
        end
    end
    if ~isempty(FWHM)
        meanFWHM = mean(FWHM);
    else
        m = cell2mat(cellfun(@(x) x(1), peakp, 'Uniformoutput', false));
        meanFWHM = abs(min(diff(m)))/2;
    end
    for i=1:numel(h)
        ud = peakp{i};
        P = getappdata(h(i), 'back');
        yd = max(get(h(i), 'Ydata'));
        if numel(ud)>1
            wd = abs(ud(3)-ud(2));
        else
            wd = meanFWHM;
        end
        yline = gaussb(q{i}(:), [yd, ud(1), wd/5, 0]) + P(1)*q{i}(:)+P(2);
        %Iq = Iq + yline;
        hl = line(hA1, 'xdata', q{i}, 'ydata', yline);
        set(hl, 'tag', 'sim_gauss_peak');
        set(hl, 'userdata', [yd, ud(1), wd/5, P]);
        hss = line(hA2, 'xdata', q{i}, 'ydata', yline);
        set(hss, 'tag', 'sim_Iq');
        setappdata(h(i), 'sim_Iq_handle', hss);
        set(hss, 'userdata', [yd, ud(1), wd/5, P]);
    end
end

function drawVoigtPeaks(varargin)
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    hA2 = findobj(gcbf, 'tag', 'PeakAxes');
    delete(findobj(hA1, 'tag', 'sim_gauss_peak'));
    delete(findobj(hA1, 'tag', 'sim_voigt_peak'));
    delete(findobj(hA2, 'tag', 'sim_Iq'));

    h = findobj(hA2, 'tag', 'backsubdata');
    q = get(h, 'xdata');
%    back = getappdata(gcbf, 'backgrounddata');
    %q = q(:);Iq = zeros(size(q));
    FWHM = [];
%     if isempty(back)
%         back = zeros(size(q));
%     end
    peakp = cell(size(h));
    for i=1:numel(h)
        ud = get(h(i), 'userdata');
        peakp{i} = ud;
        if numel(ud) > 1
            FWHM = [FWHM, abs(ud(3)-ud(2))];
        end
    end
    if ~isempty(FWHM)
        meanFWHM = mean(FWHM);
    else
        m = cell2mat(cellfun(@(x) x(1), peakp, 'Uniformoutput', false));
        meanFWHM = abs(min(diff(m)))/2;
    end
    for i=1:numel(h)
        ud = peakp{i};
        P = getappdata(h(i), 'back');
        yd = max(get(h(i), 'Ydata'));
        if numel(ud)>1
            wd = abs(ud(3)-ud(2));
        else
            wd = meanFWHM;
        end
        area = yd*wd/2;
        yline = pseudovoigt(q{i}(:), [area, ud(1), wd/5, wd/5, 0]) + P(1)*q{i}(:)+P(2);
%        yline = voigt(q{i}(:), [yd, ud(1), wd/5, wd/5, 0]) + P(1)*q{i}(:)+P(2);
        %Iq = Iq + yline;
        hl = line(hA1, 'xdata', q{i}, 'ydata', yline);
        set(hl, 'tag', 'sim_voigt_peak');
        set(hl, 'userdata', [yd, ud(1), wd/5, wd/5, P]);
        hss = line(hA2, 'xdata', q{i}, 'ydata', yline);
        set(hss, 'tag', 'sim_Iq');
        setappdata(h(i), 'sim_Iq_handle', hss);
        setappdata(h(i), 'sim_Iq_handle2', hl);
        set(hss, 'userdata', [yd, ud(1), wd/5, wd/5, P]);
        setappdata(hl, 'pairhandle', hss);
        setappdata(hss, 'pairhandle', hl);
    end
    %h = line(hA2, 'xdata', q', 'ydata', Iq);
    %set(h, 'tag', 'sim_Iq');
end

function generatebackground(varargin)
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    hA2 = findobj(gcbf, 'tag', 'PeakAxes');
    delete(findobj(hA1, 'tag', 'sim_back'));
    delete(findobj(hA2, 'tag', 'backsubdata'));
    h = findobj(hA1, 'tag', 'foundpeaks');
    q = get(findobj(hA1, 'tag', 'rawdata'), 'xdata');
    y = get(findobj(hA1, 'tag', 'rawdata'), 'ydata');
    q = q(:);y = y(:);y0 = y;
    q0 = q;
    FWHM = [];
    for i=1:numel(h)
        ud = get(h(i), 'userdata');
        if numel(ud) > 1
            FWHM = [FWHM, abs(ud(3)-ud(2))];
        end
    end
    meanFWHM = mean(FWHM);
    goodpix = zeros(size(q));
    q_sel = [];
    Iq_sel = [];
    ispeakwidthdefined = 0;
    for i=1:numel(h)
        ud = get(h(i), 'userdata');
        %yd = max(get(h(i), 'Ydata'));
        if numel(ud)>1
            wd = abs(ud(3)-ud(2));
            ispeakwidthdefined = 1;
        else
            wd = meanFWHM;
        end
        if isnan(wd)
            fprintf('Determine lower and upper boundaries for at least a peak by shift left clicks with SET PEAKS mode.\n');
            return
        end
        wd = abs(wd/1.5);
        tl = (q > ud(1)-wd);
        tr = (q < ud(1)+wd);
        t = tl&tr;
        if ~ispeakwidthdefined
            qs = q(t);
            ys = y(t);
            P = polyfit([qs(1), qs(end)],[ys(1), ys(end)],1);
            ytemp = ys - (P(1)*qs+P(2));
            % finding minima and connect two minima....
            [~, mi] = min(abs(qs-ud(1)));
            [~, m1] = min(ytemp(1:mi));
            [~, m2] = min(ytemp(mi:end));
            qss = qs(m1:(mi+m2-1));
            yss = ys(m1:(mi+m2-1));
            t = isnan(yss);
            yss(t) = [];
            qss(t) = [];
            ispeakwidthdefined = 1;
        else
            qss = q(t);
            yss = y(t);
            t = isnan(yss);
            yss(t) = [];
            qss(t) = [];
        end
        P = polyfit([qss(1), qss(end)],[yss(1), yss(end)],1);
        hp = line(hA2, 'xdata', qss, 'ydata', yss, 'color', 'r');
        set(hp, 'tag', 'backsubdata');
        setappdata(hp, 'back', P);
        set(hp, 'userdata', ud);
        fprintf('%i peaks are selected.\n', numel(h));
        fprintf('In order to group them to fit, set "peak2fitgroup" array. For example, \n');
        fprintf('When there is 5 peaks, of which you like to group 1 and 2 together and 4 and 5 together:\n');
        fprintf(', and you do not want to fit the third one:\n');
        fprintf('peak2fitgroup = [1, 1, 0, 4, 4]\n');

    end
end
function [cv, yl] = vfit(p, y, x, err)
    % x should be an array of x values
    % y should be an array of y values
    x = x(:);
    y = y(:);
    if nargin<4
        err = y;
        err(err == 0) = min(err > 0);
    else
        err = err(:);
    end
    
    yl = zeros(size(x));

    
    fit = evalin('base', 'fit'); % to display during iteration...

    fit.param = [];
    back = (p(end-1)*x + p(end));
    for i=1:4:(numel(p)-2)
        yline = pseudovoigt(x, [p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), 0]);
        yl = yl + yline(:);
        
        % display during the iteration......
        dtsetN = fix((i+1)/4)+1;
        if iscell(fit.xfit)
            xv = fit.xfit{dtsetN};
        else
            xv = fit.xfit;
        end
        yv = pseudovoigt(xv, [p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), 0]);
        backv = (p(end-1)*xv + p(end));
        if iscell(fit.xfit)
            fit.yfit{dtsetN} = yv(:) + backv(:);
        else
            fit.yfit = yv(:) + backv(:);
        end
        fit.param(dtsetN, :) = [p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), p(end-1), p(end)];
    end
    yl = yl + back; % background added.
    cv = sum((y - yl).^2./abs(err));
    cv = 1/numel(p)*cv;
    assignin('base', 'fit', fit)
end
function [cv, yline] = vfit_old(p, y, x, err)
    yline = cell(size(x));
    fit = evalin('base', 'fit');
    k = 1;cv = 0;N = 0;
    fitmultipeak = 0;
    if ~isempty(fit)
        if fit.NdataSet > 1
            fitmultipeak = 1;
        end
    end
    param = [];
    if fitmultipeak
        xv = x;
        yv = y;
        yl = 0;
        for i=1:4:(numel(p)-2)
            %x = fit.xfit{k}(:);
            if nargin<4
                err = yv;
                err(err == 0) = min(err > 0);
            end
            %yl0 = pseudovoigt(xv, [p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), 0]) + (p(end-1)*xv + p(end))/fit.NdataSet;
            yline{k} = pseudovoigt(x, [p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), 0]) + (p(end-1)*x + p(end));
            param = [param; p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), p(end-1), p(end)];
            yl = yl + yline{k};
            k = k + 1;
        end
        cv = cv + sum((yv - yl).^2./abs(err));
        N = numel(xv);
    else            
        for i=1:6:numel(p)
            yline{k} = pseudovoigt(x{k}(:), [p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), 0]) + p(i+4)*x{k}(:) + p(i+5);
            if nargin<4
                err = y{k}(:);
                err(err == 0) = min(err > 0);
            end
            cv = cv + sum((y{k}(:) - yline{k}(:)).^2./abs(err));
            param = [param; p];
            N = N + numel(x{k});
            k = k + 1;
        end
    end
    cv = 1/(N-numel(p))*cv;
    if ~isempty(fit)
        fit.yfit = yline;
        fit.param = param;
        assignin('base', 'fit', fit);
    end
    %cv = chi_squared(y, yline, 5);
end

function [cv, yl] = gfit(p, y, x, err)
    % x should be an array of x values
    % y should be an array of y values
    x = x(:);
    y = y(:);
    if nargin<4
        err = y;
        err(err == 0) = min(err > 0);
    else
        err = err(:);
    end
    
    yl = zeros(size(x));

    
    fit = evalin('base', 'fit'); % to display during iteration...

    
    back = (p(end-1)*x + p(end));
    for i=1:3:(numel(p)-2)
        yline = pseudovoigt(x, [p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), 0]);
        yl = yl + yline(:);
        
        % display during the iteration......
        dtsetN = fix((i+1)/4)+1;
        xv = fit.xfit{dtsetN};
        yv = pseudovoigt(xv, [p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), 0]);
        backv = (p(end-1)*xv + p(end));
        fit.yfit{dtsetN} = yv(:) + backv(:);
        fit.param(dtsetN, :) = [p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), p(end-1), p(end)];
    end
    yl = yl + back; % background added.
    cv = sum((y - yl).^2./abs(err));
    cv = 1/numel(p)*cv;
    assignin('base', 'fit', fit)
end

function [cv, yline] = gfit_old(p, yin, xin)
    yline = cell(size(xin));
    fit = evalin('base', 'fit');
    k = 1;cv = 0;N = 0;
    fitmultipeak = 0;
    if ~isempty(fit)
        if numel(fit.NdataSet) > 1
            fitmultipeak = 1;
        end
    end
    param = [];
    if ~iscell(xin)
        x{k} = xin;
        y{k} = yin;
    else
        x = xin;
        y = yin;
    end
    if fitmultipeak
        xv = x;
        yv = y;
        yl = 0;
        if nargin<4
            err = yv;
            err(err == 0) = min(err > 0);
        end
        for i=1:3:numel(p)
            x = fit.xfit{k}(:);
%            yl0 = voigt(xv, [p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), 0]) + (p(end-1)*xv + p(end))/fit.NdataSet;
%            yline{k} = voigt(x, [p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), 0]) + (p(end-1)*x + p(end));
            yl0 = pseudovoigt(xv, [p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), 0]) + (p(end-1)*xv + p(end))/fit.NdataSet;
            yline{k} = pseudovoigt(x, [p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), 0]) + (p(end-1)*x + p(end));
            param = [param; p(i), p(i+1), abs(p(i+2)), abs(p(i+3)), p(end-1), p(end)];
            yl = yl + yl0;
            k = k + 1;
        end
        cv = cv + sum((yv - yl).^2./abs(err));
        N = numel(xv);
    else            
        if nargin<4
            err = y{k}(:);
            err(err == 0) = min(err > 0);
        end
        for i=1:4:numel(p)
            yline{k} = gaussb(x{k}(:), [p(i), p(i+1), abs(p(i+2)), 0])+ p(i+3)*x{k}(:) + p(i+4);
            cv = cv + sum((y{k}(:) - yline{k}(:)).^2./abs(err));
            N = N + numel(x{k});
            param = [param; p];
            k = k + 1;
        end
    end
    cv = 1/(N-numel(p))*cv;
    if ~isempty(fit)
        fit.yfit = yline;
        fit.param = param;
        assignin('base', 'fit', fit);
    end
    %cv = chi_squared(y, yline, 5);
end

function peak = combinepeaks(h, i)
    peak = i;
    if i==numel(h)
        return
    end
    
    k = i+1;
    hIq0 = getappdata(h(i), 'sim_Iq_handle');
    ud0 = get(hIq0, 'userdata');
    hIq = getappdata(h(k), 'sim_Iq_handle');
    ud = get(hIq, 'userdata');
    if numel(ud) == 6
        udfwhm = voigtfwhm(ud(3), ud(4));
    else
        udfwhm = abs(ud(3));
    end
    if numel(ud0) == 6
        ud0fwhm = voigtfwhm(ud0(3), ud0(4));
    else
        ud0fwhm = abs(ud0(3));
    end
    while abs(ud(2)-ud0(2))< (udfwhm+ud0fwhm)/4.5
        peak = [peak, k];
        ud0 = ud;
        if k == numel(h)
            break
        end
        k = k+1;
        hIq = getappdata(h(k), 'sim_Iq_handle');
        ud = get(hIq, 'userdata');
    end
        
end        
            

function fitPeaks(varargin)
    try
        peak2fitgroup = evalin('base', 'peak2fitgroup');
    % when there is 5 peaks and you like to group 1 and 2 together and 4
    % and 4 together.
    % peak2fitgroup = [1, 1, 3, 4, 4];
    catch
        peak2fitgroup = [];
    end
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    hA2 = findobj(gcbf, 'tag', 'PeakAxes');
%    q0 = get(findobj(hA1, 'tag', 'rawdata'), 'xdata');
    h = findobj(hA2, 'tag', 'backsubdata');
    xl = get(hA2, 'xlim');
    try
        fit = evalin('base', 'fit');
    catch
        fit = [];
    end
    fit.fitlineh = [];
    htt = findobj(hA1, 'tag', 'sim_gauss_peak');
    peakshape = 'gfit';
    if isempty(htt)
        htt = findobj(hA1, 'tag', 'sim_voigt_peak');
        peakshape = 'vfit';
    end
    ht = [];
    for i=1:numel(htt)
        ht = [ht;i, get(htt(i), 'userdata')];
    end
    [~, ind] = sort(ht(:,3));
    h = flip(h); % handle h is read from high number to low.
    h = h(ind); % h is sorted by the peak center value.
    ht = ht(ind, :);
    
    % if the axis is zoomm in, then only peak in the zoom will be used.
    t = (ht(:, 3) < xl(1)) | (ht(:,3) > xl(2));
    h(t) = [];
    ht(t,:) = [];
    
%    ht = ht(ind, :);
    q = get(h, 'xdata');%q = q(:);
    Iq = get(h, 'ydata');%Iq = Iq(:);

    refit = 0;
    i = 1;
    
    fitmode = getappdata(gcf, 'FitMode');
    
    while (i<=numel(h))
        if isempty(peak2fitgroup)
            peak = combinepeaks(h, i);
        else
            peak = find(peak2fitgroup == i);
        end
        if isempty(peak)
            i = i+1;
            continue
        end
        p = [];UB = [];LB = [];res = [];
        fit.fitlineh = [];
        fit.simlineh = [];
        fit.isidentical = zeros(size(peak));
        
        for k = 1:numel(peak)
            hIq = getappdata(h(peak(k)), 'sim_Iq_handle');
            hIq2 = getappdata(h(peak(k)), 'sim_Iq_handle2');
            ud = get(hIq, 'userdata');
            pfit = getappdata(hIq, 'fit');
            if k>1
                ppos = p(:,2);
                ind = find(ppos == ud(2));
                if isempty(ind)
                    fit.isidentical(k) = 0;
                else
                    fit.isidentical(k) = ind;
                end
            end
            if fit.isidentical(k)~=0
                continue
            end
                S = ud(end-1);
                if S> 0
                    US = S*2;
                    LS = S/2;
                else
                    LS = S*2;
                    US = S/2;
                end
                IS = ud(end);
                if IS> 0
                    UIS = IS*2;
                    LIS = IS/2;
                else
                    LIS = IS*2;
                    UIS = IS/2;
                end
                p = [p, ud(1:end-2)];
                switch fitmode
                    case 'manual'
                        centerLB = ud(2)-abs(ud(3)/1.5);
                        centerUB = ud(2)+abs(ud(3)/1.5);
                    case 'hkls'
                        centerLB = ud(2);
                        centerUB = ud(2);
                end
                LB = [LB, ud(1)*0.00001, centerLB, abs(ud(3:end-2))*0.0001];
                UB = [UB, ud(1)*100, centerUB, abs(ud(3:end-2))*5];
%            end
            fit.fitlineh(k) = hIq;
%            fit.simlineh(k) = htt(ht(peak(k)), 1);
            fit.simlineh(k) = hIq2;
        end
        

        % Setup options
        options = optimset('fminsearch');
        options = optimset(options, 'TolX',0.1E-3);
        options = optimset(options, 'OutputFcn',@outfunPF);
        options = optimset(options, 'MaxIter',300);
        options = optimset(options, 'MaxFunEvals', 1000);
        if i==1
            fprintf('Fitting started for %i peaks.\n', numel(h));
        else
            if numel(peak) == 1
                fprintf('Fitting will be performed for the peak %i.\n', peak);
            else
                fprintf('Fitting will be performed for the peaks %i through %i.\n', peak(1), peak(end));
            end
        end
        fit.xfit = [];
        fit.yfit = [];
        fit.NdataSet = numel(peak);
        
        if fit.NdataSet>1
            xv = [];
            yv = [];
            for k=1:fit.NdataSet
                tmp = Iq{peak(k)}==0;
                Idata0 = Iq{peak(k)}(:);
                qdata0 = q{peak(k)}(:);
                xv = [xv; qdata0];
                yv = [yv; Idata0];
                fit.xfit{k} = qdata0;
                fit.yfit{k} = Idata0;
            end
            [xv, ind] = unique(xv);
            yv = yv(ind);
            err = abs(yv);
            nn = max([max(yv), 1]);
            err(err == 0) = nn;
            P = polyfit([xv(1), xv(end)],[yv(1), yv(end)],1);
            p = [p, P];
            LB = [LB, P-abs(P)*0.2];
            UB = [UB, P+abs(P)*0.2];
        else
            LB = [LB, LS, LIS];
            UB = [UB, US, UIS];
            p = [p, ud(end-1:end)];
            
            if iscell(q)
                xv = q{peak};
                yv = Iq{peak};
            else
                xv = q;
                yv = Iq;
            end
            err = abs(yv);
            nn = max([max(yv), 1]);
            err(err == 0) = nn;
            P = polyfit([xv(1), xv(end)],[yv(1), yv(end)],1);
            p(end-1:end) = P;
            LB(end-1:end) = P-abs(P)*0.01;
            UB(end-1:end) = P+abs(P)*0.01;
%             p(1) = max(yv);
%             UB(1) = max(yv)*10;
%             LB(1) = 0;
%             if UB(3) < 5E-3
%                 UB(3) = 5E-3;
%                 UB(4) = 5E-3;
%             end
            fit.xfit = xv;
            fit.yfit = yv;
        end
        fit.stop = false;
        fit.peakshape = peakshape;
        fit.LB = LB;
        fit.UB = UB;
        NLPstart = p;
        A = [];B = [];

        
        assignin('base', 'fit', fit)
        
        switch peakshape
            case 'gfit'
                INLP = fminsearchcon(@(x) gfit(x, yv, xv, err),NLPstart,LB,UB, A, B, [], options);
                a = [];
                for tmp=1:numel(peak)
                    b = INLP(((tmp-1)*3+1))*INLP(((tmp-1)*3+3))*sqrt(2*pi);
                    a = [a, b];
                end
            case 'vfit'
                INLP = fminsearchcon(@(x) vfit(x, yv, xv, err),NLPstart,LB,UB, A, B, [], options);
                a = [];
                for tmp=1:numel(peak)
                    b = INLP(((tmp-1)*4+1));
%                    b = voigtarea(q0, INLP(((tmp-1)*4+1):((tmp-1)*4+4)));
                    a = [a, b];
                end
        end
        
        % The result is saved back to 'userdata' in outfunPF function
        setappdata(hIq, 'fit', INLP); % this line is no need.
%        res = [res; INLP, a];
        fprintf('%i / %i is done.\n', i-1+numel(peak), numel(h));
        i = peak(end)+1;
    end
%    fit.param = res;
    assignin('base', 'fit', fit)
end
function fitPeaks_old(varargin)
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    hA2 = findobj(gcbf, 'tag', 'PeakAxes');
    h = findobj(hA2, 'tag', 'backsubdata');
    q = get(h, 'xdata');%q = q(:);
    Iq = get(h, 'ydata');%Iq = Iq(:);
    %t = Iq == 0;
    %q(t) = [];
    %Iq(t) = [];
    fit = evalin('base', 'fit');
    
    %assignin('base', 'Iq', Iq);
            %% Setup fitting parameters.
    htt = findobj(hA1, 'tag', 'sim_gauss_peak');
    peakshape = 'gfit';
    if isempty(htt)
        htt = findobj(hA1, 'tag', 'sim_voigt_peak');
        peakshape = 'vfit';
    end
    %fitFunHandle =  str2func(peakshape);
    refit = 0;
    p = [];UB = [];LB = [];
    for i=1:numel(h)
        hIq = getappdata(h(i), 'sim_Iq_handle');
        ud = get(hIq, 'userdata');
        p = [p, ud];

        S = ud(end-1);
        if S> 0
            US = S*2;
            LS = S/2;
        else
            LS = S*2;
            US = S/2;
        end
        IS = ud(end);
        if IS> 0
            UIS = IS*2;
            LIS = IS/2;
        else
            LIS = IS*2;
            UIS = IS/2;
        end
        LB = [LB, ud(1)*0.01, ud(2)-abs(ud(3)/1.5), abs(ud(3:end-2))*0.0001, LS, LIS];
        UB = [UB, ud(1)*100, ud(2)+abs(ud(3)/1.5), abs(ud(3:end-2))*5, US, UIS];
%         LB = [LB, ud(1)*0.01, ud(2)-abs(ud(3)/1/5), abs(ud(3:end-2))*0.0001, ud(end-1)/2, ud(end)-ud(1)];
%         UB = [UB, ud(1)*100, ud(2)+abs(ud(3)/1.5), abs(ud(3:end-2))*10, ud(end-1)*2, ud(end)+ud(1)];
        fit.fitlineh(i) = hIq;
    end
        
    fit.NdataSet = 1;
    fit.stop = false;
    assignin('base', 'fit', fit)
    
    if isfield(fit, 'peakshape')
        if strcmp(fit.peakshape, peakshape)
            if numel(p) == numel(fit.param)
                if isfield(fit, 'LB')
                    refit = 1;
                end
            end
        end
    end
    if refit == 1
        LB = fit.LB;
        UB = fit.UB;
        p = fit.param;
    end
    fit.peakshape = peakshape;
    fit.LB = LB;
    fit.UB = UB;
    NLPstart = p;
    A = [];B = [];
        
    %% Setup options
    options = optimset('fminsearch');
    options = optimset(options, 'TolX',0.1E-6);
%        options = optimset(options, 'PlotFcns',@optimplotx);
    options = optimset(options, 'OutputFcn',@outfunPF);
    options = optimset(options, 'MaxIter',5000);
    options = optimset(options, 'MaxFunEvals', 5000);
    switch peakshape
        case 'gfit'
            INLP = fminsearchcon(@(x) gfit(x, Iq, q),NLPstart,LB,UB, A, B, [], options);
%            [~, yv] = gfit(INLP, Iq, q);
        case 'vfit'
            INLP = fminsearchcon(@(x) vfit(x, Iq, q),NLPstart,LB,UB, A, B, [], options);
%            [~, yv] = vfit(INLP, Iq, q);
    end
%    set(hIq, 'ydata', yv);
    fit.param = INLP;
    assignin('base', 'fit', fit)
end
function stopfitPeaks(varargin)
    fit = evalin('base', 'fit');
    fit.stop = true;
    assignin('base', 'fit', fit)
end
function stop = outfunPF(varargin)
    state = varargin{3};
    fit = evalin('base', 'fit');
    switch state
        case 'init'
%            disp('Fit starts')
        case 'iter'
            %[~, yv] = vfit(varargin{1}, [], q);
            if isfield(fit, 'yfit')
                for i=1:numel(fit.fitlineh)
                    if fit.isidentical(i) ~=0
                        yfit = fit.yfit{fit.isidentical(i)};
                    else
                        if iscell(fit.yfit)
                            yfit = fit.yfit{i};
                        else
                            yfit = fit.yfit;
                        end
                    end
                    set(fit.fitlineh(i), 'ydata', yfit);
                end
                drawnow;
            end
        case 'done'
            if isfield(fit, 'yfit')
                for i=1:numel(fit.simlineh)
                    if fit.isidentical(i) ~=0
                        yfit = fit.yfit{fit.isidentical(i)};
                        p = fit.param(fit.isidentical(i), :);
                    else
                        if iscell(fit.yfit)
                            yfit = fit.yfit{i};
                        else
                            yfit = fit.yfit;
                        end
                        p = fit.param(i, :);
                    end
                    
                    set(fit.simlineh(i), 'ydata', yfit);
                    set(fit.fitlineh(i), 'userdata', p);
%                    t = get(fit.simlineh(i), 'userdata');
                end
                drawnow;
            end
%            disp('Fit done')
        otherwise
    end
    stop = fit.stop;
end
function clearall(varargin)
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    hA2 = findobj(gcbf, 'tag', 'PeakAxes');

    delete(findobj(hA1, 'tag', 'foundpeaks'));
    delete(findobj(hA1, 'tag', 'foundpeaks_wd'));
    delete(findobj(hA1, 'tag', 'sim_gauss_peak'));
    delete(findobj(hA1, 'tag', 'sim_voigt_peak'));
    delete(findobj(hA1, 'tag', 'sim_back'));
    delete(findobj(hA2, 'tag', 'sim_Iq'));
    delete(findobj(hA2, 'tag', 'backsubdata'));
    %delete(findobj(hA1, 'tag', 'foundpeaks'));
end
end
    
    
