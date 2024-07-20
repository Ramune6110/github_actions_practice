function runSimulinkTests
    % モデルのコンパイル
    load_system('sample');
    
    % テストファイルの作成
    testFile = sltest.testmanager.TestFile('myTestFile.mldatx');
    testSuite = testFile.createTestSuite('myTestSuite');
    testCase = testSuite.createTestCase('simulation', 'TestCase');
    
    % テストケースにシミュレーション設定を追加
    testCase.setProperty('ModelName', 'myModel');
    
    % テストケースに入力データを設定
    inputTime = (0:0.1:10)';
    inputData = sin(inputTime);
    testInput = Simulink.SimulationData.Dataset;
    testInput = testInput.addElement(timeseries(inputData, inputTime), 'inputSignal');
    testCase.setProperty('ExternalInput', testInput);
    
    % カバレッジ設定を追加
    cvSettings = sltest.testmanager.coverageSettings('AllTestsInTestFile', true);
    testCase.setProperty('CoverageSettings', cvSettings);
    
    % テストの実行
    results = testFile.run;
    
    % テスト結果の保存
    results.exportResults('testResults.mldatx');
    
    % カバレッジ結果の保存
    cvData = results.getCoverageData;
    save('coverageResults.mat', 'cvData');
end
