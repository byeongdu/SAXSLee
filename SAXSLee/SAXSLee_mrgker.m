function mergedata = SAXSLee_mrgker(varargin)
% SAXSLee_mrgker(data)
% data : cell array of 3 column data.

scanData = varargin{1};
%merge = varargin{2};
yd = zeros(numel(scanData{1}(:,1)), numel(scanData));
%yd = [];
ye = yd;
for i=1:numel(scanData);
    yd(:,i) = scanData{i}(:,2);
    ye(:,i) = scanData{i}(:,3).^2;
end
mergedata(:,1) = scanData{1}(:,1);
mergedata(:,2) = mean(yd,2);
mergedata(:,3) = sqrt(sum(ye,2))/numel(scanData);