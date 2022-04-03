function SAXSLee_savefig

% --- user choose a file to save
filter={'*.fig','Figure File (*.fig)';...
        '*.*','All Files (*.*)'};
[filename, pathname,filterIndex] = uiputfile(filter,'Save Graph As');	
% If 'Cancel' was selected then return
if isequal([filename,pathname],[0,0])
    return
else
    % Construct the full path and save
    File = fullfile(pathname,filename);
    switch filterIndex
        case 1
            if ~ strcmp(File(end-3:end),'.fig')
                File=[File '.fig'];
            end
        case 2
    end
    savefig(gcf, File);
end