function dt = readUSAXSxml(filename, field)
if nargin < 2
    field = [];
end
if ~isempty(field)
    if contains(lower(field), 'time')
        field = 'timeStamp';
    end
end
tree = xmlread(filename);

if isempty(field) % Read [Q, I, Idev]
    allListitemsQ = tree.getElementsByTagName('Q');
    allListitemsI = tree.getElementsByTagName('I');
    allListitemsIdev = tree.getElementsByTagName('Idev');
    N = allListitemsQ.getLength;
    q = zeros(N, 1);
    I = zeros(N, 1);
    Idev = zeros(N, 1);

    for i=0:N-1
        thisQ = allListitemsQ.item(i);
        thisI = allListitemsI.item(i);
        thisIdev = allListitemsIdev.item(i);
        q(i+1) = str2double(thisQ.getFirstChild.getData);
        I(i+1) = str2double(thisI.getFirstChild.getData);
        Idev(i+1) = str2double(thisIdev.getFirstChild.getData);
    end    
    dt = [q, I, Idev];
else
    allListitems = tree.getElementsByTagName(field);
    dt = cell(allListitems.getLength, 1);
    for i=0:allListitems.getLength-1
        thisQ = allListitems.item(i);
        dt(i+1) = thisQ.getFirstChild.getData;
    end
end
if strcmp(field, 'timeStamp')
    dc = dt;
    dt = zeros(size(dc));
    for i=1:numel(dc)
        s = dc{i};
        N = findstr(s, ' ');
        mmm = s(N(1)+1:N(2)-1);
        dd = s(N(2)+1:N(3)-1);
        tt = s(N(3)+1:N(4)-1);
        yr = s(N(4)+1:length(s));
        dt(i) = datenum(datestr(sprintf('%s-%s-%s %s', dd, mmm, yr, tt), ...
            'dd-mmm-yyyy HH:MM:SS'));
    end
end