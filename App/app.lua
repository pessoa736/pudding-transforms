local lapis = require("lapis")
local config = require("lapis.config").get()

local helpers = require("static.scripts.helpers")

local app = lapis.Application()
app:enable("etlua")

app:before_filter(function(self)
  self.helpers = helpers
end)
  
app:get("home", "/", function()
  return { render = "index"}
end)
app:get("visualizador de modelo", "/visualizador-de-modelo", function()
  return { render = "visualizador-de-modelo"}
end)

return app
