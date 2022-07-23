




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
















local allpairs = assert(core.table.allpairs)

local function bones(tab, limit)
   assert(type(tab) == 'table', 'can only handle tables for now')
   local dupes = {}
   local count;
   local function eviscerate(tab, depth)
      if dupes[tab] then
         return dupes[tab]
      end
      local new = {}
      dupes[tab] = new
      for key, value in allpairs(tab) do
         local key_t, val_t = type(key), type(value)
         -- we'll deal with the consequences of key_t someday
         -- for instance trying to collapse the type of the array portion
         -- in some useful cases
         if val_t == 'table' then
            if depth and depth > limit then
               new[key] = val_t
            elseif depth then
               new[key] = eviscerate(value, depth + 1)
            else
               new[key] = eviscerate(value)
            end
         else
            new[key] = val_t
         end
      end

      -- handle metatable for new and return it
      return new
   end
   if limit then
      return eviscerate(tab, 1)
   else
      return eviscerate(tab)
   end
end
scratch.bones = bones




return scratch

