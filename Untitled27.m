% Simulinkモデルの相対パス（Gitリポジトリ内のパス）を指定します
modelRelativePath = 'sample.slx';

% Gitリポジトリのパスを指定します
rootFolder = pwd;
gitRepoPath = rootFolder;

rootFolder = pwd;

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

% % ステージされている変更がなければエラーを表示します
% if isempty(strtrim(stagedFiles))
%     error('No staged changes found. Please stage the changes before running the script.');
% end

% 変更前のコミットハッシュを取得します
[status, oldCommit] = system(sprintf('git -C %s rev-parse HEAD^', gitRepoPath));
if status ~= 0
    error('Failed to get the previous commit hash');
end
oldCommit = strtrim(oldCommit);

% % 変更後のコミットハッシュを一時コミットで取得します
% tempBranchName = 'temp_comparison_branch';
% system(sprintf('git -C %s checkout -b %s', gitRepoPath, tempBranchName));
% system(sprintf('git -C %s commit -m "Temporary commit for comparison"', gitRepoPath));
% [status, newCommit] = system(sprintf('git -C %s rev-parse HEAD', gitRepoPath));
% if status ~= 0
%     error('Failed to get the new commit hash');
% end
% newCommit = strtrim(newCommit);
% 
% % 古いバージョンのモデルファイルをチェックアウト
% oldModelPath = fullfile(tempDir, 'old_model.slx');
% gitCheckoutCmdOld = sprintf('git -C %s show %s:%s > %s', gitRepoPath, oldCommit, modelRelativePath, oldModelPath);
% system(gitCheckoutCmdOld);
% 
% % 新しいバージョンのモデルファイルをチェックアウト
% newModelPath = fullfile(tempDir, 'new_model.slx');
% gitCheckoutCmdNew = sprintf('git -C %s show %s:%s > %s', gitRepoPath, newCommit, modelRelativePath, newModelPath);
% system(gitCheckoutCmdNew);
% 
% % visdiff関数を使用して2つのモデルファイルを比較し、差分を表示
% comparisonReport = visdiff(oldModelPath, newModelPath);
% 
% % レポートをHTML形式で保存するためのディレクトリを指定します
% reportDir = 'path/to/save/report';
% if ~exist(reportDir, 'dir')
%     mkdir(reportDir);
% end
% 
% % レポートをHTML形式で保存します
% reportFileName = fullfile(reportDir, 'model_comparison_report.html');
% publish(comparisonReport, 'format', 'html', 'outputDir', reportDir, 'showCode', false);
% 
% % 一時ブランチを削除し、元のブランチに戻ります
% system(sprintf('git -C %s checkout -', gitRepoPath));
% system(sprintf('git -C %s branch -D %s', gitRepoPath, tempBranchName));
% 
% % 一時ディレクトリを削除します
% rmdir(tempDir, 's');
% 
% % 完了メッセージ
% disp(['レポートが保存されました: ', reportFileName]);
