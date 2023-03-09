# Basis


Tools for programming by contract\.


### Introduction

Reminder that Cluster's interface will be unstable for the foreseeable future\.

Contracts are an old concept which fits somewhere between compile\-time and
run\-time typing\.

It's not clear in detail how contracts and molds will work, the intention is
both to provide, at low cost, some of what static typing gives a language
which has it, and work on a basis for a gradually typed language over Lua,
using inference, ADTs and flow types, and such niceties\.

```lua
local core = require "qor:core"
```


## basis

  Basis predicates either return the value or `nil`, depending on if the value
meets the contract\.

The exceptions are `none`, `isnil`, and sometimes `isboolean`, which must
return `true` to be useful predicates\.  These also return `nil` if the
predicate doesn't match, as this is as much consistency as we can offer\.

These explicitly return `nil`, meaning an actual `nil` is placed on the stack\.
There are edge cases where this distinction is a difference\.

```lua
local basis = {}
```


### Truthiness: some, none

These are carefully named\.

I think we require this semantics for None in order to get rational flow
typing in Lua\.   We'll see\.

```lua
function basis.some(a)
   if a then return a end
   return nil
end
```

```lua
function basis.none(a)
   if (not a) then
      return (not a)
   else
      return nil
   end
end
```


### primitive types

Lua has eight primitive types, with LuaJIT bringing the total to nine\.

```lua
function basis.isnil(a)
   return (a == nil) or nil
end
```


```lua
function basis.isboolean(a)
   if type(a) == 'boolean' then return true end
   return nil
end
```

```lua
function basis.isnumber(a)
   if type(a) == 'number' then return a end
   return nil
end
```

```lua
function basis.isstring(a)
   if type(a) == 'string' then return a end
   return nil
end
```

```lua
function basis.isfunction(a)
   if type(a) == 'function' then return a end
   return nil
end
```

```lua
function basis.istable(a)
   if type(a) == 'table' then return a end
   return nil
end
```

```lua
function basis.isthread(a)
   if type(a) == 'thread' then return a end
   return nil
end
```

```lua
function basis.isuserdata(a)
   if type(a) == 'userdata' then return a end
   return nil
end
```

```lua
function basis.iscdata(a)
   if type(a) == 'cdata' then return a end
   return nil
end
```


## shape

Returns whether an object is valid to use with a particular syntax\.


### hasmetamethods

  We have a helper callable table for constructing these closures\.

  \#Todo make hasmetamethod a closurizer like hasfield\.

```lua
local hasmetamethod = core.meta.hasmetamethod
```

```lua
local hascall;
```


## law

The asserted form of basis\.

```lua
local law = {}
```

```lua
do
   local function lay_down_the_law(law, name, predicate)
      local fail_str = "argument fails " .. name
      law[name] = function(a)
         return assert(predicate(a), fail_str)
      end
   end

   for name, predicate in pairs(basis) do
      lay_down_the_law(law, name, predicate)
   end
end
```

```lua
return { basis = basis, law = law }
```
