





















local getfenv, setfenv = assert(getfenv), assert(setfenv)
local setmeta, setmetatable = assert(setmetatable), nil

local function library(fenv)
   local env = fenv or getfenv(2)
   local lib = {}
   local function idx(_env, k)
      local v = lib[k]
      if v ~= nil then
         return v
      end
      return env[k]
   end
   local function newidx(_env, k, v)
      lib[k] = v
   end
   local _E = setmeta({}, { __index = idx, __newindex = newidx })
   setfenv(2, _E)

   return lib
end



return library

