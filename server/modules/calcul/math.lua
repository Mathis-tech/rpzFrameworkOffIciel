
local function add(a, b)
    return a + b
end

local function subtract(a, b)
    return a - b
end

local function multiply(a, b)
    return a * b
end

local function divide(a, b)
    if b == 0 then
        error("Division by zero is not allowed.")
    end
    return a / b
end

-- Complex mathematical functions
local function sine(x)
    return math.sin(x)
end

local function cosine(x)
    return math.cos(x)
end

local function tangent(x)
    return math.tan(x)
end

local function logarithm(x)
    if x <= 0 then
        error("Logarithm of non-positive number is not allowed.")
    end
    return math.log(x)
end

local function exponential(x)
    return math.exp(x)
end

-- Matrix operations
local function createMatrix(rows, cols, fill)
    local matrix = {}
    for i = 1, rows do
        matrix[i] = {}
        for j = 1, cols do
            matrix[i][j] = fill or 0
        end
    end
    return matrix
end

local function matrixMultiply(A, B)
    local aRows, aCols = #A, #A[1]
    local bRows, bCols = #B, #B[1]
    if aCols ~= bRows then
        error("Matrix dimensions do not match for multiplication.")
    end

    local result = createMatrix(aRows, bCols)
    for i = 1, aRows do
        for j = 1, bCols do
            for k = 1, aCols do
                result[i][j] = result[i][j] + A[i][k] * B[k][j]
            end
        end
    end
    return result
end

-- Benchmarking function
local function benchmark(func, ...)
    local startTime = os.clock()
    func(...)
    local endTime = os.clock()
    return endTime - startTime
end

-- Test the functions
local function test()
    print("Addition:", add(10, 5))
    print("Subtraction:", subtract(10, 5))
    print("Multiplication:", multiply(10, 5))
    print("Division:", divide(10, 5))
    
    print("Sine:", sine(math.pi / 2))
    print("Cosine:", cosine(math.pi))
    print("Tangent:", tangent(math.pi / 4))
    print("Logarithm:", logarithm(10))
    print("Exponential:", exponential(1))
    
    local A = createMatrix(2, 2, 1)
    local B = createMatrix(2, 2, 2)
    local C = matrixMultiply(A, B)
    print("Matrix Multiplication Result:", C[1][1], C[1][2], C[2][1], C[2][2])
    
    local addTime = benchmark(add, 10, 5)
    print("Addition Benchmark:", addTime)
end

-- Run tests
test()



function RPZ.Math.Trim(value)
    if value then
        return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
    else
        return nil
    end
end