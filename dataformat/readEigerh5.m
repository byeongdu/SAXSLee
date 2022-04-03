function data = readEigerh5(filename, datatype)
% Reading APS Eiger h5 file with lz4 compression
% The default h5read does not have lz4 compression. 
% http://hasyweb.desy.de/services/computing/nexus/hdf5-external-filters/install_on_windows.html

% 4/4/2021
% Byeongdu Lee
if nargin<2
    datatype = '/entry/data/data';
end
data = h5read(filename, datatype);