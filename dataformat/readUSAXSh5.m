function [data, header] = readUSAXSh5(filename, datatype)
% Reading APS USAXS h5 file
% [data, header] = readUSAXSh5(filename, datatype)
% datatype: Name of the group to read.
%   default:'flyScan_reduced_full'
%
% Usage:
% [data, header] = readUSAXSh5('mytest.h5')
% [data, header] = readUSAXSh5('mytest.h5', 'flyScan_reduced_250')
%
% 2/7/2021
% Byeongdu Lee

if nargin < 2
    datatype = 'flyScan_reduced_full';
end
if strcmp(datatype, 'saxs')
    datatype = 'areaDetector_reduced_full';
end
Nset = 0;
data = [];
info = h5info(filename);
for i=1:numel(info.Groups.Groups)
    if contains(info.Groups.Groups(i).Name, datatype)
        Nset = i;
        Name = info.Groups.Groups(i).Name;
        break
    end
end
if Nset ==0
    return
end
tmp = [info.Groups.Groups(3).Datasets.Dataspace];
[ds, ~, ind] = unique([tmp.Size]);
[datasize, dsind] = max(ds);
t = ind == dsind;
data = zeros(datasize, sum(t));
header = cell(1, sum(t));
k = 1;
for i=1:numel(ind)
    if t(i) ~= 1
        continue
    end
    header{k} = info.Groups.Groups(Nset).Datasets(i).Name;
    newName = sprintf('%s/%s', Name, info.Groups.Groups(Nset).Datasets(i).Name);
    data(:,k) = h5read(filename, newName);
    k = k + 1;
end