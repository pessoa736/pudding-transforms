


local special_characters={
  ["a"]="áâãàäåæāăąª",
  ["c"]="çćĉčč̣",
  ["d"]="ðďđḍ",
  ["e"]="éêèëēėęěĕẹ",
  ["g"]="gʻĝģğ",
  ["h"]="ĥ",
  ["i"]="íìîïīįıï",
  ["j"]="ǰǰ̣ĵ",
  ["k"]="ķ",
  ["l"]="ĺļľłl·l·",
  ["n"]="n̈ñńņňŉŋɲṅ",
  ["o"]="óôõoʻòöøōŏőœơọº",
  ["r"]="ŕř",
  ["s"]="ß§śŝšṣ̌şșṣ",
  ["t"]="þťŧțţṭ",
  ["u"]="úüùûūŭůűųưụ",
  ["w"]="ŵẁẃẅ",
  ["x"]="x̌",
  ["y"]="ÿýỳŷ",
  ["z"]="źżžẓ̌"
}

--[[ 
    funcao para trocar o caractere especial pelo seu caractere normalizado  
    function to replace the special character with its equivalent character
]]
local function troca_caractere(letra_especial)
  local resultado = letra_especial
  
  for letra_normalizada, v in pairs(special_characters) do
    for _, c in utf8.codes(v) do

      if utf8.char(c) == letra_especial then
        resultado = letra_normalizada 
      end

    end
  end
  
  return resultado
end



-- funcao para normalizar o texto / function to normalize the text
local function normalizador_de_texto(texto)
  local novo_texto=""
  
  for n, c in utf8.codes(texto) do
    local caractere = utf8.char(c)
    novo_texto = novo_texto .. troca_caractere(caractere)
  end
  
  return novo_texto
end



-- funcao para transformar o texto em tabela / function to transform the text into a table
function transformador_de_texto_em_tabela(texto)
  local texto_normalizado = normalizador_de_texto(texto)
  local texto_sem_espacos = texto_normalizado:gsub(" ", ",")
  
  local i = 0
  local palavras = texto_sem_espacos:gsub("%w+", 
    function(palavra)
      local resultado = '['..i..']="'..palavra..'"'
      i=i+1
      return resultado
    end
  )

  local funcao_que_cria_tabela, erro = load("return {"..palavras.."}")

  if funcao_que_cria_tabela then
    local ok, tabela_de_palavras = pcall(funcao_que_cria_tabela)
    
    return setmetatable(
      tabela_de_palavras,
      {__tostring = function(s) return "{"..palavras.."}" end}
    )

  else
    print("erro:" .. erro)
  end
  
end

if _ENV.DEBUGMODE and _ENV.TOKENIZERTEST then
  print(normalizador_de_texto("isso é um test de normalização de texto"))
  local tokens = transformador_de_texto_em_tabela("isso é um test de traformação de uma string em tabela")
  print(tokens)
end