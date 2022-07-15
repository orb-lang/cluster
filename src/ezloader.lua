




















local conn = assert(require "bridge" . modules_conn)






local get_all_project = [[
SELECT project_id as project, name FROM project;
]]




local project = {}

for i, id, name in conn:prepare(get_all_project):cols() do
   project[name] = id
end




local get_distinct_modules = [[
SELECT DISTINCT module_id as ID, name FROM module
WHERE module.project = :id
GROUP BY name
ORDER BY MAX(module.time) DESC
]]







local EZ = {}



local get_mods = conn:prepare(get_distinct_modules)

function EZ.__index(tab, key)
   if project[key] then
      local modmap = {}
      for i, id, name in get_mods :bind(project[key]) :cols() do
         modmap[name] = id
      end
      -- we need one more metatable
      return modmap
   end
end




return setmetatable({}, EZ)

