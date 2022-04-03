function [FileList, scan] = listFileinDir(varargin)
if numel(varargin) == 0
    scan.Dir = pwd;
    scan.filefilter = '*';
elseif numel(varargin) == 1
    scan.Dir = varargin{1};
    scan.filefilter = '*';
elseif numel(varargin) == 2
    scan.Dir = varargin{1};
    scan.filefilter = varargin{2};
elseif numel(varargin) == 3
    scan.Dir = varargin{1};
    scan.filefilter = varargin{2};
    scan.filesort = varargin{3};   % file sort can be name, date, ...
end

% Get image formats
[n, n2]= filefilter;

if isempty(n)
  scan.filen = {};
else
  scan.filen = n;
end

%if ~isempty(n2)
%  n2 = strcat(repmat({'['}, 1, length(n2)), n2, repmat({']'}, 1, length(n2)));
%  n = {n2{:}, n{:}};
%  scan.imageID = scan.imageID + length(n2);
%end
FileList = n;
%set(scan.FileList, 'string', n, 'value', 1);

    function [n, n2] = filefilter
            % Get image formats
    imf  = imformats;
    exts = [imf.ext];
    d = [];
    % check the format string....
    if isfield(scan, 'filefilter')
        formatstring = scan.filefilter;
    else
        formatstring = [];
    end

    if isfield(scan, 'filesort')
        sortstring = scan.filesort;
    else
        sortstring = 'name';
    end

    % list files
    if isempty(formatstring)
        for id = 1:length(exts)
            d = [d; dir(fullfile(scan.Dir, ['*.' exts{id}]))];
        end
    else
        d = [d; dir(fullfile(scan.Dir, formatstring))];
        d = d(~[d.isdir]);
    end

    %    sort files;
    if numel(d) < 2
        n = {d.name};
    else
        if isstr(d(1).(sortstring))
            [~, tmpind] = sort({d.(sortstring)});
        else
            [~, tmpind] = sort([d.(sortstring)]);
        end
        n = {d(tmpind).name};
    end

    d2 = dir(scan.Dir);
    n2 = {d2.name};
    n2 = n2([d2.isdir]);
    ii1 = strmatch('.', n2, 'exact');
    ii2 = strmatch('..', n2, 'exact');
    n2([ii1, ii2]) = '';
    end

end