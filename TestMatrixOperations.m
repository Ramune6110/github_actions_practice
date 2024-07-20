function tests = testMatrixOperations
    tests = functiontests(localfunctions);
end

function testMatrixAdd(testCase)
    A = [1, 2; 3, 4];
    B = [5, 6; 7, 8];
    expected = [6, 8; 10, 12];
    actual = matrixAdd(A, B);
    testCase.verifyEqual(actual, expected);
end

function testMatrixSubtract(testCase)
    A = [5, 6; 7, 8];
    B = [1, 2; 3, 4];
    expected = [4, 4; 4, 4];
    actual = matrixSubtract(A, B);
    testCase.verifyEqual(actual, expected);
end

function testMatrixMultiply(testCase)
    A = [1, 2; 3, 4];
    B = [2, 0; 1, 2];
    expected = [4, 4; 10, 8];
    actual = matrixMultiply(A, B);
    testCase.verifyEqual(actual, expected);
end

function testMatrixAddDifferentSizes(testCase)
    A = [1, 2, 3];
    B = [4, 5, 6];
    expected = [5, 7, 9];
    actual = matrixAdd(A, B);
    testCase.verifyEqual(actual, expected);
end

function testMatrixSubtractDifferentSizes(testCase)
    A = [10, 20, 30];
    B = [1, 2, 3];
    expected = [9, 18, 27];
    actual = matrixSubtract(A, B);
    testCase.verifyEqual(actual, expected);
end

function testMatrixMultiplyIncompatibleSizes(testCase)
    A = [1, 2, 3];
    B = [4, 5; 6, 7];
    testCase.verifyError(@() matrixMultiply(A, B), 'MATLAB:dimagree');
end
