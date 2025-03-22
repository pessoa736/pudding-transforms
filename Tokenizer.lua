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


local char_esp={
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


local function checkchar(letter)
  local result = letter
  for k, v in pairs(char_esp) do
    for _, c in utf8.codes(v) do
      if utf8.char(c) == letter then
        result = k 
      end
    end
  end
  return result
end

local function normalaize_text(str)
  local newstring=""
  for n, c in utf8.codes(str) do
    local c = utf8.char(c)
    newstring = newstring .. checkchar(c)
  end
  return newstring
end

print(normalaize_text("isso é um test de normalização de texto"))

tokenizer = function(str)
  local normalized = normalaize_text(str)
  local removespace = normalized:gsub(" ", ",")
  local i = 0
  local words = removespace:gsub("%w+", 
    function(s)
      local result =  '['..i..']="'..s..'"'
      i=i+1
      return result
    end
  )
    local tablefunction, err=load("return {"..words.."}")
    if tablefunction then
      local ok, table_ = pcall(tablefunction)
      return setmetatable(
        table_,
        {__tostring = function(s) return "{"..words.."}" end}
      )
    else
      print("erro:" .. err)
    end
  --return tablefunction
end
debugtokenizer=true
if debugtokenizer then
  local tokens = tokenizer("isso é um test de traformação de uma string em tabela")
  print(tokens)
end