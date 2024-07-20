function tests = testSimulinkModel
    tests = functiontests(localfunctions);
end

function testModelOutput(testCase)
    % モデルの入力データ
    inputTime = (0:0.1:10)';
    inputData = sin(inputTime);
    
    % Simulink.SimulationInputオブジェクトの作成
    in = Simulink.SimulationInput('sample');
    
    % 外部入力データの設定
    inputDataset = timeseries(inputData, inputTime);
    in = in.setExternalInput(inputDataset);
    
    % モデルのシミュレーション実行
    out = sim(in);
    
    % モデルの出力データの取得
    outputData = out.logsout.getElement('outputSignal').Values.Data;
    
    % 期待される出力データの計算
    expectedOutput = 2 * inputData;
    
    % 出力データの検証
    testCase.verifyEqual(outputData, expectedOutput, 'AbsTol', 1e-3);
end
