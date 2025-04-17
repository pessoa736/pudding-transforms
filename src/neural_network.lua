


-- funcao de ativacao / activation function
local function sigm(n)
    return 1/(1+1/math.exp(n))
end

local function derivate(f, n)
    return (f(n+0.001)-f(n))/0.001
end


local function serialize(t, tab_level)
    local function tab_series(numTabs)
        local str=""
        for i=0, numTabs do
            str=str.."\t"
        end
        return str
    end

    local tab_level = tab_level or -1

    local tostr ="{" 

    for k, v in pairs(t) do
        if type(k) == "string" then 
            tostr = tostr .. "\n".. tab_series(tab_level+1) .. k .. " = "
        elseif type(k) == "number" then
            tostr = tostr .. "\n".. tab_series(tab_level+1) .. "[" .. k .. "]="
        end
        
        if type(v) == "table" then
            tostr = tostr .. serialize(v, tab_level + 1)
        elseif type(v) == "string" then
            tostr = tostr .. string.format("%q", v)
        else
            tostr = tostr .. tostring(v)
        end
        tostr = tostr .. ","
    end

    tostr = tostr .. "\n" .. tab_series(tab_level) .. "}"
    
    return tostr
end

-- funcao para criar a rede neural / function to create the neural network
function criar_rede_neural(layers) 
    local nn = {
        sizelayers=layers,
        layers={},
        weight={}
    }

    for l = 1, #layers do
        local l2 = (l-1<=0 and 1 or l-1)
        nn.layers[l]= Matrix.new(1, layers[l], 0)
        nn.weight[l2]= Matrix.new(layers[l], layers[l2], 
            function() return math.random(-100, 100)/100 end
        )
    end
     
    return setmetatable(nn, 
        {
            __index = {
                think = function(s)
                    for l = 2, #s.sizelayers do
                        local l2 = (l-1<=0 and 1 or l-1)
                        local lt = s.weight[l2]:transpose()
                        local bias = Matrix.new(s.layers[l].nrows, s.layers[l2].ncols, function() return math.random(0,20)/100 end)
            
                        s.layers[l] = (s.layers[l-1]+bias) * lt
            
                        s.layers[l] = s.layers[l]:modify(
                            function(i, j, m) 
                                local item = m:get(i, j)
                                local result = sigm(item)

                                if DEBUGMODE then print("valor recebido: "..item, "valor ativado: "..result) end
                                
                                return result
                            end
                        )
                    end
                    
                    if DEBUGMODE then print("\nvisualizando as camadas e pesos: \n"..tostring(s)) end
                    if #s.sizelayers == l then
                        return s.layers[l]
                    end
                end,
                backpropagation = function(s, args)
                    local args = args or {}
                    local target = args.target or Matrix.new(1, s.sizelayers[#s.sizelayers], 0)
                    local learning_rate = args.learning_rate or 0.01
                    local L = #s.sizelayers  
                    local delta = {}         
                
                    delta[L] = s.layers[L]:modify(function(i, j, m)
                        local d_sigmoid = m:get(i, j) * (1 - m:get(i, j))
                        local erro = m:get(i, j) - target:get(i, j)
                        return erro * d_sigmoid
                    end)

                    for l = L - 1, 2, -1 do
                        
                        local next_delta = delta[l + 1]
                        if DEBUGMODE then print("next_delta: "..tostring(next_delta)) end	

                        local erro = next_delta * s.weight[l] 
                        if DEBUGMODE then print("erro: "..tostring(erro)) end

                        
                        delta[l]  = s.layers[l]:modify(function(i, j, m)
                            local d_sigmoid = m:get(i, j) * (1 - m:get(i, j))
                            return  erro:get(i,j) * d_sigmoid
                        end)

                        if DEBUGMODE then print("delta: "..tostring(delta[l])) end
                    end
                
                    for l = 1, L - 1 do
                        local ativacao_prev = s.layers[l]
                        local delta_next = delta[l + 1]
                        
                        if DEBUGMODE then print("ativacao_prev: "..tostring(ativacao_prev)) end
                        local grad = delta_next:transpose() * ativacao_prev
                        
                        if DEBUGMODE then print("grab: ".. tostring(grad)) end
                        local nivel_de_aprendizagem = ( learning_rate * grad)
                        
                        if DEBUGMODE then print("nivel de aprendizagem: "..tostring(nivel_de_aprendizagem)) end
                        if DEBUGMODE then print(s.weight[l]) end
                        
                        s.weight[l] = s.weight[l] -  nivel_de_aprendizagem
                    end
                end,
                inputsset = function(s, inputs)
                    if DEBUGMODE then print("") end
                    if DEBUGMODE then print("inputs setados") end

                    s.layers[1]=s.layers[1]:modify(
                        function(i, j, m)
                            local result = inputs[i][j]
                            
                            if DEBUGMODE  then print("input: "..j.." = "..result) end
                            
                            return result
                        end
                    )

                    if DEBUGMODE then print("") end
                
                end,
                save = function(s, name)
                    local model = "return "..serialize(s)
                    local name = name or "test"

                    local file = assert(io.open("models/"..name..".lua", "w"))
                    if file then
                        file:write(model)
                        file:close()
                    else
                        print("Erro ao abrir o arquivo para escrita.")
                    end
                end
            },
            __tostring = function(s)
                local str = "neural_network: { "
                
                for k, v in ipairs(s.layers) do
                    str = str .. "\n\tlayer " .. k ..":\n".. tostring(v) 
                end
                
                for k, v in ipairs(s.weight) do
                    str = str .. "\n\tweight " .. k ..":\n".. tostring(v) 
                end
                
                str = str .. "\n}"
                
                return str
            end
        }
    )
end




  
if  NEURALNETWORKTEST then
    local i=0
    print "\n\n---- testing neural network ----"
    local nn = criar_rede_neural({2,2,1})
    nn:inputsset({{2, 3}})
    
    while i<1000 do
        nn:think()
        nn:backpropagation()
        i=i+1
        print(i)
    end
    nn:save()
end
  
