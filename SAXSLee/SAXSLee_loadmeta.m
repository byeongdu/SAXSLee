function scan = SAXSLee_loadmeta(filename)
% scan = SAXSLee_loaddata(filename)
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
scan = cell(Ndata,1);
OLD = 'SAXS\Averaged\S';
NEW = 'Log\L';
OLDext = '.dat';
Newext = '.meta';
for iSelection=1:Ndata
    fn = fnc{iSelection, 1};
    fn = strrep(fn,OLD,NEW);
    fn = strrep(fn,OLDext,Newext);
    try
        [phd, ic1, eng, expt]=parseMetafile(fn);
    catch
        phd = 1;
        ic1 = 1;
        eng = 1;
        expt = 1;
    end
    scan{iSelection}.phd = phd;
    scan{iSelection}.ic = ic1;
    scan{iSelection}.energy = eng;
    scan{iSelection}.exposuretime = expt;
end