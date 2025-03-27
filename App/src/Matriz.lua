-- Definição da "classe" Matrix
Matrix = {}
Matrix.__index = Matrix

-- Função para criar uma nova matriz
function Matrix.new(nrows, ncols, initial)
    local m = {
        nrows = nrows,
        ncols = ncols,
        data = {}
    }
    for i = 1, nrows do
        m.data[i] = {}
        for j = 1, ncols do
          if type(initial) == "function" then
            m.data[i][j] = initial(i, j)
          else
            m.data[i][j] = initial or 0
          end
        end
    end
    setmetatable(m, Matrix)
    return m
end

function Matrix.get(m, i, j)
  return m.data[i][j]
end

function Matrix.set(m, i, j, v)
  m.data[i][j]=v or 0
  return m
end


-- Função para exibir a matriz de forma amigável (sobrecarga do operador tostring)
function Matrix.__tostring(m)
    local s = ""
    for i = 1, m.nrows do
        s = s .. "| "
        for j = 1, m.ncols do
            s = s .. m.data[i][j] .. "\t"
        end
        s = s .. "|\n"
    end
    return s
end

function Matrix.modify(m, v)
  m = Matrix.new(
    m.nrows,
    m.ncols, 
    function(i, j) 
      return (type(v)=="function" and v(i, j, m) or v)
    end
  )
  return m
end

-- Operador de adição: soma elemento a elemento (necessita de dimensões iguais)
function Matrix.__add(a, b)
    if a.nrows ~= b.nrows or a.ncols ~= b.ncols then
        error("As matrizes devem ter as mesmas dimensões para adição.")
    end
    local result = Matrix.new(a.nrows, a.ncols)
    for i = 1, a.nrows do
        for j = 1, a.ncols do
            result.data[i][j] = a.data[i][j] + b.data[i][j]
        end
    end
    return result
end

-- Operador de subtração: subtrai elemento a elemento (necessita de dimensões iguais)
function Matrix.__sub(a, b)
    if a.nrows ~= b.nrows or a.ncols ~= b.ncols then
        error("As matrizes devem ter as mesmas dimensões para subtração.")
    end
    local result = Matrix.new(a.nrows, a.ncols)
    for i = 1, a.nrows do
        for j = 1, a.ncols do
            result.data[i][j] = a.data[i][j] - b.data[i][j]
        end
    end
    return result
end

-- Operador de multiplicação: trata tanto a multiplicação escalar quanto a multiplicação de matrizes
function Matrix.__mul(a, b)
    if type(a) == "number" then
        -- Multiplicação escalar: número * matriz
        local result = Matrix.new(b.nrows, b.ncols)
        for i = 1, b.nrows do
            for j = 1, b.ncols do
                result.data[i][j] = a * b.data[i][j]
            end
        end
        return result
    elseif type(b) == "number" then
        -- Multiplicação escalar: matriz * número
        local result = Matrix.new(a.nrows, a.ncols)
        for i = 1, a.nrows do
            for j = 1, a.ncols do
                result.data[i][j] = a.data[i][j] * b
            end
        end
        return result
    else
        -- Multiplicação de matrizes: o número de colunas de a deve ser igual ao número de linhas de b
        if a.ncols ~= b.nrows then
            error("Dimensões incompatíveis para multiplicação de matrizes. 1")
        end
        local result = Matrix.new(a.nrows, b.ncols)
        for i = 1, a.nrows do
            for j = 1, b.ncols do
                local sum = 0
                for k = 1, a.ncols do
                    sum = sum + a.data[i][k] * b.data[k][j]
                end
                result.data[i][j] = sum
            end
        end
        return result
    
    end
end


function Matrix.__idiv(a, b)
    if type(a) == "number" then
        -- Divisão escalar: número // matriz
        local result = Matrix.new(b.nrows, b.ncols)
        for i = 1, b.nrows do
            for j = 1, b.ncols do
                result.data[i][j] = math.floor(a / b.data[i][j])
            end
        end
        return result
    elseif type(b) == "number" then
        -- Divisão escalar: matriz // número
        local result = Matrix.new(a.nrows, a.ncols)
        for i = 1, a.nrows do
            for j = 1, a.ncols do
                result.data[i][j] = math.floor(a.data[i][j] / b)
            end
        end
        return result
    
    end
end


-- Operador unário para negação (-matriz)
function Matrix.__unm(m)
    local result = Matrix.new(m.nrows, m.ncols)
    for i = 1, m.nrows do
        for j = 1, m.ncols do
            result.data[i][j] = -m.data[i][j]
        end
    end
    return result
end

-- Operador de igualdade: verifica se duas matrizes são iguais elemento a elemento
function Matrix.__eq(a, b)
    if a.nrows ~= b.nrows or a.ncols ~= b.ncols then
        return false
    end
    for i = 1, a.nrows do
        for j = 1, a.ncols do
            if a.data[i][j] ~= b.data[i][j] then
                return false
            end
        end
    end
    return true
end

-- Função para transpor uma matriz
function Matrix.transpose(self)
    local result = Matrix.new(self.ncols, self.nrows)
    for i = 1, self.nrows do
        for j = 1, self.ncols do
            result.data[j][i] = self.data[i][j]
        end
    end
    return result
end

if DEBUGMODE and MATRIXTEST then
--   -- Exemplo de uso
  local A = Matrix.new(2, 3)
  A.data = {
      {1, 2, 3},
      {4, 5, 6}
  }
  
  local B = Matrix.new(2, 3)
  B.data = {
      {6, 5, 4},
      {3, 2, 1}
  }

  local C = A + B         -- Soma de matrizes
  local D = A - B         -- Subtração de matrizes
  local E = 2 * A         -- Multiplicação escalar
  local T = Matrix.transpose(A)  -- Transposta da matriz A
  
  print("Matriz A:")
  print(A)
  
  print("Matriz B:")
  print(B)
  
  print("A + B:")
  print(C)
  
  print("A - B:")
  print(D)
  
  print("2 * A:")
  print(E)
  
  print("Transposta de A:")
  print(T)
  
  -- Para multiplicação de matrizes, as dimensões devem ser compatíveis.
  local F = Matrix.new(3, 2)
  F.data = {
      {1, 2},
      {3, 4},
      {5, 6}
  }
  
  local G = A * F  -- Multiplicação de A (2x3) por F (3x2) resulta em uma matriz 2x2
  print("A * F:")
  print(G)
end