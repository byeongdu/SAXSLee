function SAXSLee_loadfig

filter={'*.fig','Figure File (*.fig)';...
        '*.*','All Files (*.*)'};
[filename, pathname] = uigetfile(filter,'Load a figure');	
% If 'Cancel' was selected then return
if isequal([filename,pathname],[0,0])
    return
else
    % Construct the full path and save
    File = fullfile(pathname,filename);
    % Load the selected figure.
    h = openfig(File, 'new', 'invisible');
    
    % find the target Axes, which is the axes of SAXSLee.
    hFigSAXSLee = findobj('Tag','SAXSLee_Fig');
    hAxes = findobj(hFigSAXSLee,'Tag','SAXSLee_Axes');    
    
    % push the children's in the saved axes into the SAXSLee axes.
    oh = findobj(h, 'type', 'axes');
    copyobj(get(oh(end), 'children'), hAxes)
end