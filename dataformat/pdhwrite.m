function pdhwrite(data)

[filename, pathname] = uiputfile('*.ift', 'Save as PDH format');
file = [pathname, '\', filename];
fid = fopen(file,'w');
fprintf(fid, 'data converting \r\n');
fprintf(fid, 'SAXS \r\n')
fprintf(fid, '%9i %1s %9i %1s %9i %1s %9i %1s %9i %1s %9i %1s %9i %1s %9i\r\n', length(data(:,1)),' ', 0,' ', 0,' ', 0,' ', 0,' ', 0,' ', 0,' ', 0)
fprintf(fid, '%14.6e %1s %14.6e %1s %14.6e %1s %14.6e %1s %14.6e\r\n', 0, ' ', 0, ' ', 0, ' ', 1, ' ', 0)
fprintf(fid, '%14.6e %1s %14.6e %1s %14.6e %1s %14.6e %1s %14.6e\r\n', 0, ' ', 0, ' ', 0, ' ', 0, ' ', 0)
[x, y] = size(data);
if y < 3
    sig = -1*ones(size(data(:,1)));
end
data(:,3) = sig;

for i=1:x
    fprintf(fid, '%14.6e, %1s %14.6e, %1s %14.6e\r\n', data(i, 1), ' ', data(i, 2), ' ', data(i, 3));
end
fclose(fid);