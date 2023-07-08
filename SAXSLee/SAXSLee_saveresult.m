function filename = SAXSLee_saveresult(settings, Beamline, dataType, nd, tg, header)
% SAXSLee_savedata(settings, Beamline, dataType, nd, tg)
% SAXSLee_savedata('', '', '', data, filename_tag)

    pth = [];
    if nargin < 6
        header = [];
    end
    if ~isempty(header)
        if isfield(header, 'path')
            pth = fileparts(header.path); %This clear up '\Averaged'.
            [pth, backsubdir] = SAXSLee_getfolders(settings, pth, dataType);
            pth = fullfile(pth, filesep, backsubdir);
        end
    end
    if isempty(pth)
        [pth, backsubdir] = SAXSLee_getfolders(settings, [], dataType);
        if isempty(pth)
            pth = settings.path;
        end
        pth = fullfile(pth, filesep, backsubdir);
    end
    if isempty(pth)
        pth = settings.path;
    end
    tg(tg == ' ') = '_';
    t = find(tg == ':');
    tg(1:t+1) = [];
    filename = fullfile(pth, tg);
    pdir = fullfile(pth);
    if ~isempty(pdir)
        if ~isdir(pdir)
            mkdir(pdir);
        end
    end
    fid = fopen(filename, 'w');
    if ~isempty(header)
        fname = fieldnames(header);
        for i=1:numel(fname)
            if isnumeric(header.(fname{i}))
                fprintf(fid, '%% %s : %0.5f \n', fname{i}, header.(fname{i}));
            else
                fprintf(fid, '%% %s : %s \n', fname{i}, header.(fname{i}));
            end
        end
    end
    fprintf(fid, '%s\n', '');
    fclose(fid);
    save(filename, 'nd', '-ascii', '-append');
    fprintf('%s%s%s is saved\n', pth, filesep, tg);
end