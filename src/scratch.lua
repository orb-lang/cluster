




local scratch = {}



local core = require "qor:core" -- last one I promise





function scratch.just(object)
   local err_msg = "value is not just a "
                   .. type(object) .. " " .. tostring(object)
   return function(tested)
      if object == tested then
         return true
      end
      return nil, err_msg
   end
end
















local allkeys = assert(core.table.allkeys)

local function bones(tab)
   assert(type(tab) == 'table', 'can only handle tables for now')
   local dupes = {}
   local function eviscerate(tab)
      if dupes[tab] then
         return dupes[tab]
      end
      local new = {}
      for key, value in allkeys(tab) do
         local key_t, val_t = type(key), type(value)
         -- we'll deal with the consequences of key_t someday
         -- for instance trying to collapse the type of the array portion
         -- in some useful cases
         if val_t == 'table' then
            new[key] = eviscerate(value)
         else
            new[key] = val_t
         end
      end
      -- handle metatable for new and return it
      return new
   end
end
scratch.bones = bones




return scratch

