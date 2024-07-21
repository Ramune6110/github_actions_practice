% Simulinkモデルの相対パス（Gitリポジトリ内のパス）を指定します
modelRelativePath = 'sample.slx';

% Gitリポジトリのパスを指定します
rootFolder = pwd;
gitRepoPath = rootFolder;

% 一時ディレクトリを作成します
tempDir = fullfile(tempname);
mkdir(tempDir);

% 最新のコミットハッシュを取得します
[status, latestCommit] = system(sprintf('git -C %s rev-parse HEAD', gitRepoPath));
if status ~= 0
    error('Failed to get the latest commit hash');
end
latestCommit = strtrim(latestCommit);

% ステージされている変更があるか確認します
[status, stagedFiles] = system(sprintf('git -C %s diff --cached --name-only', gitRepoPath));
if status ~= 0
    error('Failed to check staged files');
end

% ステージされている変更がなければエラーを表示します
if isempty(strtrim(stagedFiles))
    error('No staged changes found. Please stage the changes before running the script.');
end

% 変更前のコミットハッシュを取得します
[status, oldCommit] = system(sprintf('git -C %s rev-parse HEAD^', gitRepoPath));
if status ~= 0
    error('Failed to get the previous commit hash');
end
oldCommit = strtrim(oldCommit);

% 現在のブランチ名を取得
[status, currentBranch] = system(sprintf('git -C %s rev-parse --abbrev-ref HEAD', gitRepoPath));
if status ~= 0
    error('Failed to get the current branch name');
end
currentBranch = strtrim(currentBranch);

% 起点となるブランチが 'main' または 'develop' であることを確認
if ~ismember(currentBranch, {'main', 'develop'})
    error('This script can only be run from the main or develop branch.');
end

try
    % 変更後のコミットハッシュを取得するために、ステージされた変更を一時ブランチに適用
    tempBranchName = 'temp_comparison_branch';
    system(sprintf('git -C %s checkout -b %s', gitRepoPath, tempBranchName));
    system(sprintf('git -C %s add %s', gitRepoPath, modelRelativePath));  % ステージされた変更を追加
    system(sprintf('git -C %s commit -m "Temporary commit for comparison"', gitRepoPath));
    [status, newCommit] = system(sprintf('git -C %s rev-parse HEAD', gitRepoPath));
    if status ~= 0
        error('Failed to get the new commit hash');
    end
    newCommit = strtrim(newCommit);

    % 古いバージョンのモデルファイルをチェックアウト
    oldModelPath = fullfile(tempDir, 'old_model.slx');
    gitCheckoutCmdOld = sprintf('git -C %s show %s:%s > %s', gitRepoPath, oldCommit, modelRelativePath, oldModelPath);
    system(gitCheckoutCmdOld);

    % 新しいバージョンのモデルファイルをチェックアウト
    newModelPath = fullfile(tempDir, 'new_model.slx');
    gitCheckoutCmdNew = sprintf('git -C %s show %s:%s > %s', gitRepoPath, newCommit, modelRelativePath, newModelPath);
    system(gitCheckoutCmdNew);

    % 既に開いている同名のモデルを閉じる
    try
        close_system('old_model', 0); % 変更を保存せずに閉じる
    catch
        % モデルが開かれていない場合の例外を無視
    end

    try
        close_system('new_model', 0); % 変更を保存せずに閉じる
    catch
        % モデルが開かれていない場合の例外を無視
    end

    % visdiff関数を使用して2つのモデルファイルを比較し、差分を表示
    comparisonReport = visdiff(oldModelPath, newModelPath);

    % 比較レポートをHTML形式で保存するためのディレクトリを指定します
    reportDir = 'path/to/save/report';
    if ~exist(reportDir, 'dir')
        mkdir(reportDir);
    end

    % 比較レポートをHTML形式で保存
    reportFileName = fullfile(reportDir, 'model_comparison_report.html');

    % HTMLファイルとして比較レポートを保存するためにslxmlcomp.exportを使用します
    filter(comparisonReport, 'unfiltered');
    publish(comparisonReport, 'html'); % OutputDirを指定
    
    % 元のブランチに戻ります
    system(sprintf('git -C %s checkout %s', gitRepoPath, currentBranch));
    
    % レポートファイルが更新されていれば、git addとgit commitを実行
    [status, changedFiles] = system(sprintf('git -C %s status --porcelain', gitRepoPath));
    if status == 0 && contains(changedFiles, 'model_comparison_report.html')
        system(sprintf('git -C %s add %s', gitRepoPath, reportFileName));
        system(sprintf('git -C %s commit -m "Update: Model comparison report updated."', gitRepoPath));
    end
    
    % 一時ブランチを削除します
    system(sprintf('git -C %s branch -D %s', gitRepoPath, tempBranchName));

    % 完了メッセージ
    disp(['レポートが保存されました: ', reportFileName]);

catch ME
    % エラー発生時に元のブランチに戻る
    system(sprintf('git -C %s checkout %s', gitRepoPath, currentBranch));
    system(sprintf('git -C %s branch -D %s', gitRepoPath, tempBranchName));
    rmdir(tempDir, 's'); % 一時ディレクトリを削除
    rethrow(ME);
end

% 一時ディレクトリを削除します
rmdir(tempDir, 's');