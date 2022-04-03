function SAXSLee_peakfinder2(varargin)
% For simple object such as spherical, cylinderical or lamella stures,
% it may be possible to obtain excess electron density profile along
% radial, cross sectional and normal to the plane directions, respectively.
% This program is to convert I(q) to A(q) and finally to get rho(r),
% where users may arbitrary decide phase of amplitudes.
% Look at also Lipid.m

warning off
verNumber = '2.0';
init(varargin)
hSL = gcbf;
if isempty(hSL)
    hSL = gcf;
end
hSLaxes = findobj(hSL, 'type', 'axes');
coupleindex = 1;

function init(varargin)
f = figure;
%set(f, 'MenuBar', 'none');
%tbh = uitoolbar(f);
%set(f, 'uitoggletool', 'on');
set(f, 'numbertitle', 'off')
set(f, 'Tag', 'SAXSLee_peakfinder')
set(f, 'Name', 'Peak Fitting with Pseudo-Voigt Function');

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
%set(findall(hMenubar), 'visible', 'off')
hMenubar = findall(gcf,'tag','figMenuDesktop');
set(findall(hMenubar), 'visible', 'off')
hMenubar = findall(gcf,'tag','figMenuWindow');
set(findall(hMenubar), 'visible', 'off')
%get(findall(hMenubar),'tag')
%hToolbar = findall(gcf,'tag','FigureToolBar');
%set(hToolbar, 'visible', 'on');
%% Menu
hMenuFile = uimenu(f,...
    'Label','&File',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFile');
hMenuFileOpen = uimenu(hMenuFile,...
    'Label','&Load Data from SAXSLee...',...
    'Position',3,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileOpen',...
    'separator','on',...
    'callback',@loaddata);
hMenuFileOpen = uimenu(hMenuFile,...
    'Label','&Load Data (q, int)...',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileOpenxy',...
    'callback',@loaddataxy);
hMenuFileOpen = uimenu(hMenuFile,...
    'Label','&Load Data (ang, q, int)...',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileOpen0xy',...
    'callback',@loaddata0xy);
hMenuFileOpen2 = uimenu(hMenuFile,...
    'Label','&Load Data from indexing...',...
    'Position',4,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileOpen',...
    'callback',{@loaddatafromindexing, varargin{1}});
hMenuFileSave = uimenu(hMenuFile,...
    'Label','&Save Result...',...
    'Position',5,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileSave',...
    'separator','on',...
    'callback',@saveResults);
hMenuFileSave = uimenu(hMenuFile,...
    'Label','&Save for DICVOL...',...
    'Position',7,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileSave',...
    'callback',{@savedspacings, 'DICVOL'});
hMenuFileSave = uimenu(hMenuFile,...
    'Label','&Save for McMaille...',...
    'Position',8,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileSave',...
    'callback',{@savedspacings, 'McMaille'});
hMenuFileSaveInflip = uimenu(hMenuFile,...
    'Label','&Save as Inflip...',...
    'Position',9,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileSaveInflip',...
    'Accelerator','I',...
    'callback',@saveinflip);
hMenuProc = uimenu(f,...
    'Label','&Process',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuProc');
hMenuProcOption = uimenu(hMenuProc,...
    'Label','Setting...',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuProcOption',...
    'callback',@software_option);
hMenuSetFindPeaks = uimenu(hMenuProc,...
    'Label','&Locate Peaks...',...
    'Position',2,...
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
    'Position',3,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuSetfindPeaksManual',...
    'callback',@setfindpeaks);
hMenuSetFindPeaks2 = uimenu(hMenuSetFindPeaks,...
    'Label','&Locate peaks automatically...',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuSetfindPeaksAuto',...
    'callback',@setfindpeaksauto);
hMenuFindMinima = uimenu(hMenuProc,...
    'Label','Show Selected Peaks/Trim Peaks',...
    'Position',3,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFindMinima',...
    'callback',@generatebackground);

hMenuDrawPeaks = uimenu(hMenuProc,...
    'Label','Generate Initial Peaks',...
    'Position',4,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuDrawVoigtPeak',...
    'callback',@drawVoigtPeaks);
hMenuPeakParam = uimenu(hMenuProc,...
    'Label','Coupling for Fitting...',...
    'Position',5,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuPeakParam',...
    'callback', @setpeakparameter);
hMenuAddaPeak = uimenu(hMenuProc,...
    'Label','Add/remove a peak...',...
    'Position',6,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuAddaPeak',...
    'callback', @add_new_peak);
hMenuClearall = uimenu(hMenuProc,...
    'Label','&Clear All...',...
    'Position',7,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuCalAq',...
    'callback',@clearall);


hMenuProc2 = uimenu(f,...
    'Label','&Process2',...
    'Position',3,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuProc_Proc2');
hMenuProcOption = uimenu(hMenuProc2,...
    'Label','Setting...',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuProcOption_Proc2',...
    'callback',@software_option);
hMenuSetFindPeaks2 = uimenu(hMenuProc2,...
    'Label','&Locate Peaks...',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuSetPeaks_Proc2');
hMenuSetFindPeaks21 = uimenu(hMenuSetFindPeaks2,...
    'Label','&Load HKLs...',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_Menuloadhkls_Proc2',...
    'callback',@loadhkls);
hMenuSetFindPeaks22 = uimenu(hMenuSetFindPeaks2,...
    'Label','&Locate peaks manually...',...
    'Position',3,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuSetfindPeaksManual_Proc2',...
    'callback',@setfindpeaks);
hMenuSetFindPeaks23 = uimenu(hMenuSetFindPeaks2,...
    'Label','&Locate peaks automatically...',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuSetfindPeaksAuto_Proc2',...
    'callback',@setfindpeaksauto);
hMenuFindMinima2 = uimenu(hMenuProc2,...
    'Label','Show Selected Peaks/Trim Peaks',...
    'Position',3,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFindMinima_Proc2',...
    'callback',@generatebackground);
hMenuDrawPeaks2 = uimenu(hMenuProc2,...
    'Label','Generate Initial Peaks',...
    'Position',4,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuDrawVoigtPeak_Proc2',...
    'callback',@drawVoigtPeaks);
hMenuPeakParam2 = uimenu(hMenuProc2,...
    'Label','Tune the shape of a peak...',...
    'Position',5,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuPeakParam_Proc2',...
    'callback', @setpeakparameter);



hMenuFit = uimenu(f,...
    'Label','Fit',...
    'Position',4,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFit');
hMenuCalAq = uimenu(hMenuFit,...
    'Label','Fit Peaks...',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuCalAq',...
    'callback',@fitPeaks);
hMenuCalAq = uimenu(hMenuFit,...
    'Label','&Stop Fit Peaks...',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuCalAq',...
    'callback',@stopfitPeaks);
hMenuSetting = uimenu(hMenuFit,...
    'Label','Setting',...
    'Position',3,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFitoption',...
    'callback', @fit_option);


hMenuHelp = uimenu(f,...
    'Label','Help',...
    'Position',5,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFit');
hMenuHelp2 = uimenu(hMenuHelp,...
    'Label','Manual',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuHelpManual',...
    'callback', @peakfit_help);

%% Graph
hA1 = subplot(2, 1, 1);
hA2 = subplot(2, 1, 2);
%tb = axtoolbar(hA1,{'brush', 'datacursor', 'zoomin','zoomout','restoreview'});
set(hA1, 'box', 'on', 'tag', 'IqAxes');
set(hA2, 'box', 'on', 'tag', 'PeakAxes');
end
%% functions

function peakfit_help(varargin)
    test = questdlg('What would you like to do?','Help','Go to Youtube','Cancel','Go to Youtube');
    if strcmp(test,'Go to Youtube')
        dos(['start https://www.youtube.com/channel/UCIVnZD6PKyJU4UNXOPeTviQ']);
    end
end


function loaddataxy(varargin)
    load1ddata(1, 2)
end

function loaddata0xy(varargin)
    load1ddata(2, 3)
end

function load1ddata(xcol, ycol)
    if xcol == 1
        filefilterstr = {'*.dat','data file (*.dat)'; ...
        '*.txt','text (*.txt)'; ...
        '*.*',  'All Files (*.*)'};
    else
        filefilterstr = {'*.txt','text (*.txt)';...
        '*.dat','data file (*.dat)'; ...
        '*.*',  'All Files (*.*)'};
    end
    [filename, pathname] = uigetfile( ...
       filefilterstr, ...
        'Pick a file', ...
        'MultiSelect', 'off');
 
    % This code checks if the user pressed cancel on the dialog.
 
    if isequal(filename,0) || isequal(pathname,0)
       disp('User pressed cancel')
       return
    else
       disp(['User selected ', fullfile(pathname, filename)])
    end
    try
        data = load(fullfile(pathname, filename));
    catch
        [~, data] = hdrload(fullfile(pathname, filename));
    end
    xd = data(:,xcol);
    yd = data(:,ycol);

    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    delete(findobj(hA1, 'tag', 'rawdata'));
    %axes(hA1)
    hNL = plot(xd, yd, 'tag', 'rawdata', 'parent', hA1);
    set(hA1, 'tag', 'IqAxes');
    set(hA1, 'xscale', 'linear');
    set(hA1, 'yscale', 'log');
    filename = strrep(filename, '_', '-');
    title(hA1, filename)
    xlabel(hA1, sprintf('q (1/%c)', char(197)), 'fontsize', 14);
    ylabel(hA1, sprintf('I(q) (a.u.)'), 'fontsize', 14);
    init_parameters
end


function loaddata(varargin)
    SAXSLee_Handle = evalin('base', 'SAXSLee_Handle');
    hL = findobj(SAXSLee_Handle, 'type', 'line', '-xor', '-regexp', 'tag', 'BACK');
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    delete(findobj(hA1, 'tag', 'rawdata'));
    xd = get(hL, 'xdata');
    yd = get(hL, 'ydata');
    %axes(hA1);
    hNL = plot(xd, yd, 'tag', 'rawdata', 'parent', hA1);
    set(hA1, 'tag', 'IqAxes');
    set(hA1, 'xscale', 'linear');
    set(hA1, 'yscale', 'log');
    xlabel(hA1, sprintf('q (1/%c)', char(197)), 'fontsize', 14);
    ylabel(hA1, sprintf('I(q) (a.u.)'), 'fontsize', 14);
    init_parameters
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
    %axes(hA1)
    hNL = plot(xd, yd, 'tag', 'rawdata', 'parent', hA1);
    set(hA1, 'tag', 'IqAxes');
    set(hA1, 'xscale', 'linear');
    set(hA1, 'yscale', 'log');
    xlabel(hA1, sprintf('q (1/%c)', char(197)), 'fontsize', 14);
    ylabel(hA1, sprintf('I(q) (a.u.)'), 'fontsize', 14);
    init_parameters;
end

    function init_parameters(varargin)
        coupleindex = 1;
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
    if numel(varargin) > 2
        format = varargin{3};
    end
    [~, m, data_lab] = combineFitResults(varargin);
    %data_lab = data_lab(data_lab_sel);
    switch format
        case 'McMaille'
            formatstr = {'*.dat'};
        otherwise
            formatstr = {'*.txt';'*.dat'};
    end
    [filename, pathname] = uiputfile(...
        formatstr,...
        'Save as');
    if isequal(filename,0) || isequal(pathname,0)
        disp('User selected Cancel')
        return
    else
        disp(['User selected ',filename])
    end
    fn = fullfile(pathname, filename);
    switch format
        case 'DICVOL'
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
            fprintf(fid, '**** %s with factor %0.5e ****\n', filename, f);
            fprintf(fid, '%i  %s\n', Npeak, '3 1 1 1 1 0 0');
            fprintf(fid, '%0.3f %0.3f %0.3f 0.0 %0.3f 0 0\n', maxd*3, maxd*3, maxd*3, 5*maxd^3);
            fprintf(fid, '%s\n', '0 0 0 0');
            fprintf(fid, '%s\n', '1.0 0 0 0 0');
            for i=1:Npeak
                fprintf(fid, '%0.3f %0.3f\n', m(i, 1), sig(i)*m(i, 1));
            end
            fclose(fid);
        case 'McMaille'
            maxd = m(1, 1);
            f = 1/maxd*5;
            m(:,1) = m(:,1)*f;
            m(:,2) = m(:,2)/max(m(:,2))*100;
            Npeak = length(m(:,1));
            fid = fopen(fn, 'w');
            fprintf(fid, '**** %s with factor %0.5e ****\n', filename, f);
            fprintf(fid, '1.5406 0.0 -3\n');
            for i=1:Npeak
                fprintf(fid, '%0.3f %0.3f\n', m(i, 1), m(i, 2));
            end
            fclose(fid);            
    end
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
            try
                hIq = getappdata(h2(i), 'sim_Iq_handleA2');
            catch
                continue;
            end
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
                setappdata(h, 'myindex', i);
                set(h, 'userdata', xInd);
            end
            setfindpeaks(varargin{1})
            set(gcbo, 'checked', 'on');
            setappdata(gcf, 'FitMode', 'hkls')
        end
    end

    function setfindpeaks(varargin)
        %obj = varargin{1};
        obj = findobj(gcbf, 'tag', 'SSL_MenuSetfindPeaksManual');
        if strcmp(get(obj, 'tag'), 'SSL_MenuSetfindPeaksManual')
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
            set(obj, 'checked', 'on');
            set(gcf,'Pointer','crosshair');
            hA1 = findobj(gcbf, 'tag', 'IqAxes');
            set(hA1, 'buttondownfcn', @setbtndwnfcn)
        end
    end

    function software_option(varargin)
        res_default = 20;
        Np_default = 25;
        domainsize_default = 2000;
        gaussianwidth_default = 0.001;
        dlgtitle = 'Processing Parameters';
        op = getappdata(gcbf, 'peakfitoption');

        if isempty(op)
            definput = {num2str(res_default), num2str(Np_default),...
                num2str(domainsize_default), num2str(gaussianwidth_default)}; 
        else
            if isfield(op, 'resolution')
                res = op.resolution;
            else
                res =res_default;
            end
            if isfield(op, 'Ndatapoints')
                Ndatapoints = op.Ndatapoints;
            else
                Ndatapoints =Np_default;
            end
            if isfield(op, 'domainsize')
                domainsize = op.domainsize;
            else
                domainsize = domainsize_default;
            end
            if isfield(op, 'gaussianwidth')
                gaussianwidth = op.gaussianwidth;
            else
                gaussianwidth = gaussianwidth_default;
            end
            definput = {num2str(res), num2str(Ndatapoints), ...
                num2str(domainsize), num2str(gaussianwidth)};
        end
        
        if contains(get(gcbo, 'tag'), '_Proc2')
            prompt = {'Resolution for auto-peak finding', ...
                'Data points for each peak', 'domain size', 'gaussian width'};
        else
            prompt = {'Resolution for auto-peak finding', ...
                'Data points for each peak'};
            definput = definput(1:2);
        end

        s = inputdlg(prompt, dlgtitle, [1, 60], definput);
        if ~isempty(s)
            op.resolution = str2double(s{1});
            op.Ndatapoints = str2double(s{2});
            if numel(s)>2
                op.domainsize = str2double(s{3});
                op.gaussianwidth = str2double(s{4});
            end
            setappdata(gcbf, 'peakfitoption', op);
        end
    end


    function fit_option(varargin)
        prompt = {'Peak center shift allowance. -1 for as much as peak width', ...
            'Maximum Iteration for Fitting'};
        dlgtitle = 'Fit Parameters';
        op = getappdata(gcbf, 'peakfitoption');
        dq_default = 0.01;
        itr_default = 200;
        if isempty(op)
            definput = {num2str(dq_default), num2str(itr_default)}; 
        else
            if isfield(op, 'delta_q')
                dq = op.delta_q;
            else
                dq =dq_default;
            end
            if isfield(op, 'Niterations')
                Niterations = op.Niterations;
            else
                Niterations =itr_default;
            end
            definput = {num2str(dq), num2str(Niterations)};
        end
        s = inputdlg(prompt, dlgtitle, [1, 60], definput);
        if ~isempty(s)
            op.delta_q = str2double(s{1});
            op.Niterations = str2double(s{2});
            setappdata(gcbf, 'peakfitoption', op);
        end
        %peak=fpeak(xd(:),yd(:),str2double(s{1}),[xl, yl]);
    end

    function setfindpeaksauto(varargin)
%         if strcmp(get(gcbo, 'checked'), 'on')
%             setfindpeaks(varargin{1})
%             set(gcbo, 'checked', 'off');
%         else
            hA1 = findobj(gcbf, 'tag', 'IqAxes');
            hl = findobj(hA1, 'tag', 'rawdata');
            xd = get(hl, 'xdata');
            yd = get(hl, 'ydata');
            xl = get(hA1, 'xlim');
            yl = get(hA1, 'ylim');
            op = getappdata(gcbf, 'peakfitoption');
            if isempty(op)
                s = inputdlg('Sensitivity to find peaks','Resolution', 1, {'20'});
                res = str2double(s{1});
                op.resolution = str2double(s{1});
                setappdata(gcbf, 'peakfitoption', op);
            else
                res = op.resolution;
            end
            
            peak=fpeak(xd(:),yd(:),res,[xl, yl]);
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
%             set(gcbo, 'checked', 'on');
            set(hA1, 'buttondownfcn', @setbtndwnfcn)
            setappdata(gcf, 'FitMode', 'manual')
%         end
    end

    function reset_btn_function(varargin)
        state = get(gcf, 'userdata');
        uirestore(state);
        set(gcf,'Pointer','arrow');
        hA1 = findobj(gcbf, 'tag', 'IqAxes');
        set(hA1, 'buttondownfcn', '');
        hA2 = findobj(gcbf, 'tag', 'PeakAxes');
        set(hA2, 'buttondownfcn', '');
        set(gcf, 'WindowButtonMotionFcn','');
        h = findobj(gcf, 'type', 'uimenu', '-and', 'Checked', 'on');
        set(h, 'Checked', 'off');
    end

    function setpeaksParam(varargin)
        obj = varargin{1};
%         if strcmp(get(obj, 'tag'), 'SSL_MenuSetPeakParam')
%             % manual peak selection is chosen.
%             setappdata(gcf, 'FitMode', 'manual')
%         end
        if strcmp(get(obj, 'checked'), 'on')
            set(gcbo, 'checked', 'off');
            state = get(gcf, 'userdata');
            uirestore(state);
            set(gcf,'Pointer','arrow');
            hA1 = findobj(gcbf, 'tag', 'IqAxes');
            set(hA1, 'buttondownfcn', '');
            hA2 = findobj(gcbf, 'tag', 'PeakAxes');
            set(hA2, 'buttondownfcn', '');
            set(gcf, 'WindowButtonMotionFcn','');
        else
            state = uisuspend(gcf);
            set(gcf, 'userdata', state);
            set(gcbo, 'checked', 'on');
            set(gcf,'Pointer','crosshair');
            hA1 = findobj(gcbf, 'tag', 'IqAxes');
            set(hA1, 'buttondownfcn', @btndownfn_A1)
            set (gcf, 'WindowButtonMotionFcn', @btnmove_A1);
            hA2 = findobj(gcbf, 'tag', 'PeakAxes');
            set(hA2, 'buttondownfcn', @btndownfn_A2)
        end
    end
    function setpeakparameter(varargin)
        if strcmp(get(gcbo, 'checked'), 'on')
            setpeaksParam(varargin{1})
            set(gcbo, 'checked', 'off');
        else
            setpeaksParam(varargin{1})
            set(gcbo, 'checked', 'on');
        end
    end
    function add_new_peak(varargin)
        if strcmp(get(gcbo, 'checked'), 'on')
            set(gcbo, 'checked', 'off');
            state = get(gcf, 'userdata');
            uirestore(state);
            set(gcf,'Pointer','arrow');
            hA1 = findobj(gcbf, 'tag', 'IqAxes');
            set(hA1, 'buttondownfcn', '');
        else
            state = uisuspend(gcf);
            set(gcf, 'userdata', state);
            set(gcbo, 'checked', 'on');
            set(gcf,'Pointer','crosshair');
            hA1 = findobj(gcbf, 'tag', 'IqAxes');
            set(hA1, 'buttondownfcn', @btndown_addapeak)
        end
    end

    function btndown_addapeak(varargin)
        % get mouse position
        st = get(gcbf, 'Selectiontype');
        pt = get(gca, 'CurrentPoint');
        yl = get(gca, 'ylim');
        xInd = (pt(1, 1));
        yInd = (pt(1, 2));
        switch st
            case 'normal'
                h = line(gca, [xInd, xInd], [1E-10, yInd], 'color', 'r');
                set(h, 'tag', 'foundpeaks');
                set(h, 'userdata', xInd);
                ch = generatebackground(h);
                drawVoigtPeaks(ch{1});
            case 'alt'
                h = findobj(gca, 'tag', 'foundpeaks');
                a = get(h, 'userdata');
                if numel(h) > 1
                    m = cell2mat(cellfun(@(x) x(1), a, 'Uniformoutput', false));
                    [~, ind] = min(abs(m-xInd));
                elseif numel(h) == 1
                    ind = 1;
                else
                    ind = [];
                end
                ch = getappdata(h(ind), 'childrenhandle');
                if ~isempty(ch)
                    cch2 = getappdata(ch, 'sim_Iq_handleA2');
                    cch1 = getappdata(ch, 'sim_Iq_handleA1');
                    delete(ch);
                    delete(cch2);
                    delete(cch1);
                end
                delete(h(ind))
        end
        set(gca, 'ylim', yl);

    end
    function setbtndwnfcn(varargin)
        % get mouse position
        st = get(gcbf, 'Selectiontype');
        pt = get(gca, 'CurrentPoint');
        yl = get(gca, 'ylim');
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
        set(gca, 'ylim', yl);

    end



function drawGaussianPeaks(varargin)
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    hA2 = findobj(gcbf, 'tag', 'PeakAxes');
    delete(findobj(hA1, 'tag', 'sim_gauss_peak'));
    delete(findobj(hA1, 'tag', 'sim_Iq'));
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
        setappdata(hss, 'myindex', i);
        setappdata(h(i), 'sim_Iq_handleA2', hss);
        set(hss, 'userdata', [yd, ud(1), wd/5, P]);
    end
end

function drawVoigtPeaks(varargin)
    if contains(get(gcbo, 'tag'), '_Proc2')
        setappdata(gcbf, 'fitoption', 'proc2')
    else
        setappdata(gcbf, 'fitoption', 'proc1')
    end
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    hA2 = findobj(gcbf, 'tag', 'PeakAxes');
    if numel(varargin) == 0 || numel(varargin) == 2
        delete(findobj(hA1, 'tag', 'sim_Iq'));
        delete(findobj(hA2, 'tag', 'sim_Iq'));
        h = findobj(hA2, 'tag', 'backsubdata');
    else
        h = varargin{1};
    end
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
        meanFWHM = 1E-4; % set it default....
%         m = cell2mat(cellfun(@(x) x(1), peakp, 'Uniformoutput', false));
%         meanFWHM = abs(min(diff(m)))/2;
    end
    for i=1:numel(h)
        ud = peakp{i};
        P = getappdata(h(i), 'back');
        %ht = getappdata(h(i), 'foundpeak_handle');
        xd = get(h(i), 'Xdata');
        yd = get(h(i), 'Ydata');
        [~, indx] = min(abs(xd-ud(1)));
        myd = yd(indx);
        if numel(ud)>1
            wd = abs(ud(3)-ud(2));
        else
            wd = meanFWHM;
        end
        area = myd*wd;
        if iscell(q)
            qv = q{i};
        else
            qv = q;
        end
        yline = pseudovoigt(qv(:), [area, ud(1), wd/5, wd/5, 0]) + P(1)*qv(:)+P(2);
%        yline = voigt(q{i}(:), [yd, ud(1), wd/5, wd/5, 0]) + P(1)*q{i}(:)+P(2);
        %Iq = Iq + yline;
        hl = line(hA1, 'xdata', qv, 'ydata', yline);
        set(hl, 'tag', 'sim_Iq');
        setappdata(hl, 'myindex', i);
        set(hl, 'userdata', [area, ud(1), wd/5, wd/5, P]);
        hss = line(hA2, 'xdata', qv, 'ydata', yline);
        set(hss, 'tag', 'sim_Iq');
        setappdata(hss, 'myindex', i);
        setappdata(h(i), 'sim_Iq_handleA2', hss);
        setappdata(h(i), 'sim_Iq_handleA1', hl);
        set(hss, 'userdata', [area, ud(1), wd/5, wd/5, P]);
        setappdata(hl, 'pairhandle', hss);
        setappdata(hss, 'pairhandle', hl);
        setappdata(hl, 'parenthandle', h(i));
        setappdata(hss, 'parenthandle', h(i));
    end
    %h = line(hA2, 'xdata', q', 'ydata', Iq);
    %set(h, 'tag', 'sim_Iq');
end

    function btndownfn_backsubdata(varargin)
        if ~strcmp(get(gca, 'tag'), 'PeakAxes')
            return
        end
        st = get(gcbf, 'Selectiontype');
        pt = get(gca, 'CurrentPoint');
        xInd = (pt(1, 1));
        yInd = (pt(1, 2));
        switch st
            case 'normal'
                h = findobj(gca, 'tag', 'backsubdata');
                a = get(h, 'userdata');
                a = cell2mat(a);
                [~, ind] = min(abs(a-xInd));
                ud = get(h(ind), 'userdata');
                set(h(ind), 'linestyle', '--', 'linewidth', 2);
                
            case 'alt'
                h = findobj(gca, 'tag', 'backsubdata', '-and', 'linestyle', '--');
                if isempty(h)
                    fprintf('No one was selected.\n')
                    return
                end
                xd = get(h, 'xdata');
                yd = get(h, 'ydata');
                ud = get(h, 'userdata');
                if xInd < ud(1)
                    t = xd < xInd;
                else
                    t = xd > xInd;
                end
                xd(t) = [];
                yd(t) = [];
                set(h, 'xdata', xd);
                set(h, 'ydata', yd);
                set(h, 'linestyle', '-', 'linewidth', 0.5);
        end
    end

    function btndownfn_A1(varargin)
        if ~strcmp(get(gca, 'tag'), 'IqAxes')
            return
        end
        st = get(gcbf, 'Selectiontype');
        pt = get(gca, 'CurrentPoint');
        xInd = (pt(1, 1));
        yInd = (pt(1, 2));
        switch st
            case 'normal'
                h = findobj(gca, 'tag', 'sim_Iq');
                a = get(h, 'userdata');
                a = cell2mat(a);
                [~, ind] = min(abs(a(:,2)-xInd));
                ud = get(h(ind), 'userdata');
                set(h(ind), 'linestyle', '--');
                
            case 'alt'
                h = findobj(gca, 'tag', 'sim_Iq', '-and', 'linestyle', '--');
                if isempty(h)
                    fprintf('No one was selected.\n')
                    return
                end
                set(h, 'linestyle', '-');
                a = get(h, 'userdata');
                fprintf('Area = %0.3f, wd = %0.4f\n', a(1), a(3));
                ht = getappdata(h, 'pairhandle');
                     m = get(ht, 'userdata');
                    m(3) = a(3);
                    m(4) = a(4);               
           
                        fwhm = voigtfwhm(m(3), m(4));
                        op = getappdata(gcbf, 'peakfitoption');
                        op.domainsize = 2*pi/fwhm;
                        setappdata(gcbf, 'peakfitoption', op);
                    xd = get(ht, 'xdata');
                    yd = get(ht, 'ydata');
                    
                    %area = a(1); %max(yd)*m(3)*5/2;
                    area = max(yd)*fwhm;
                    fprintf('center = %0.3f, area=%0.3f, peakmax=%0.3f\n', m(2), area, max(yd));
                    yline = pseudovoigt(xd(:), [area, m(2:4), 0]) + m(5)*xd(:)+m(6);
                    set(ht, 'ydata', yline);
                    set(ht, 'userdata', m);     
                    
%                 hA2 = findobj(gcbf, 'tag', 'PeakAxes');
%                 h = findobj(hA2, 'tag', 'backsubdata');                for i=1:numel(h)
%                     ht = getappdata(h(i), 'sim_Iq_handleA2');
%                     m = get(ht, 'userdata');
%                     m(3) = a(3);
%                     m(4) = a(4);
%                     if i==1
%                         fwhm = voigtfwhm(m(3), m(4));
%                         op = getappdata(gcbf, 'peakfitoption');
%                         op.domainsize = 2*pi/fwhm;
%                         setappdata(gcbf, 'peakfitoption', op);
%                     end
%                     xd = get(h(i), 'xdata');
%                     yd = get(h(i), 'ydata');
%                     
%                     %area = a(1); %max(yd)*m(3)*5/2;
%                     area = max(yd)*fwhm;
%                     fprintf('center = %0.3f, area=%0.3f, peakmax=%0.3f\n', m(2), area, max(yd));
%                     yline = pseudovoigt(xd(:), [area, m(2:4), 0]) + m(5)*xd(:)+m(6);
%                     %a(1) = area;
%                     m(1) = area;
%                     set(ht, 'userdata', m);
%                     set(ht, 'ydata', yline);
%                     ht = getappdata(ht, 'pairhandle');
%                     set(ht, 'ydata', yline);
%                     set(h(i), 'userdata', m);
%                 end
        end
    end

    function btnmove_A1(varargin)
        if ~strcmp(get(gca, 'tag'), 'IqAxes')
            return
        end
        st = get(gcbf, 'Selectiontype');
        pt = get(gca, 'CurrentPoint');
        xInd = (pt(1, 1));
        yInd = (pt(1, 2));
        h = findobj(gca, 'tag', 'sim_Iq', '-and', 'linestyle', '--');
        if isempty(h)
            return
        end
        if numel(h) > 1
            set(h, 'linestyle', '-');
            return
        end
        a = get(h, 'userdata');
        
        xd = get(h, 'xdata');
        yd = get(getappdata(h, 'parenthandle'), 'ydata');
        wd = abs(xInd-a(2));
        op = getappdata(gcbf, 'peakfitoption');
        if isfield(op, 'gaussianwidth')
            gw = op.gaussianwidth;
        else
            gw = wd/2;
        end
        fwhm = voigtfwhm(gw, wd/4);
        area = max(yd)*fwhm;
        fprintf('xId = %0.3f, peak width is %0.3e, Area is %0.3f.\n', xInd, wd, area)
        yline = pseudovoigt(xd(:), [area, a(2), gw, wd/4, 0]) + a(5)*xd(:)+a(6);
        set(h, 'ydata', yline);
        set(h, 'userdata', [area, a(2), gw, wd/4, a(5:6)]);

    end
    function btndownfn_A2(varargin)
        % get mouse position
        if ~strcmp(get(gca, 'tag'), 'PeakAxes')
            return
        end
        st = get(gcbf, 'Selectiontype');
        pt = get(gca, 'CurrentPoint');
        xInd = (pt(1, 1));
        yInd = (pt(1, 2));
        switch st
            case 'normal'
                h = findobj(gca, 'tag', 'sim_Iq');
                a = get(h, 'userdata');
                a = cell2mat(a);
                [~, ind] = min(abs(a(:,2)-xInd));
%                 if numel(h) > 1
%                     %m = cell2mat(get(h, 'userdata'));
%                     m = cell2mat(cellfun(@(x) x(1), a(:,2), 'Uniformoutput', false));
%                     [~, ind] = min(abs(m-xInd));
%                 elseif numel(h) == 1
%                     ind = 1;
%                 else
%                     ind = [];
%                 end
                ud = get(h(ind), 'userdata');
                set(h(ind), 'linestyle', '--');
%             case 'extend'
%                 h = line(gca, [xInd, xInd], [1E-10, yInd], 'color', 'r');
%                 set(h, 'tag', 'foundpeaks');
%                 set(h, 'userdata', xInd);
                
            case 'alt'
                h = findobj(gca, 'tag', 'sim_Iq', '-and', 'linestyle', '--');
                set(h, 'linestyle', '-');
                if numel(h) < 2
                    return
                end
                for i=1:numel(h)
                    g = getappdata(h(i), 'parenthandle');
                    setappdata(h(i), 'coupleindex', coupleindex);
                    setappdata(g, 'coupleindex', coupleindex);
                end
                coupleindex = coupleindex + 1;
                fprintf('%i peaks are coupled for fitting.\n', numel(h));
        end
    end

function out = generatebackground(varargin)
    Np_default = 25;
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    hA2 = findobj(gcbf, 'tag', 'PeakAxes');
    if numel(varargin) == 2
        delete(findobj(hA1, 'tag', 'sim_back'));
        delete(findobj(hA2, 'tag', 'backsubdata'));
        h = findobj(hA1, 'tag', 'foundpeaks');
    elseif numel(varargin) == 1
        h = varargin{1};
    end
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
    out = [];
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
%             fprintf('Determine lower and upper boundaries for at least a peak by shift left clicks with SET PEAKS mode.\n');
%             return
            Np = [];
            op = getappdata(gcbf, 'peakfitoption');
            if isempty(op)
                Np = Np_default;
            else
                if isfield(op, 'Ndatapoints')
                    Np = op.Ndatapoints;
                end
            end
            if isempty(Np)
                Np = Np_default;
            end
            fprintf('Default number of peak points %i is used.\n', Np);
            wd = [];
        end
        if ~isempty(wd)
            wd = abs(wd/1.5);
            tl = (q > ud(1)-wd);
            tr = (q < ud(1)+wd);
            t = tl&tr;
        else
            [~, iqp] = min(abs(q-ud(1)));
            tl = q > q(iqp-fix((op.Ndatapoints-1)/2));
            tr = q < q(iqp+fix((op.Ndatapoints-1)/2));
            t = tl&tr;
            ispeakwidthdefined = 1;
        end
        if ~ispeakwidthdefined
            qs = q(t);
            ys = y(t);
%             P = polyfit([qs(1), qs(end)],[ys(1), ys(end)],1);
            [P, x1, x2] = optimum_background(qs, ys);
            qs = qs(x1:x2);
            ys = ys(x1:x2);
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
        %P = polyfit([qss(1), qss(end)],[yss(1), yss(end)],1);
        [P, x1, x2] = optimum_background(qss, yss);
        qss = qss(x1:x2);
        yss = yss(x1:x2);
        hp = line(hA2, 'xdata', qss, 'ydata', yss, 'color', 'r');
        set(hp, 'tag', 'backsubdata');
        setappdata(h(i), 'childrenhandle', hp);
        setappdata(hp, 'foundpeak_handle', h(i));
        setappdata(hp, 'back', P);
        set(hp, 'userdata', ud);
        out{i} = hp;
    end
    fprintf('%i peaks are selected.\n', numel(h));
    fprintf('In order to group them to fit, set "peak2fitgroup" array. For example, \n');
    fprintf('When there is 5 peaks, of which you like to group 1 and 2 together and 4 and 5 together:\n');
    fprintf(', and you do not want to fit the third one:\n');
    fprintf('peak2fitgroup = [1, 1, 0, 4, 4]\n');
    if numel(varargin) == 0
        set(hA2, 'buttondownfcn', @btndownfn_backsubdata);
    end
%    drawVoigtPeaks
end
    function [P, x1min, x2min] = optimum_background(xd, yd)
        Nx = numel(xd);
        N1 = fix(Nx/2)-3;
        if N1 <= 1
            N1 = 1;
        end
        N2 = fix(Nx/2)+3;
        if N2 >= Nx
            N2 = Nx;
        end
        [~, x1min] = min(yd(1:N1));
        [~, x2min] = min(yd(N2:end));
        x2min = N2+x2min-1;
        P = polyfit_area(xd(x1min), xd(x2min), yd(x1min), yd(x2min));
    end

    function P = optimum_background_old(xd, yd)
        A = inf;
        ind2 = numel(xd);
        for ind1=1:(fix(numel(xd)/2)-1)
            [P, An] = polyfit_area(xd(ind1), xd(ind2), yd(ind1), yd(ind2));
            if An > A
                ind1 = ind1 - 1;
                break
            else
                A = An;
            end
        end
        for ind2=numel(xd):-1:(fix(numel(xd)/2)+1)
            [P, An] = polyfit_area(xd(ind1), xd(ind2), yd(ind1), yd(ind2));
            if An > A
                ind2 = ind2 + 1;
                break
            else
                A = An;
            end
        end
        P = polyfit_area(xd(ind1), xd(ind2), yd(ind1), yd(ind2));
    end

    function [P, A] = polyfit_area(x1, x2, y1, y2)
        P = polyfit([x1, x2],[y1, y2],1);
        A = P(1)*(x2.^2 - x1^2)/2+P(2)*(x2-x1);
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
    hIq0 = getappdata(h(i), 'sim_Iq_handleA2');
    ud0 = get(hIq0, 'userdata');
    hIq = getappdata(h(k), 'sim_Iq_handleA2');
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
        hIq = getappdata(h(k), 'sim_Iq_handleA2');
        ud = get(hIq, 'userdata');
    end
        
end        
            

function fitPeaks(varargin)
    delete(findobj(gcf, 'tag', 'Temporary_fitline'));
    reset_btn_function
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
    peakshape = 'vfit';
    ht = [];
    for i=1:numel(h)
        htt = getappdata(h(i), 'sim_Iq_handleA2');
        ht = [ht;i, get(htt, 'userdata')];
    end
    [~, ind] = sort(ht(:,3));
%    h = flip(h); % handle h is read from high number to low.
    h = h(ind); % h is sorted by the peak center value.
    ht = ht(ind, :);
    

    % if the axis is zoomm in, then only peak in the zoom will be used.
    t = (ht(:, 3) < xl(1)) | (ht(:,3) > xl(2));
    h(t) = [];
    ht(t,:) = [];

% delta q for UB and LB
%     peakpositiondiff = abs(diff(ht(:,3)));
%     peakpositiondiff(peakpositiondiff <= 0) = [];
%     min_delta_peak = min(peakpositiondiff);
    op = getappdata(gcbf, 'peakfitoption');
    dq = inf;
    if ~isempty(op)
        if isfield(op, 'delta_q')
            dq = op.delta_q;
        end
    end

    % check coupled peaks....
    ciindex = zeros(numel(h), 1);
    if isempty(peak2fitgroup)
        for i=1:numel(h)
            ci = getappdata(h(i), 'coupleindex');
            if isempty(ci)
                peak2fitgroup(i) = i;
                ciindex(i) = 0;
            else
                indx = find(ciindex == ci);
                if ~isempty(indx)
                    peak2fitgroup(i) = indx(1);
                else
                    peak2fitgroup(i) = i;
                end
                ciindex(i) = ci;
            end
        end
    end
    
%    ht = ht(ind, :);
    q = get(h, 'xdata');%q = q(:);
    Iq = get(h, 'ydata');%Iq = Iq(:);

%    min_delta_peak = min([min_delta_peak, dq]);
    
    
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
            hIq = getappdata(h(peak(k)), 'sim_Iq_handleA2');
            hIq2 = getappdata(h(peak(k)), 'sim_Iq_handleA1');
            ud = get(hIq, 'userdata');
            pfit = getappdata(hIq, 'fit');
            
            
            min_delta_peak = abs(hIq.XData(end)-hIq.XData(1))/2;

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
                        if min_delta_peak < 0
                            centerLB = ud(2)-abs(ud(3));
                            centerUB = ud(2)+abs(ud(3));
                        else
                            %xd = hIq.XData;
                            centerLB = ud(2)-abs(min_delta_peak)*2;
                            centerUB = ud(2)+abs(min_delta_peak)*2;
%                             centerLB = ud(2)-abs(min_delta_peak);
%                             centerUB = ud(2)+abs(min_delta_peak);
                        end
                    case 'hkls'
                        centerLB = ud(2);
                        centerUB = ud(2);
                end
                LB = [LB, ud(1)*0.00001, centerLB, abs(ud(3:end-2))*0.0001];
                UB = [UB, ud(1)*100, centerUB, abs(ud(3:end-2))*100];
%            end
            fit.fitlineh(k) = hIq;
%            fit.simlineh(k) = htt(ht(peak(k)), 1);
            fit.simlineh(k) = hIq2;
        end
        

        % Setup options
        op = getappdata(gcbf, 'peakfitoption');
        if ~isempty(op)
            if isfield(op, 'Niterations')
                Nitr = op.Niterations;
            else
                Nitr = 300;
            end
            setappdata(gcbf, 'peakfitoption', op);
        else
            Nitr = 300;
        end

        options = optimset('fminsearch');
        options = optimset(options, 'TolX',0.1E-3);
        options = optimset(options, 'OutputFcn',@outfunPF);
        options = optimset(options, 'MaxIter',Nitr);
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
            tmpline = line(hA2, 'xdata', xv, 'ydata', yv');
            set(tmpline, 'color', 'm')
            set(tmpline, 'tag', 'Temporary_fitline');
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
        dt = [];
        switch peakshape
            case 'gfit'
                INLP = fminsearchcon(@(x) gfit(x, yv, xv, err),NLPstart,LB,UB, A, B, [], options);
                a = [];

                for tmp=1:numel(peak)
                    b = INLP(((tmp-1)*3+1))*INLP(((tmp-1)*3+3))*sqrt(2*pi);
                    a = [a, b];
                    dt = [dt; INLP(((tmp-1)*3+1):(tmp*3)), INLP((numel(peak)*3+1):end)];
                end
            case 'vfit'
                if numel(NLPstart)>8
                    sg1 = min(NLPstart([3,7]));
                    sg2 = min(NLPstart([4,8]));
                    NLPstart(3) = sg1;
                    NLPstart(7) = sg1;
                    NLPstart(8) = sg2;
                    NLPstart(4) = sg2;
%                     %sg1 = min(UB([3,7]));
%                     %sg2 = min(UB([4,8]));
%                     UB(3) = sg1*1.1;
%                     UB(7) = sg1*1.1;
%                     UB(8) = sg2*1.1;
%                     UB(4) = sg2*1.1;
%                     sg1 = min(LB([3,7]));
%                     sg2 = min(LB([4,8]));
%                     LB(3) = sg1*0.9;
%                     LB(7) = sg1*0.9;
%                     LB(8) = sg2*0.9;
%                     LB(4) = sg2*0.9;

                    A = [0, 0, 1, 0, 0, 0, -1, 0, 0, 0;...
                        0, 0, 0, 1, 0, 0, 0, -1, 0, 0];
                    B = [0.00001;0.00001];
%                      A = [0, 0, 0, 1, 0, 0, 0, -1, 0, 0];
%                      B = [0];
                end
                INLP = fminsearchcon(@(x) vfit(x, yv, xv, err),NLPstart,LB,UB, A, B, [], options);
                a = [];
                [~, yl] = vfit(INLP, yv, xv, err);     
                for tmp=1:numel(peak)
                    b = INLP(((tmp-1)*4+1));
                    a = [a, b];
                    dt = [dt; INLP(((tmp-1)*4+1):(tmp*4)), INLP((numel(peak)*4+1):end)];
                end
        end
        if fit.NdataSet > 1
            set(tmpline, 'ydata', yl);
        else
            dt = INLP;
        end
        
        % The result is saved back to 'userdata' in outfunPF function
        for k=1:numel(peak)
            hIq = getappdata(h(peak(k)), 'sim_Iq_handleA2');
            if fit.NdataSet == 1
                setappdata(hIq, 'fit', dt); % this line is no need.
            else
                setappdata(hIq, 'fit', dt); % this line is no need.
%                setappdata(hIq, 'fit', dt(i, :)); % this line is no need.
            end
        end
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
    htt = findobj(hA1, 'tag', 'sim_Iq');
    peakshape = 'vfit';
    %fitFunHandle =  str2func(peakshape);
    refit = 0;
    p = [];UB = [];LB = [];
    for i=1:numel(h)
        hIq = getappdata(h(i), 'sim_Iq_handleA2');
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
    delete(findobj(hA1, 'tag', 'sim_Iq'));
    delete(findobj(hA1, 'tag', 'sim_back'));
    delete(findobj(hA2, 'tag', 'sim_Iq'));
    delete(findobj(hA2, 'tag', 'backsubdata'));
    init_parameters
    %delete(findobj(hA1, 'tag', 'foundpeaks'));
end
end
    
    
