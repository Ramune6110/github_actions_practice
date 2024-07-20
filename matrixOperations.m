function result = matrixAdd(A, B)
    if ~isequal(size(A), size(B))
        error('MATLAB:dimagree', 'Matrix dimensions must agree.');
    end
    result = A + B;
end

function result = matrixSubtract(A, B)
    if ~isequal(size(A), size(B))
        error('MATLAB:dimagree', 'Matrix dimensions must agree.');
    end
    result = A - B;
end

function result = matrixMultiply(A, B)
    if size(A, 2) ~= size(B, 1)
        error('MATLAB:dimagree', 'Inner matrix dimensions must agree.');
    end
    result = A * B;
end
