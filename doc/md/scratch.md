# Scratch

A namespace which is guaranteed not to be the final home of anything\.

```lua
local scratch = {}
```

```lua
local core = require "qor:core" -- last one I promise
```

## just\(object\)

```lua
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
```


## bones\(tab\)

Returns a table with values other than `true` or `false` replaced with the
type, recursively doing the same for all subtables\.

We can do a nice trick here, and use `__metatable` to return the origin
metatable, while providing a metatable which doesn't responed to any of the
metamethods present on it\.

All of the actual traits are coalesced onto the skeleton, this is intended for
identity stuff\.

```lua
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
```


```lua
return scratch
```
