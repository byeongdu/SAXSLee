function [pth, backsubdir] = SAXSLee_getfolders(settings, filepath, dataType)
% function [pth, backsubdir] = SAXSLee_getfolders(settings, Beamline, dataType)
% Copyright 2004, Byeongdu Lee
    if isfield(settings, 'atBeamline')
        Beamline = settings.atBeamline;
    else
        Beamline = '';
    end
    if nargin<2
        filepath = settings.path;
    end
    if nargin<3
        dataType = '';
    end
    
    if isfield(settings, 'backsubtractedDir')
        backsubdir = settings.backsubtractedDir;
    else
        backsubdir = 'Processed';
    end
    if strfind(filepath, settings.path)
        pth = settings.path;
    else
        pth = filepath;
    end
    
%     switch Beamline
%         case '12IDB'
%             if numel(dataType)>1
%                 pth = [settings.path, filesep, dataType];
%                 %pth = settings.path;
%             else
%                 pth = settings.path;
%             end
%         case 'PLS9A'
%             pth = settings.path;
%         otherwise
%             try
%                 pth = settings.path;
%             catch
%                 pth = [];
%             end
%     end
