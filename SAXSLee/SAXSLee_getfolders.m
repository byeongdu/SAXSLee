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