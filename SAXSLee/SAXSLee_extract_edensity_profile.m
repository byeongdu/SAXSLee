function SAXSLee_extract_edensity_profile(varargin)
% For simple object such as spherical, cylinderical or lamella stures,
% it may be possible to obtain excess electron density profile along
% radial, cross sectional and normal to the plane directions, respectively.
% This program is to convert I(q) to A(q) and finally to get rho(r),
% where users may arbitrary decide phase of amplitudes.
% Look at also Lipid.m

warning off
verNumber = '1.0';
init
hSL = gcbf;
if isempty(hSL)
    hSL = gcf;
end
hSLaxes = findobj(hSL, 'type', 'axes');

function init
f = figure;
%set(f, 'MenuBar', 'none');
%tbh = uitoolbar(f);
%set(f, 'uitoggletool', 'on');
set(f, 'Tag', 'Extract_Edensity_Profile')
set(f, 'Name', 'Electron Density');

hMenubar = findall(gcf,'tag','figMenuFile');
set(findall(hMenubar), 'visible', 'off')
hMenubar = findall(gcf,'tag','figMenuView');
set(findall(hMenubar), 'visible', 'off')
hMenubar = findall(gcf,'tag','figMenuEdit');
set(findall(hMenubar), 'visible', 'off')
hMenubar = findall(gcf,'tag','figMenuHelp');
set(findall(hMenubar), 'visible', 'off')
%get(findall(hMenubar),'tag')
hToolbar = findall(gcf,'tag','FigureToolBar');
set(hToolbar, 'visible', 'off');
%% Menu
hMenuFile = uimenu(f,...
    'Label','&File',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFile');
hMenuFileOpen = uimenu(hMenuFile,...
    'Label','&Load Data...',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileOpen',...
    'Accelerator','L',...
    'callback',@loaddata);
hMenuFileSave = uimenu(hMenuFile,...
    'Label','&Save Result...',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFileSave',...
    'Accelerator','S',...
    'callback',@saveResults);
hMenuProc = uimenu(f,...
    'Label','&Process',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuProc');
hMenuBackDraw = uimenu(hMenuProc,...
    'Label','&Draw Background on SAXSLee...',...
    'Position',1,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuDrawBack',...
    'Accelerator','L',...
    'callback',@drawback);
hMenuSubtractBack = uimenu(hMenuProc,...
    'Label','&Import and Subtract Background...',...
    'Position',2,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuSubtractBack',...
    'Accelerator','-',...
    'callback',@subtractback);
hMenuFindMinima = uimenu(hMenuProc,...
    'Label','&Find Minima...',...
    'Position',3,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFindMinima',...
    'Accelerator','F',...
    'callback',@findminima);
hMenuLorCor1 = uimenu(hMenuProc,...
    'Label','&Lorentz Correction for Lamella/Cylinder...',...
    'Position',4,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuLC1',...
    'callback',@lorentzcorrection);
hMenuCalAq = uimenu(hMenuProc,...
    'Label','&Calculate A(q)...',...
    'Position',5,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuCalAq',...
    'callback',@CalAq);
hMenuFlipAq = uimenu(hMenuProc,...
    'Label','&Flip A(q)...',...
    'Position',6,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFlipAq',...
    'Accelerator','A',...
    'callback',@flipAq);
hMenuFT = uimenu(hMenuProc,...
    'Label','&Fourier Transfrom...',...
    'Position',7,...
    'HandleVisibility','callback',...
    'Tag','SSL_MenuFT',...
    'callback',@Aq2eden);
%% Graph
hA1 = subplot(3, 1, 1);
hA2 = subplot(3, 1, 2);
hA3 = subplot(3, 1, 3);

set(hA1, 'box', 'on', 'tag', 'IqAxes');
set(hA2, 'box', 'on', 'tag', 'AqAxes');
set(hA3, 'box', 'on', 'tag', 'rhoAxes');
end
%% functions
function loaddata(varargin)
    hL = findobj(hSLaxes, 'type', 'line', '-xor', '-regexp', 'tag', 'BACK');
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    delete(findobj(hA1, 'tag', 'rawdata'));
    xd = get(hL, 'xdata');
    yd = get(hL, 'ydata');
    if iscell(xd)
        tag = get(hL, 'tag');
        [indx,tf] = listdlg('PromptString',{'Select a data.',''},...
    'SelectionMode','single','ListString',tag);
        if isempty(indx)
            return
        end
        xd = xd{indx};
        yd = yd{indx};
    end
    hNL = line(hA1, xd, yd, 'tag', 'rawdata');
    set(hA1, 'xscale', 'log');
    set(hA1, 'yscale', 'log');
    xlabel(hA1, sprintf('q (1/%c)', char(197)), 'fontsize', 14);
    ylabel(hA1, sprintf('I(q) (a.u.)'), 'fontsize', 14);
end

function saveResults(varargin)
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    hback = findobj(hA1, 'tag', 'back', 'color', 'r');
    hrawdata = findobj(hA1, 'tag', 'rawdata');
    hdata = findobj(hA1, 'tag', 'data');
    hA2 = findobj(gcbf, 'tag', 'AqAxes');
    hAq = findobj(hA2, 'tag', 'Aq');
    hA3 = findobj(gcbf, 'tag', 'rhoAxes');
    hrho = findobj(hA3, 'tag', 'rhoprofile');
    q = get(hrawdata, 'xdata');q = q(:);
    Iq = get(hrawdata, 'ydata');Iq = Iq(:);
    data_lab = {'Raw_Data', 'Back', 'Background_Subtracted_Data', 'A(q)'};
    data_lab_sel = [1, 1, 1, 1];
    Iq = [q, Iq];
    if isempty(hback)
        back = [];
        data_lab_sel(2) = 0;
    else
        t = get(hback, 'ydata');
        back = t(:);
    end
    Iq = [Iq, back];
    if isempty(hdata)
        data = [];
        data_lab_sel(3) = 0;
    else
        t = get(hdata, 'ydata');
        data = t(:);
    end
    Iq = [Iq, data];
    if isempty(hAq)
        Aq = [];
        data_lab_sel(4) = 0;
    else
        t = get(hAq, 'ydata');
        Aq = t(:);
    end
    Iq = [Iq, Aq];
    if isempty(hrho)
        rho = [];
    else
        t = get(hAq, 'xdata');
        x = t(:);
        t = get(hAq, 'ydata');
        rho = t(:);
    end
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
    fn = fullfile(pathname, ['Data_', filename]);
    str = '%';
    for i=1:numel(data_lab)
        if data_lab_sel(i)
            str = sprintf('%s %s', str, data_lab{i});
        end
    end
    fid = fopen(fn, 'w');
    fwrite(fid, str);
    fprintf(fid, '\n');
    fclose(fid);
    dlmwrite(fn, Iq, '-append');
    fn = fullfile(pathname, ['rho_', filename]);
    fid = fopen(fn, 'w');
    fwrite(fid, '% x rho(x)');
    fprintf(fid, '\n');
    fclose(fid);
    dlmwrite(fn, [x, rho], '-append');
end

function drawback(varargin)
    drawContinousBack('start')
end

function subtractback(varargin)
    hback = findobj(hSLaxes, '-regexp', 'tag', 'BACK');
    xd = get(hback, 'xdata');
    yd = get(hback, 'ydata');
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    hback = findobj(hA1, 'tag', 'back', 'color', 'r');
    delete(hback);
    hNLback = line(hA1, xd, yd, 'tag', 'back', 'color', 'r');
    set(hA1, 'xscale', 'log');
    set(hA1, 'yscale', 'log');
    
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    %hback = findobj(hA1, 'tag', 'back', 'color', 'r');
    Hdata = findobj(hA1, 'tag', 'rawdata');
    xdata = get(Hdata, 'xdata');xdata = xdata(:);
    ydata = get(Hdata, 'ydata');ydata = ydata(:);
    %bkg = get(hback, 'ydata');bkg = bkg(:);
%     Hbkg.bkg = [xdata, bkg];
%     Hbkg.Hdata = Hdata;
    ydata = ydata(:)-yd(:);
    k = ydata <= 0;
    ydata(k) = abs(eps);
    delete(findobj(hA1, 'tag', 'data'));
    hNLbacksub = line(hA1, xdata, ydata, 'tag', 'data', 'color', 'k');
end

function findminima(varargin)
    val = dialog_box('minima');
    pos = ginput(val);
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    set(hA1, 'userdata', pos);
    CalAq
end

function CalAq(varargin)
    hA1 = findobj(gcbf, 'tag', 'IqAxes');
    hdata = findobj(hA1, 'type', 'line', 'tag', 'data');
    if isempty(hdata)
        hdata = findobj(hA1, 'type', 'line', 'tag', 'rawdata');
    end
    if isempty(hdata)
        fprintf('No data selected, yet.\n')
        return
    end
    xdata = get(hdata, 'xdata');xdata = xdata(:);
    ydata = get(hdata, 'ydata');ydata = ydata(:);
    
    posm = get(hA1, 'userdata');
    if isempty(posm)
        fprintf('Select A(q) minima before proceeding to calculate A(q).\n');
        return
    end
    posm = posm(:,1);
    Aq = lipidformGen(xdata, ydata, posm, 1);
    hA2 = findobj(gcbf, 'tag', 'AqAxes');
    delete(findobj(hA2, 'tag', 'Aq'));
    h = line(hA2, xdata, Aq, 'tag', 'Aq');
    set(hA2, 'xscale', 'linear', 'yscale', 'linear')
    xlabel(hA2, sprintf('q (1/%c)', char(197)), 'fontsize', 14);
    ylabel(hA2, sprintf('A(q) (a.u.)'), 'fontsize', 14);
end

function lorentzcorrection(varargin)
    hA2 = findobj(gcbf, 'tag', 'AqAxes');
    h = findobj(hA2, 'tag', 'Aq');
    if isempty(h)
        fprintf('A(q) is not available yet. Calculate A(q) first!!!!\n');
        return
    end
    xdd = get(h, 'xdata');
    ydd = get(h, 'ydata');
    set(h, 'ydata', ydd.*xdd.^2);
end

function flipAq(varargin)
    hA2 = findobj(gcbf, 'tag', 'AqAxes');
    h = findobj(hA2, 'tag', 'Aq');
    if isempty(h)
        fprintf('A(q) is not available yet.\n');
        return
    end
    xdd = get(h, 'xdata');
    ydd = get(h, 'ydata');
    set(h, 'ydata', -ydd);
    hA3 = findobj(gcbf, 'tag', 'rhoAxes');
    hrho = findobj(hA3, 'tag', 'rhoprofile');
    if ~isempty(hrho)
        y = get(hrho, 'ydata');
        set(hrho, 'ydata', -y);
    end
end
function Aq2eden(varargin)
    x = dialog_box('x');
    dim = dialog_box('dim');
    hA2 = findobj(gcbf, 'tag', 'AqAxes');
    hA3 = findobj(gcbf, 'tag', 'rhoAxes');
    h = findobj(hA2, 'tag', 'Aq');
    if isempty(h)
        fprintf('A(q) is not available yet.\n');
        return
    end
    q = get(h, 'xdata');
    Aq = get(h, 'ydata');
    switch dim
        case 2
            y = fourier_cos(x, q, Aq, 'i');
        case {0, 1}
            y = fourier_sym_trans(q, Aq, x, dim);
    end
    delete(findobj(hA3, 'type', 'line'));
    t = line(hA3, x, y, 'tag', 'rhoprofile', 'color', 'k');
    line(hA3, x, zeros(size(x)), 'tag', 'ref', 'linestyle', '--');
    set(hA3, 'userdata', x);
    xlabel(hA3, sprintf('r (%c)', char(197)), 'fontsize', 14);
    ylabel(hA3, '\rho (a.u.)', 'fontsize', 14);
    
end
function val = dialog_box(mode)
    switch mode
        case 'minima'
            str1 = 'How many A(q) minima?';
            str2 = 'Number of minima:';
            str3 = '3';
            style2 = 'edit';
        case 'x'
            str1 = 'Real Space Range';
            str2 = sprintf('x(%c) =', char(197));
            str3 = '0:1:200';
            style2 = 'edit';
        case 'dim'
            str1 = 'Dimension of Object';
            str2 = 'Shape of Object: ';
            str3 = {'Sphere', 'Cylinder', 'Lamella'};
            style2 = 'popup';
    end
    d = dialog('Position',[300 300 250 150],'Name',str1);
    txt = uicontrol('Parent',d,...
           'Style','text',...
           'Position',[20 80 210 40],...
           'String',str2);

    ed = uicontrol('Parent',d,...
           'tag', 'return',...
           'Style',style2,...
           'Position',[75 70 100 25],...
           'String',str3);
    btn = uicontrol('Parent',d,...
           'Position',[89 20 70 25],...
           'String','Close',...
           'Callback',@popup_callback);

    % Wait for d to close before running to completion
    uiwait(d);
       function popup_callback(varargin)
           edb = findobj(gcbf, 'tag', 'return');
           switch get(edb, 'style')
               case 'edit'
                    val = eval(get(edb, 'string'));
               case 'popupmenu'
                  idx = edb.Value;
                  popup_items = edb.String;
                  shape = char(popup_items(idx,:));
                  switch lower(shape)
                      case 'sphere'
                          val = 0;
                      case 'cylinder'
                          val = 1;
                      case 'lamella'
                          val = 2;
                  end
           end
           delete(gcbf);
       end
end
end
    
    
