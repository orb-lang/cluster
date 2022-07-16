




















local conn = assert(require "bridge" . modules_conn)






local get_all_project = [[
SELECT project_id as project, name FROM project;
]]




local project = {}

for i, id, name in conn:prepare(get_all_project):cols() do
   project[name] = id
end








local get_distinct_modules = [[
SELECT DISTINCT name FROM module
WHERE module.project = :id
GROUP BY name
ORDER BY MAX(module.time) DESC
]]







local EZ = {__meta = {__keys = project}}



local get_mods = conn:prepare(get_distinct_modules)

local Mod_M = {}

function EZ.__index(tab, name)
   if project[name] then
      local modmap = {name}
      local modules = get_mods :bind(project[name]) :resultset 'i' [1]
      get_mods :clearbind() :reset()
      local modmap = {}
      for i, str in ipairs(modules) do
        -- what we actually do here is kinda fun but not now
        modmap[str] = true
      end

      return setmetatable(modmap, Mod_M)
   end
end









function Mod_M.__call(mod)
   return require (mod[1] .. ":" .. mod[1])
end




return setmetatable({}, EZ)

