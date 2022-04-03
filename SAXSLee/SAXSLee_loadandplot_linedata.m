function sc = SAXSLee_loadandplot_linedata(filename, NoldL, hAxes)
% scan = SAXSLee_loadandplot_linedata(filename, scan, iSelection, NoldL, hAxes)
% Load data and update scan
% Plot the data on hAxes
% filename : filename to be loaded. It can be a string or a cell including
% SAXS and WAXS filenames. SAXS filename comes first.

if ~iscell(filename)
    fnc{1} = filename;
else
    fnc = filename;
end
Ndata = size(fnc, 1);
Ndet = size(fnc, 2);
SAXS = cell(Ndata, 1);
WAXS = cell(Ndata, 1);
for iSelection=1:Ndata
    for mm = 1:Ndet
        fn = fnc{iSelection, mm};

        % Loading file.
        % Does the file exist?

        Notloaded = 1;
        loadCount = 1;
        while (Notloaded) 
            try
                [~, tmp] = hdrload(fn);
                [~,ntmp] = size(tmp);
                if ntmp == 2
                    tmp(:,3) = sqrt(abs(tmp(:,2)));
                end
                Notloaded = 0;
            catch
                loadCount = loadCount + 1;
            end
            if loadCount > 20
                break
            end
        end

        if Notloaded == 1
            fprintf('There is not found %s\n', fn);
            return
        end


        % if the file is loaded.
        if (mm==1)
            SAXS{iSelection}.data = tmp;
            SAXS{iSelection}.fn = fn;
        else
            WAXS{iSelection}.data = tmp;
            WAXS{iSelection}.fn = fn;
        end
    end
end

sc = SAXSLee_plot(SAXS, WAXS, NoldL, hAxes);

