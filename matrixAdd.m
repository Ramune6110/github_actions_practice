function result = matrixAdd(A, B)
    if ~isequal(size(A), size(B))
        error('MATLAB:dimagree', 'Matrix dimensions must agree.');
    end
    result = A + B;
end