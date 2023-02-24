



















































































local getfenv, setfenv = assert(getfenv), assert(setfenv)
local setmeta, setmetatable = assert(setmetatable), nil
local tostring = assert(tostring)



local library;















local function noidx(tab, key)
   error("hey. hey! this is library: ." .. tostring(key))
end

local Lib_M = { __index = use "gadget:oops",
                __newindex = noidx,
                __sunt = { [library] = true } }

local rawget, rawset = assert(rawget)






function library(fenv)
   local env = fenv or getfenv(2)
   local lib = setmetatable({}, Lib_M)
   local function idx(_env, k)
      local v = rawget(lib, k)
      if v ~= nil then
         return v
      end
      return env[k]
   end
   local function newidx(_env, k, v)
      rawset(lib, k, v)
   end
   local _E = setmeta({}, { __index = idx, __newindex = newidx })
   setfenv(2, _E)

   return lib
end



return library

