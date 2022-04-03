function [X, Y, Z, density, cellinfo] = loadxplor(filename)
fid = fopen(filename, 'r');
fgetl(fid); % read first empty line
nt = fgetl(fid); % read the number of title lines.
nt = str2double(nt);
for i=1:nt % skip reading title.
    fgetl(fid);
end
pixeldiv = fgetl(fid);
pdiv = sscanf(pixeldiv,'%i %i %i %i %i %i');
voxeldim = pdiv(1:3:end)';
x=linspace(0, 1, voxeldim(1));
y=linspace(0, 1, voxeldim(2));
z=linspace(0, 1, voxeldim(3));
[X, Y, Z] = ndgrid(x,y,z);
cellp = fgetl(fid);
cell = sscanf(cellp,'%f %f %f %f %f %f');
cellinfo = celcon(cell);
P = [X(:), Y(:), Z(:)]*cellinfo.mat';
X = reshape(P(:,1), size(X));
Y = reshape(P(:,2), size(Y));
Z = reshape(P(:,3), size(Z));
fgetl(fid); % ZYX
pleft = 1:12:72;
pright = pleft + 11;
density = zeros(voxeldim);
layerdensity = [];
while(1)
    l = fgetl(fid);
    if numel(l)<=7;
        if strcmp(l(1:5), '-9999')
            break
        end
        zn = str2double(l);
        if zn > 0
            density(:,:,zn+1) = reshape(layerdensity, voxeldim(1:2));
        end
        layerdensity = [];
        continue
    end
    n = zeros(1, numel(pleft));
    for i=1:numel(pleft)
        n(i) = str2double(l(pleft(i):pright(i)));
    end
    layerdensity = [layerdensity, n];
end
density(:,:,zn+1) = reshape(layerdensity, voxeldim(1:2));
fclose(fid)