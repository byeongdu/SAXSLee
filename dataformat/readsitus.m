function [alln, X, Y, Z] = readsitus(filename)
fid = fopen(filename, 'r');
alln = [];
tline = fgetl(fid); % read first header out.
t = str2num(tline);
res = t(1);
ox = t(2);
oy = t(3);
oz = t(4);
nx = t(5);
ny = t(6);
nz = t(7);

tline = fgetl(fid); % read 2nd header out.
x = (1:nx)*res + ox;
y = (1:ny)*res + oy;
z = (1:nz)*res + oz;
while 1
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    t = str2num(tline);
    alln = [alln, t];
end
fclose(fid);
[X, Y, Z] = ndgrid(x, y, z);
alln = reshape(alln, nx, ny, nz);
