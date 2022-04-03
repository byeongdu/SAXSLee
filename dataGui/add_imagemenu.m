function add_imagemenu(varargin)
if ~isempty(varargin)
    f = uimenu(varargin{1}, 'Label','Image');
else
    f = uimenu('Label', 'Image');
end
flg = uimenu(f,'Label','Log Scale','Callback',@makelogimage);
fli = uimenu(f,'Label','Linear Scale','Callback',@makelinimage);
uimenu(f,'Label','Change Min-Max','Callback',@changescale);
uimenu(f,'Label','Show cursor','Callback',@showcursor);
flcon = uimenu(f,'Label','Linecut at Cursor','Callback',@showcut);
imgcursor = [];
% a1 = findobj(gcf, 'type', 'axes');
% imghandle = get(a1, 'Children');
% img = get(imghandle, 'CData');
% dt.image = img;
% dt.scale = 'lin';
% set(gcf, 'userdata', dt);

%     function linecuton(varargin)
%         if strcmp(get(flcon, 'Checked'), 'off')
%             set(flcon, 'Checked', 'on');
%         else
%             set(flcon, 'Checked', 'off');
%         end
%     end
    
    function showcursor(varargin)

        a1 = findobj(gcbf, 'type', 'axes');
        imghandle = get(a1, 'Children');
        xd = get(imghandle, 'XData');
        yd = get(imghandle, 'YData');
        %img = get(imghandle, 'CData');
        imgcursor = datacursormode(gcbf);
        imgcursor.UpdateFcn = {@myupdatefcn, xd, yd};
        imgcursor.SnapToDataVertex = 'on';
        datacursormode on
    % mouse click on plot
    end

    function showcut(varargin)
        flcut = findall(0, 'tag', 'Cursor_Image_Linecut');
        if isempty(flcut);
            flcut = figure;
            set(flcut, 'tag', 'Cursor_Image_Linecut');
        end
        event_obj = getCursorInfo(imgcursor);
        xd = get(event_obj.Target, 'XData');
        yd = get(event_obj.Target, 'YData');
        pos = event_obj.Position;
        [~, indx] = min(abs(xd-pos(1)));
        [~, indy] = min(abs(yd-pos(2)));
        
        img = get(event_obj.Target, 'CData');
        figure(flcut);
        subplot(2,1,1, 'parent', flcut);
        plot(xd, img(indy, :));
        subplot(2,1,2, 'parent', flcut);
        plot(yd, img(:, indx));
    end
%     function saveHcut(varargin)
% 
%         a1 = findobj(gcbf, 'type', 'axes');
%         imghandle = get(a1, 'Children');
%         %xd = get(imghandle, 'XData');
%         %yd = get(imghandle, 'YData');
%         img = get(imghandle, 'CData');
%         p = getCursorInfo(imgcursor);
%         [~, indx] = min(abs(xd-pos(1)));
%         [~, indy] = min(abs(yd-pos(2)));
%         
%         %imgcursor = datacursormode(gcbf);
%         %imgcursor.UpdateFcn = {@myupdatefcn, xd, yd};
%         %imgcursor.SnapToDataVertex = 'on';
%         datacursormode off
%     % mouse click on plot
%     end
    function txt = myupdatefcn(varargin)
        obj = varargin{1};
        event_obj = varargin{2};
        xd = varargin{3};
        yd = varargin{4};
    %    xmin
        % Display 'Time' and 'Amplitude'
        pos = event_obj.Position;
        [~, indx] = min(abs(xd-pos(1)));
        [~, indy] = min(abs(yd-pos(2)));
        %(-0.0167+0.05)/0.1*(siz(2)-1)+1;
        txt = {['X: ',num2str(pos(1))],['Xindex: ',num2str(indx)];
            ['Y: ',num2str(pos(2))],['Yindex: ',num2str(indy)]};
    end 
    
    function makelogimage(varargin)

        a1 = findobj(gcbf, 'type', 'axes');
        dt = get(gcbf, 'userdata');
        if ~isempty(dt)
            if isfield(dt, 'scale')
                if strcmp(dt.scale, 'log')
                    return
                end
            end
        end
        set(flg, 'Checked', 'on');
        set(fli, 'Checked', 'off');
        imghandle = get(a1, 'Children');
%        if isempty(dt)
        img = get(imghandle, 'CData');
        dt.image = img;
%        else
%            if isfield(dt, 'scale')
%                if strcmp(dt.scale, 'log')
%                    return
%                end
%            end
%        end
        set(imghandle, 'CData', log10(abs(double(dt.image))+eps));
        dt.scale = 'log';
        set(gcbf, 'userdata', dt);

    end    
    function makelinimage(varargin)

        a1 = findobj(gcbf, 'type', 'axes');
        dt = get(gcbf, 'userdata');
        imghandle = get(a1, 'Children');
        if ~isempty(dt)
            if isfield(dt, 'scale')
                if strcmp(dt.scale, 'lin')
                    return
                end
            end
        end
        set(flg, 'Checked', 'off');
        set(fli, 'Checked', 'on');
        if isempty(dt)
            dt.image = 10.^double(get(imghandle, 'CData'));
        end
        set(imghandle, 'CData', dt.image);
        dt.scale = 'lin';
        set(gcbf, 'userdata', dt);
    end
    function changescale(varargin)

        prompt = {'Enter Min Value:','Enter Max Value:'};
        dlg_title = 'Input';
        num_lines = 1;
        switch get(flg, 'Checked')
            case 'on'
                defaultans = {'0','5'};
            case 'off'
                defaultans = {'0','100'};
        end
        answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

        caxis(gca, [str2double(answer{1}), str2double(answer{2})]);
    end
end