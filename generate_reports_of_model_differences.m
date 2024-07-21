% Simulink���f���̑��΃p�X�iGit���|�W�g�����̃p�X�j���w�肵�܂�
modelRelativePath = 'sample.slx';

% Git���|�W�g���̃p�X���w�肵�܂�
rootFolder = pwd;
gitRepoPath = rootFolder;

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

% �X�e�[�W����Ă���ύX���Ȃ���΃G���[��\�����܂�
if isempty(strtrim(stagedFiles))
    error('No staged changes found. Please stage the changes before running the script.');
end

% �ύX�O�̃R�~�b�g�n�b�V�����擾���܂�
[status, oldCommit] = system(sprintf('git -C %s rev-parse HEAD^', gitRepoPath));
if status ~= 0
    error('Failed to get the previous commit hash');
end
oldCommit = strtrim(oldCommit);

% ���݂̃u�����`�����擾
[status, currentBranch] = system(sprintf('git -C %s rev-parse --abbrev-ref HEAD', gitRepoPath));
if status ~= 0
    error('Failed to get the current branch name');
end
currentBranch = strtrim(currentBranch);

% �N�_�ƂȂ�u�����`�� 'main' �܂��� 'develop' �ł��邱�Ƃ��m�F
if ~ismember(currentBranch, {'main', 'develop'})
    error('This script can only be run from the main or develop branch.');
end

try
    % �ύX��̃R�~�b�g�n�b�V�����擾���邽�߂ɁA�X�e�[�W���ꂽ�ύX���ꎞ�u�����`�ɓK�p
    tempBranchName = 'temp_comparison_branch';
    system(sprintf('git -C %s checkout -b %s', gitRepoPath, tempBranchName));
    system(sprintf('git -C %s add %s', gitRepoPath, modelRelativePath));  % �X�e�[�W���ꂽ�ύX��ǉ�
    system(sprintf('git -C %s commit -m "Temporary commit for comparison"', gitRepoPath));
    [status, newCommit] = system(sprintf('git -C %s rev-parse HEAD', gitRepoPath));
    if status ~= 0
        error('Failed to get the new commit hash');
    end
    newCommit = strtrim(newCommit);

    % �Â��o�[�W�����̃��f���t�@�C�����`�F�b�N�A�E�g
    oldModelPath = fullfile(tempDir, 'old_model.slx');
    gitCheckoutCmdOld = sprintf('git -C %s show %s:%s > %s', gitRepoPath, oldCommit, modelRelativePath, oldModelPath);
    system(gitCheckoutCmdOld);

    % �V�����o�[�W�����̃��f���t�@�C�����`�F�b�N�A�E�g
    newModelPath = fullfile(tempDir, 'new_model.slx');
    gitCheckoutCmdNew = sprintf('git -C %s show %s:%s > %s', gitRepoPath, newCommit, modelRelativePath, newModelPath);
    system(gitCheckoutCmdNew);

    % ���ɊJ���Ă��铯���̃��f�������
    try
        close_system('old_model', 0); % �ύX��ۑ������ɕ���
    catch
        % ���f�����J����Ă��Ȃ��ꍇ�̗�O�𖳎�
    end

    try
        close_system('new_model', 0); % �ύX��ۑ������ɕ���
    catch
        % ���f�����J����Ă��Ȃ��ꍇ�̗�O�𖳎�
    end

    % visdiff�֐����g�p����2�̃��f���t�@�C�����r���A������\��
    comparisonReport = visdiff(oldModelPath, newModelPath);

    % ��r���|�[�g��HTML�`���ŕۑ����邽�߂̃f�B���N�g�����w�肵�܂�
    reportDir = 'path/to/save/report';
    if ~exist(reportDir, 'dir')
        mkdir(reportDir);
    end

    % ��r���|�[�g��HTML�`���ŕۑ�
    reportFileName = fullfile(reportDir, 'model_comparison_report.html');

    % HTML�t�@�C���Ƃ��Ĕ�r���|�[�g��ۑ����邽�߂�slxmlcomp.export���g�p���܂�
    filter(comparisonReport, 'unfiltered');
    publish(comparisonReport, 'html'); % OutputDir���w��
    
    % ���̃u�����`�ɖ߂�܂�
    system(sprintf('git -C %s checkout %s', gitRepoPath, currentBranch));
    
    % ���|�[�g�t�@�C�����X�V����Ă���΁Agit add��git commit�����s
    [status, changedFiles] = system(sprintf('git -C %s status --porcelain', gitRepoPath));
    if status == 0 && contains(changedFiles, 'model_comparison_report.html')
        system(sprintf('git -C %s add %s', gitRepoPath, reportFileName));
        system(sprintf('git -C %s commit -m "Update: Model comparison report updated."', gitRepoPath));
    end
    
    % �ꎞ�u�����`���폜���܂�
    system(sprintf('git -C %s branch -D %s', gitRepoPath, tempBranchName));

    % �������b�Z�[�W
    disp(['���|�[�g���ۑ�����܂���: ', reportFileName]);

catch ME
    % �G���[�������Ɍ��̃u�����`�ɖ߂�
    system(sprintf('git -C %s checkout %s', gitRepoPath, currentBranch));
    system(sprintf('git -C %s branch -D %s', gitRepoPath, tempBranchName));
    rmdir(tempDir, 's'); % �ꎞ�f�B���N�g�����폜
    rethrow(ME);
end

% �ꎞ�f�B���N�g�����폜���܂�
rmdir(tempDir, 's');