function resettoolbar(hCurrentFig)
hToolbarEditPlot = findall(hCurrentFig,'Tag','toolbarEditPlot');
hToolbarZoom = findall(hCurrentFig,'Tag','toolbarZoom');
hToolbarPan = findall(hCurrentFig,'Tag','toolbarPan');
hToolbarDataCursor = findall(hCurrentFig,'Tag','toolbarDataCursor');
plotedit off;
zoom off;
pan off;
datacursormode off;
set(hToolbarEditPlot,'state','off');
set(hToolbarZoom,'state','off');
set(hToolbarPan,'state','off');
set(hToolbarDataCursor,'state','off');
