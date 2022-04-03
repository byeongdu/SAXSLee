function SAXSLee_savedata(varargin)
% SAXSLee_savedata(scan)
%   default fileextension = '.Abs'
% SAXSLee_savedata(scan, fileextension)
%   ex) SAXSLee_savedata(scan, 'dat')
% SAXSLee_savedata(filename, data)
%
% Byeongdu Lee

if numel(varargin) == 2
    % string filename, 3 or 2 column data file.
    filename = varargin{1};
%    data = varargin{2};
    if ischar(filename)
        save(filename, 'data', '-ascii');
        return
    end
end
if numel(varargin) == 2
    scan = varargin{1};
    FileExt = varargin{2};
end
if numel(varargin) == 1
    scan = varargin{1};
    FileExt = 'Abs';
end

if isempty(scan)
    
else
    for i=1:numel(scan)
        if isfield(scan{i}, 'colData')
            nd = scan{i}.colData;
            filename = [scan{i}.Tag, '.', FileExt];
            save(filename, 'nd', '-ascii');
        end
        if isfield(scan{i}, 'colWData')
            nd = scan{i}.colWData;
            filename = scan{i}.WTag;
            filename = [scan{i}.WTag, '.', FileExt];
            save(filename, 'nd', '-ascii');
        end
    end
end
