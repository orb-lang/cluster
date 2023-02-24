# Library


  A system for writing libraries\.

Bridge modules serve a number of purposes, one common pattern being a library\.

This is a simple affordance which leverages Lua's first class environments to
let us write them with less ceremony, while providing better error messages\.


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

It is an error to assign new values to a the lib table directly, or to look up
slots which are nil\.


## Design

We build a function metatable which assigns 'globals' to a given return value,
but without leaving the library bound to the fenv\.

The library itself gets a metatable which prohibits ordinary lvalue assignment,
and responds to missed indices with an informative error message\.

This means libraries build using this system don't require the endless
assertions to prevent the Null Pointer Problem\.

Note that we don't go the extra distance to prevent reassignment of existing
slots\.  I put an error\-throwing newindex on there because it's free, not to
provide a hard guarantee that the user doesn't do something silly\.  That's
more of Scry's wheelhouse\.

Speaking of which\!


### scry

This is a marvelous example of a deep interaction which scry must be able to
comprehend\.

The actual function has no conditions at all, but it has profound side effects\.

This is yet another kind of effect we need to track\.  How does one even
annotate "changes the calling environment"?

Hmm\. There's something here for sure, because this is analogous to changing an
upvalue, or other 'side effects' which actually stay inside the system\.


## library\(fenv?\): lib: t

Takes either the passed fenv, or takes the fenv of the calling function\.

Sets up a custom environment, which puts all globals in `lib`, sets that
environment on the calling context, and returns `lib`\.

`lib` itself gets a metatable which gives informative errors on missing
indexes, and prevents direct assignment\.

For one thing, nothing but the library should be filling slots on the table,
that much should be obvious\.

But furthermore, if using this pattern, the library should be created at the
top and then returned at the bottom, everything else should be made global or
local\.  Prohibiting lvalue assignment ensures this style is followed\.

```lua
local getfenv, setfenv = assert(getfenv), assert(setfenv)
local setmeta, setmetatable = assert(setmetatable), nil
local tostring = assert(tostring)
```

```lua
local library;
```


### Lib\_M

I'll probably move this to core, so I can use it in core\.

That would imply pcalling the gadget dependency and using a simpler error
function if it's not available, because core isn't allowed to have
dependencies\.

So `__sunt` is a 'manual' Set\.  `idest` doesn't actually check, nor should it\.


```lua
local function noidx(tab, key)
   error("hey. hey! this is library: ." .. tostring(key))
end

local Lib_M = { __index = use "gadget:oops",
                __newindex = noidx,
                __sunt = { [library] = true } }

local rawget, rawset = assert(rawget)
```


### library\(fenv\)

```lua
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
```

```lua
return library
```
