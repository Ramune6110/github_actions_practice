function tests = testSimulinkModel
    tests = functiontests(localfunctions);
end

function testModelOutput(testCase)
    % ���f���̓��̓f�[�^
    inputTime = (0:0.1:10)';
    inputData = sin(inputTime);
    
    % Simulink.SimulationInput�I�u�W�F�N�g�̍쐬
    in = Simulink.SimulationInput('sample');
    
    % �O�����̓f�[�^�̐ݒ�
    inputDataset = timeseries(inputData, inputTime);
    in = in.setExternalInput(inputDataset);
    
    % ���f���̃V�~�����[�V�������s
    out = sim(in);
    
    % ���f���̏o�̓f�[�^�̎擾
    outputData = out.logsout.getElement('outputSignal').Values.Data;
    
    % ���҂����o�̓f�[�^�̌v�Z
    expectedOutput = 2 * inputData;
    
    % �o�̓f�[�^�̌���
    testCase.verifyEqual(outputData, expectedOutput, 'AbsTol', 1e-3);
end
