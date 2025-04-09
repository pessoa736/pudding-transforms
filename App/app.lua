local lapis = require("lapis")
local config = require("lapis.config").get()

local app = lapis.Application()
app:enable("etlua")


--app:match("/", function(self)
--  return self:html(function()
--    head()
--  end)
-- end)
  
app:get("/", function()
  return { render = "index"}
end)

return app
