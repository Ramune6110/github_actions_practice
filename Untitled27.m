% Simulink���f���̑��΃p�X�iGit���|�W�g�����̃p�X�j���w�肵�܂�
modelRelativePath = 'sample.slx';

% Git���|�W�g���̃p�X���w�肵�܂�
rootFolder = pwd;
gitRepoPath = rootFolder;

rootFolder = pwd;

% �ꎞ�f�B���N�g�����쐬���܂�
tempDir = fullfile(tempname);
mkdir(tempDir);

% �ŐV�̃R�~�b�g�n�b�V�����擾���܂�
[status, latestCommit] = system(sprintf('git -C %s rev-parse HEAD', gitRepoPath));
if status ~= 0
    error('Failed to get the latest commit hash');
end
latestCommit = strtrim(latestCommit);

% �X�e�[�W����Ă���ύX�����邩�m�F���܂�
[status, stagedFiles] = system(sprintf('git -C %s diff --cached --name-only', gitRepoPath));
if status ~= 0
    error('Failed to check staged files');
end

% % �X�e�[�W����Ă���ύX���Ȃ���΃G���[��\�����܂�
% if isempty(strtrim(stagedFiles))
%     error('No staged changes found. Please stage the changes before running the script.');
% end

% �ύX�O�̃R�~�b�g�n�b�V�����擾���܂�
[status, oldCommit] = system(sprintf('git -C %s rev-parse HEAD^', gitRepoPath));
if status ~= 0
    error('Failed to get the previous commit hash');
end
oldCommit = strtrim(oldCommit);

% % �ύX��̃R�~�b�g�n�b�V�����ꎞ�R�~�b�g�Ŏ擾���܂�
% tempBranchName = 'temp_comparison_branch';
% system(sprintf('git -C %s checkout -b %s', gitRepoPath, tempBranchName));
% system(sprintf('git -C %s commit -m "Temporary commit for comparison"', gitRepoPath));
% [status, newCommit] = system(sprintf('git -C %s rev-parse HEAD', gitRepoPath));
% if status ~= 0
%     error('Failed to get the new commit hash');
% end
% newCommit = strtrim(newCommit);
% 
% % �Â��o�[�W�����̃��f���t�@�C�����`�F�b�N�A�E�g
% oldModelPath = fullfile(tempDir, 'old_model.slx');
% gitCheckoutCmdOld = sprintf('git -C %s show %s:%s > %s', gitRepoPath, oldCommit, modelRelativePath, oldModelPath);
% system(gitCheckoutCmdOld);
% 
% % �V�����o�[�W�����̃��f���t�@�C�����`�F�b�N�A�E�g
% newModelPath = fullfile(tempDir, 'new_model.slx');
% gitCheckoutCmdNew = sprintf('git -C %s show %s:%s > %s', gitRepoPath, newCommit, modelRelativePath, newModelPath);
% system(gitCheckoutCmdNew);
% 
% % visdiff�֐����g�p����2�̃��f���t�@�C�����r���A������\��
% comparisonReport = visdiff(oldModelPath, newModelPath);
% 
% % ���|�[�g��HTML�`���ŕۑ����邽�߂̃f�B���N�g�����w�肵�܂�
% reportDir = 'path/to/save/report';
% if ~exist(reportDir, 'dir')
%     mkdir(reportDir);
% end
% 
% % ���|�[�g��HTML�`���ŕۑ����܂�
% reportFileName = fullfile(reportDir, 'model_comparison_report.html');
% publish(comparisonReport, 'format', 'html', 'outputDir', reportDir, 'showCode', false);
% 
% % �ꎞ�u�����`���폜���A���̃u�����`�ɖ߂�܂�
% system(sprintf('git -C %s checkout -', gitRepoPath));
% system(sprintf('git -C %s branch -D %s', gitRepoPath, tempBranchName));
% 
% % �ꎞ�f�B���N�g�����폜���܂�
% rmdir(tempDir, 's');
% 
% % �������b�Z�[�W
% disp(['���|�[�g���ۑ�����܂���: ', reportFileName]);
