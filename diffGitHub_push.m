% function diffGitHub_push(lastpush)
%     % Open project
%     proj = openProject(pwd);
%     
%     % List modified models since the last push. Use *** to search recursively for modified 
%     % SLX files starting in the current folder
%     % git diff --name-only lastpush ***.slx
%     gitCommand = sprintf('git --no-pager diff --name-only %s ***.slx', lastpush);
%     [status,modifiedFiles] = system(gitCommand);
%     assert(status==0, modifiedFiles);
%     modifiedFiles = split(modifiedFiles);
%     modifiedFiles(end) = []; % Removing last element because it is empty
%     
%     if isempty(modifiedFiles)
%         disp('No modified models to compare.')
%         return
%     end
%     
%     % Create a temporary folder to store the ancestors of the modified models
%     % If you have models with the same name in different folders, consider
%     % creating multiple folders to prevent overwriting temporary models
%     tempdir = fullfile(proj.RootFolder, "modelscopy");
%     mkdir(tempdir)
%     
%     % Generate a comparison report for every modified model file
%     for i = 1:numel(modifiedFiles)
%         report = diffToAncestor(tempdir,string(modifiedFiles(i)),lastpush);
%     end
%     
%     % Delete the temporary folder
%     rmdir modelscopy s
%     
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     
%     function report = diffToAncestor(tempdir,fileName,lastpush)
%         
%         ancestor = getAncestor(tempdir,fileName,lastpush);
%     
%         % Compare models and publish results in a printable report
%         % Specify the format using 'pdf', 'html', or 'docx'
%         comp= visdiff(ancestor, fileName);
%         filter(comp, 'unfiltered');
%         report = publish(comp,'html');
%         
%     end
%     
%     
%     function ancestor = getAncestor(tempdir,fileName,lastpush)
%         
%         [relpath, name, ext] = fileparts(fileName);
%         ancestor = fullfile(tempdir, name);
%         
%         % Replace seperators to work with Git and create ancestor file name
%         fileName = strrep(fileName, '\', '/');
%         ancestor = strrep(sprintf('%s%s%s',ancestor, "_ancestor", ext), '\', '/');
%         
%         % Build git command to get ancestor
%         % git show lastpush:models/modelname.slx > modelscopy/modelname_ancestor.slx
%         gitCommand = sprintf('git --no-pager show %s:%s > %s', lastpush, fileName, ancestor);
%         
%         [status, result] = system(gitCommand);
%         assert(status==0, result);
%     
%     end
% end

function diffGitHub_push(lastpush)
    % プロジェクトのパスを設定（プロジェクトファイルがない場合）
    rootFolder = pwd;  % 必要に応じてプロジェクトのルートフォルダを指定
    
    % List modified models since the last push. Use *** to search recursively for modified 
    % SLX files starting in the current folder
    gitCommand = sprintf('git --no-pager diff --name-only %s ***.slx', lastpush);
    [status, modifiedFiles] = system(gitCommand);
    assert(status==0, modifiedFiles);
    modifiedFiles = split(modifiedFiles);
    modifiedFiles(end) = []; % Removing last element because it is empty
    
    if isempty(modifiedFiles)
        disp('No modified models to compare.')
        return
    end
    
    % Create a temporary folder to store the ancestors of the modified models
    tempdir = fullfile(rootFolder, "modelscopy");
    mkdir(tempdir)
    
    % Generate a comparison report for every modified model file
    for i = 1:numel(modifiedFiles)
        report = diffToAncestor(tempdir, string(modifiedFiles(i)), lastpush);
    end
    
    % Delete the temporary folder
    rmdir modelscopy s
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    function report = diffToAncestor(tempdir, fileName, lastpush)
        
        ancestor = getAncestor(tempdir, fileName, lastpush);
    
        % Compare models and publish results in a printable report
        % Specify the format using 'pdf', 'html', or 'docx'
%         comp = visdiff(ancestor, fileName);
%         filter(comp, 'unfiltered');
%         report = publish(comp, 'html');
        % Compare models and publish results in a printable report
        % Specify the format using 'pdf', 'html', or 'docx'
        % Note: visdiff is a GUI-based function and may not work in a headless environment
        % Consider using another method to compare models if running in a CI/CD pipeline
        try
            comp = visdiff(ancestor, fileName);
            filter(comp, 'unfiltered');
            report = publish(comp, 'html');
        catch
            disp(['Unable to compare ' ancestor ' and ' fileName ' without opening the Comparison Tool.']);
            report = '';
        end
    end
    
    function ancestor = getAncestor(tempdir, fileName, lastpush)
        
        [relpath, name, ext] = fileparts(fileName);
        ancestor = fullfile(tempdir, name);
        
        % Replace separators to work with Git and create ancestor file name
        fileName = strrep(fileName, '\', '/');
        ancestor = strrep(sprintf('%s%s%s', ancestor, "_ancestor", ext), '\', '/');
        
        % Build git command to get ancestor
        gitCommand = sprintf('git --no-pager show %s:%s > %s', lastpush, fileName, ancestor);
        
        [status, result] = system(gitCommand);
        assert(status == 0, result);
    
    end
end

%   Copyright 2023 The MathWorks, Inc.
