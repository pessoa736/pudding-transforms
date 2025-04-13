

-- pacotes a serem carregados / packages to be loaded
pacotes= {
  "env",
  "Tokenizer",
  "Matriz",
  "neural_network",
  "training",
  "lapis"
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

print("\nsettings:")
print("\tdebug mode: " .. (DEBUGMODE and "true" or "false"))
print("\ttokenizer test: " .. (TOKENIZERTEST and "true" or "false"))
print("\tmatrix test: " .. (MATRIXTEST and "true" or "false"))
print("\tneural network test: " .. (NEURALNETWORKTEST and "true" or "false"))
print("\n\n")




