centerx = 483.9;
centery = 582.6;
pixelsize = 0.175;
sdd = 2056.5;
offset = 200;
mask_centerradius = 14;
mask_centerx = centerx;
mask_centery = centery;
normvalcolumn = 5;
energycolumn = 7;

l{1} = '#!/bin/bash\n';

l{2} = 'logname=$1\n';

l{3} = 'while test $# -ge 2 ; do';
l{4} = 'filename=$2\n';

l{5} = 'fileline=`grep -F $filename $logname`';
l{6} = sprintf('normval=`echo $fileline | gawk \''{ print $%d }\''`', normvalcolumn);
l{7} = sprintf('energyval=`echo $fileline | gawk \''{ print $%d }\''`\n', energycolumn);

l{8} = 'echo FILENAME $filename $normval $energyval';

l{9} = sprintf('goldaverage -o Averaged_norm -y -p %0.3f, -d %0.2f -Z %d -k $normval -e $energyval -c%d@%0.2f,%0.2f %0.2f %0.2f $filename',...
    pixelsize, sdd, offset, mask_centerradius, mask_centerx, mask_centery, centerx, centery);
l{10} = 'shift';
l{11} = 'done';

fdgn = fopen('goldnormengavg', 'w');
for k=1:11
    fprintf(fdgn, [l{k}, '\n']);
end
fclose(fdgn);
system('chmod 777 goldnormengavg');