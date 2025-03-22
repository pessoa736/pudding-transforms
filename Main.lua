#!/bin/bash/env lua

local libs= {
  "Matriz"
}

for _, lib in ipairs(libs) do
  local i = false
  for k in pairs(package.loaded) do
    if k == lib then
      i=true
    end
  end
  if not i then
    require(lib)
    print(lib.." is loaded")
  end
end

local libs= {
  "Matriz",
  "Tokenizer"
}

for _, lib in ipairs(libs) do
  local i = false
  for k in pairs(package.loaded) do
    if k == lib then
      i=true
    end
  end
  if not i then
    require(lib)
    print(lib.." is loaded")
  end
end

-- settings
debugmode= true
matrixtest = false



function sigm(n)
  local max = math.max
  local n = max(0, n)
  return n/(n+1)
end

function create_neural_network(layers) 
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
   
  return setmetatable(nn, {
    __index = {
      think = function(s)
        for l = 2, #s.sizelayers do
          print(s.sizelayers[l-1])
          
          local l2 = (l-1<=0 and 1 or l-1)
          local lt = s.weight[l2]:transpose()
          local bias = Matrix.new(s.layers[l].nrows, s.layers[l2].ncols, function() return math.random(0,20)/100 end)
          
          s.layers[l] = (s.layers[l-1]+bias) * lt
          
          s.layers[l] = s.layers[l]:modify(
            function(i, j, m) 
              local item = m:get(i, j)
              local result = sigm(item)
              print(item, result)
              return result
            end
          )
          
          if debugmode then print(s) end
        end
      end,
      inputsset = function(s, inputs)
        --print(s)
        s.layers[1]=s.layers[1]:modify(
          function(i, j, m)
            local result = inputs[i][j]
            print(result)
            return result
          end
        )
      end,
    },
    __tostring = function(s)
      local str = ""
      str = str .. "neural_network: { "
      for k, v in ipairs(s.layers) do
        str = str .. "\n\tlayer " .. k ..":\n".. tostring(v) 
      end
      for k, v in ipairs(s.weight) do
        str = str .. "\n\tweight " .. k ..":\n".. tostring(v) 
      end
      str = str .. "\n}"
      return str
    end
  })
end

local i=0
if debugmode==true then
  print "\n\n---- testing neural network ----"
  nn = create_neural_network({2, 4, 4, 3})
  nn:inputsset({{1,2}})
  
  
  while i<1 do
   nn:think()
   i=i+1
  end
end

