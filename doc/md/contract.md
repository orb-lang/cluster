# Contract


Reminder that Cluster's interface will be unstable for the foreseeable future\.


### basis

  Basis predicates either return the value or `nil`, depending on if the value
meets the contract\.

```lua
local basis = {}
```

```lua
function basis.is(a)
   if a then return a end
end
```

```lua
function basis.isnot(a)
   if (not a) then return (not a) end
end
```

```lua
function basis.isnil(a)
   return a == nil
end
```

```lua
function basis.isboolean(a)
   if type(a) == 'boolean' then return a end
end
```

```lua
function basis.isnumber(a)
   if type(a) == 'number' then return a end
end
```

```lua
function basis.isstring(a)
   if type(a) == 'string' then return a end
end
```

```lua
function basis.isfunction(a)
   if type(a) == 'function' then return a end
end
```

```lua
function basis.istable(a)
   if type(a) == 'table' then return a end
end
```

```lua
function basis.isthread(a)
   if type(a) == 'thread' then return a end
end
```

```lua
function basis.isuserdata(a)
   if type(a) == 'userdata' then return a end
end
```

```lua
function basis.iscdata(a)
   if type(a) == 'cdata' then return a end
end
```
