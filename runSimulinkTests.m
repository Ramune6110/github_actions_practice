function runSimulinkTests
    % ���f���̃R���p�C��
    load_system('sample');
    
    % �e�X�g�t�@�C���̍쐬
    testFile = sltest.testmanager.TestFile('myTestFile.mldatx');
    testSuite = testFile.createTestSuite('myTestSuite');
    testCase = testSuite.createTestCase('simulation', 'TestCase');
    
    % �e�X�g�P�[�X�ɃV�~�����[�V�����ݒ��ǉ�
    testCase.setProperty('ModelName', 'myModel');
    
    % �e�X�g�P�[�X�ɓ��̓f�[�^��ݒ�
    inputTime = (0:0.1:10)';
    inputData = sin(inputTime);
    testInput = Simulink.SimulationData.Dataset;
    testInput = testInput.addElement(timeseries(inputData, inputTime), 'inputSignal');
    testCase.setProperty('ExternalInput', testInput);
    
    % �J�o���b�W�ݒ��ǉ�
    cvSettings = sltest.testmanager.coverageSettings('AllTestsInTestFile', true);
    testCase.setProperty('CoverageSettings', cvSettings);
    
    % �e�X�g�̎��s
    results = testFile.run;
    
    % �e�X�g���ʂ̕ۑ�
    results.exportResults('testResults.mldatx');
    
    % �J�o���b�W���ʂ̕ۑ�
    cvData = results.getCoverageData;
    save('coverageResults.mat', 'cvData');
end
