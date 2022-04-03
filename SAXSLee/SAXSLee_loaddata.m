function scan = SAXSLee_loaddata(filename, option)
% scan = SAXSLee_loaddata(filename)
% Load data and update scan
% Plot the data on hAxes
% filename : filename to be loaded. It can be a string or a cell including
% SAXS and WAXS filenames. SAXS filename comes first.
if nargin < 2
    option = [];
end
if ~iscell(filename)
    fnc{1} = filename;
else
    fnc = filename;
end
Ndata = size(fnc, 1);
Ndet = size(fnc, 2);
scan = cell(Ndata,1);
for iSelection=1:Ndata
    for mm = 1:Ndet
        fn = fnc{iSelection, mm};

        % Loading file.
        % Does the file exist?

        Notloaded = 1;
%        loadCount = 1;
%        while (Notloaded) 
            try
                [hdr, tmp] = hdrload(fn);
                [~,ntmp] = size(tmp);
                if ntmp == 2
                    tmp(:,3) = sqrt(abs(tmp(:,2)));
                else
                    if ~isempty(option)
                        x = tmp(:, option.xcol);
                        y = tmp(:, option.ycol);
                        if isfield(option, 'yerrcol')
                            yerr = tmp(:, option.yerrcol);
                        else
                            yerr = sqrt(abs(y));
                        end
                        tmp = [x, y, yerr];
                    end
                end
                Notloaded = 0;
            catch
%                loadCount = loadCount + 1;
            end
%            if loadCount > 20
%                break
%            end
%             if Notloaded
%                 pause(0.3)
%             end
%        end

        [fpath,f1,f2] = fileparts(fn);
        cfile = [f1, f2];
        
        if (mm==1)
            scan{iSelection}.Tag = cfile;
        else
            scan{iSelection}.WTag = cfile;
        end
        
        if Notloaded == 1
            fprintf('There is not found %s\n', fn);
            continue
        end
        % if the file is loaded.
        
        if (mm==1)
            scan{iSelection}.colData = tmp;
            scan{iSelection}.path = fpath;
        else
            scan{iSelection}.colWData = tmp;
            scan{iSelection}.Wpath = fpath;
        end
        scan{iSelection}.header = hdr;
    end
end