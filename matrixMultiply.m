function result = matrixMultiply(A, B)
    if size(A, 2) ~= size(B, 1)
        error('MATLAB:dimagree', 'Inner matrix dimensions must agree.');
    end
    result = A * B;
end