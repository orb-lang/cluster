# Mold


A mold is a function which examines one table\.  It either returns this table,
or `nil, explanation`\.

The brief is necessarily complex, with more than one way to do it\.

We'll proceed slowly, from primitive types of equality\.


### First

We compare string keys only, and the shape provides type strings only, or
booleans which must match the truthiness of the field\.

```lua
local function mold(shape)
  return function(subject)
     for key, mold in pairs(shape) do
        local value = subject[key]
        local valtype = type(value)
        if value then
           if mold == false then
              return nil, "subject contains forbidden key " .. key
           end
           if type(mold) == 'string' then
              if valtype ~= mold then
                 return nil, "subject " .. key .. " of type " .. valtype
                             .. " not " .. mold
              end
           elseif mold ~= true then
              return nil , "unsupported mold shape " ..type(mold)
           end
        end
     end
     return subject
  end
end
```

```lua
return mold
```
