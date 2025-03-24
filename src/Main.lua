DEBUGMODE = os.getenv("DEBUGMODE") 	                == "true";
TOKENIZERTEST = os.getenv("TOKENIZERTEST")          == "true";  
MATRIXTEST = os.getenv("MATRIXTEST")                == "true";
NEURALNETWORKTEST = os.getenv("NEURALNETWORKTEST")  == "true";

print("\nsettings:")
print("\tdebug mode: " .. (DEBUGMODE and "true" or "false"))
print("\ttokenizer test: " .. (TOKENIZERTEST and "true" or "false"))
print("\tmatrix test: " .. (MATRIXTEST and "true" or "false"))
print("\tneural network test: " .. (NEURALNETWORKTEST and "true" or "false"))
print("\n\n")

-- pacotes a serem carregados / packages to be loaded
pacotes= {
  "Tokenizer",
  "Matriz",
  "neural_network",
  "training"
}

-- carregamento dos pacotes / loading packages
for _, pacote in ipairs(pacotes) do
  local pacote_carregado = false

  for pacote_carregado in pairs(package.loaded) do
    if pacote == pacote_carregado then pacote_carregado = true end
  end

  if not pacote_carregado then 
    require(pacote) 
    if DEBUGMODE then print(pacote.." is loaded") end
  end
end


