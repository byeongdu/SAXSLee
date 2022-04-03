fn = 'P3HT_SiO2_315K_264.mar3450';
fid = fopen(fn, 'r');
cimg = fread(fid);
fclose(fid);
t = sprintf('%c', cimg(1:6000));
formatid = strfind(t, 'CCP4 packed image');
len = strfind(t(formatid:formatid+50), char(10));
f = sscanf(t(formatid:formatid+len-1), 'CCP4 packed image, X: %f, Y: %f');
%a = unpack345new(cimg, f(1), f(2));
%a = unpack345new(char(cimg), 15, 1);
a = unpack_word(cimg, 3450, 3450);

                      