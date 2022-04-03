function data1d = save1d(file, a, numdata)
% save1d(file, a)
% file : filename
% a : figure number where data is plotted.
%

if ~exist('file')
	[file, datadir]=uiputfile('*.dat','Select data file');
	if file==0 return; end
    file = [datadir, file];
end

if ~exist('a', 'var')
    a = gcf;
end

a = get(a);b=get(a.Children);c=get(b.Children);
if length(c) == 1
    data1d = [reshape(c.XData, length(c.XData), 1), reshape(c.YData, length(c.YData), 1)];
    save(file, 'data1d', '-ascii')
    %savestr = ['save ', file, ' data1d -ascii']
    %eval(savestr);
else
    disp(['there are many data..... maybe .. ', num2str(length(c))])
    ydata = [];
    if nargin < 3
        for i = 1:length(c)
            if length(c(i).XData) == length(c(1).XData)
                %if c(1).XData == c(i).XData
                    ydata(:, i) = [reshape(c(i).YData, length(c(i).YData), 1)];
                %end
            end
        end
    else
        ydata(:, 1) = [reshape(c(numdata).YData, length(c(numdata).YData), 1)];
    end
    data1d = [reshape(c(1).XData, length(c(1).XData), 1), ydata];
    save(file, 'data1d', '-ascii')
    %savestr = ['save ', file, ' data1d -ascii'];
    %eval(savestr);
end