function yesorno = SAXSLee_isbacksub(hd)
    yesorno = 0;
    if ~isempty(getappdata(hd, 'isbacksubtracted'))
        yesorno = 1;
    end
end
