

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
    if _ENV.DEBUGMODE then print(lib.." is loaded") end
  end
end


