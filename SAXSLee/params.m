function [scanPeak,scanCOM,scanFWHM] = params(scan)
% PARAMS Calculate peak,COM and FWHM of a scan
%
% Copyright 2004, Zhang Jiang

% --- peak
[peak,peakIndex] = max(scan(:,2));
scanPeak.X = scan(peakIndex,1);
scanPeak.Y = peak;

% --- COM
if sum(scan(:,2)) == 0      % denominator is not zero
    scanCOM = 0;
else
    scanCOM = sum(scan(:,1).*scan(:,2))/sum(scan(:,2));
end

% --- FWHM
try
    leftError = 0;
    halfLeftIndex = find(scan(1:peakIndex,2)<peak/2);
    left = interp1(...
        scan(halfLeftIndex(end):peakIndex,2),scan(halfLeftIndex(end):peakIndex,1),peak/2);
catch
    leftError = 1;
end
try
    rightError = 0;
    halfRightIndex = find(scan(peakIndex:end,2)<peak/2)+peakIndex-1;
    right = interp1(...
        scan(peakIndex:halfRightIndex(1),2),scan(peakIndex:halfRightIndex(1),1),peak/2);
catch
    rightError = 1;
end
if leftError == 0 & rightError == 0
    scanFWHM.center = (left+right)/2;
    scanFWHM.FWHM = right-left;
elseif leftError == 0 & rightError == 1
    scanFWHM.center = left;
    scanFWHM.FWHM = scan(end,1)-left;
elseif leftError == 1 & rightError == 0
    scanFWHM.center = right;
    scanFWHM.FWHM = right-scan(1,1);
else
    scanFWHM.center = (scan(end,1)+scan(1,1))/2;
    scanFWHM.FWHM = scan(end,1)-scan(1,1);
end