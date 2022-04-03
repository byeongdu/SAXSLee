function dt = readUSAXSreducedh5(filename, Nd)
% [data, header] = readUSAXSreducedh5(filename, datatype)
% Reading APS USAXS reduced h5 file that included both USAXS/SAXS
%
% Usage:
% data = readUSAXSh5('mytest.h5')
%
% 2/7/2021
% Byeongdu Lee
if nargin<2
    Nd = [];
end
info = h5info(filename);
Ndata = numel(info.Groups);
%header = cell(1, sum(t));
dt = [];
if isempty(Nd)
    Nd = Ndata;
    Ns = 1;
else
    Ns = Nd;
end
k = 1;
for Nset = Ns:Nd
    header = info.Groups(Nset).Groups(1).Name;
    tmp = [info.Groups(Nset).Groups(1).Datasets.Dataspace];
    [ds, ~, ind] = unique([tmp.Size]);
    [datasize, dsind] = max(ds);
    t = ind == dsind;
    data = zeros(datasize, sum(t));
    columnName = {info.Groups(Nset).Groups(1).Datasets.Name};
    for i=1:numel(ind)
        if t(i) ~= 1
            continue
        end
        newName = sprintf('%s/%s', header, info.Groups(Nset).Groups(1).Datasets(i).Name);
        data(:,i) = h5read(filename, newName);
    end
    dt(k).data = data;
    dt(k).header = header;
    dt(k).columnName = columnName;
    k = k+1;
end