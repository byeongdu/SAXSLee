function SAXSLee_copyPlotoption(oldhandle, newhandle)
% This function is for copying line properties of orignal to the either
% background subtracted or FF devided.

fieldname = {'isSAXSWAXS', 'isSAXS', 'SAXShandle', 'WAXShandle'};
for i=1:numel(fieldname)
    setappdata(newhandle, fieldname{i}, getappdata(oldhandle, fieldname{i}));
end
lineproperties = {'marker', 'color'};
for i=1:numel(lineproperties)
    set(newhandle, lineproperties{i}, get(oldhandle, lineproperties{i}));
end
SAXSLee_dataControlmenu(newhandle);

