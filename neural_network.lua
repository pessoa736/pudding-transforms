


-- funcao de ativacao / activation function
function sigm(n)
    local max = math.max
    local n = max(0, n)
    return n/(n+1)
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

                                if DEBUGMODE and NEURALNETWORKTEST then print("valor recebido: "..item, "valor ativado: "..result) end
                                
                                return result
                            end
                        )
                    end
                    
                    if DEBUGMODE and NEURALNETWORKTEST then print("\nvisualizando as camadas e pesos: \n"..tostring(s)) end
                end,

                inputsset = function(s, inputs)
                    if DEBUGMODE and NEURALNETWORKTEST then print("") end
                    if DEBUGMODE then print("inputs setados") end

                    s.layers[1]=s.layers[1]:modify(
                        function(i, j, m)
                            local result = inputs[i][j]
                            
                            if DEBUGMODE and NEURALNETWORKTEST then print("input: "..j.." = "..result) end
                            
                            return result
                        end
                    )

                    if DEBUGMODE and NEURALNETWORKTEST then print("") end
                
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
  
if DEBUGMODE and NEURALNETWORKTEST then
    local i=0
    print "\n\n---- testing neural network ----"
    nn = criar_rede_neural({2, 4, 4, 3})
    nn:inputsset({{2,3}})
    
    
    while i<1 do
        nn:think()
        i=i+1
    end
end
  
