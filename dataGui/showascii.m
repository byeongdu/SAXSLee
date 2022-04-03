str = '';
strv = '';
for i=945:969
    str = sprintf('%s%c%s', str, char(i), '       ');
    strv = sprintf('%s%s%s', strv, num2str(i), '     ');
end
str
strv