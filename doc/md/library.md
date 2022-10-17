# Library


  A system for writing libraries\.

Bridge modules serve a number of purposes, one common pattern being a library\.

This is a simple affordance which leverages Lua's first class environments to
let us write them with less ceremony\.

### use

Simple:

```lua
local lib = use "cluster:library" ()

local an_upvalue = 5

function giveFive()
   return an_upvalue
end

slot = "I'm lib.slot!"

return lib -- { giveFive = giveFive, slot = slot }
```

## Design

We build a function metatable which assigns 'globals' to a given return value,
but without leaving the library bound to the fenv\.

Not much to it, let's go\.


### scry

This is a marvelous example of a deep interaction which scry must be able to
comprehend\.

The actual function has no conditions at all, but it has profound side effects\.

This is yet another kind of effect we need to track\.  How does one even
annotate "changes the calling environment"?

Hmm\. There's something here for sure, because this is analogous to changing an
upvalue, or other 'side effects' which actually stay inside the system\.

### library\(fenv?\): lib: t

Takes either the passed fenv, or takes the fenv of the calling function\.

Sets up a custom environment which puts all globals in `lib`, without putting
a metatable on `lib` itself, sets that environment on the calling context,
and returns `lib`\.

```lua
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
```

```lua
return library
```
