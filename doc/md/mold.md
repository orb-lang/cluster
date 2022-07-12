# Mold


A mold is a function which examines one table\.  It either returns this table,
or `nil, explanation`\.

The brief is necessarily complex, with more than one way to do it\.

We'll proceed slowly, from primitive types of equality\.


### mold\(use, mention\)

A mold takes up to two tables, called `use` and `mention`\.

The `use` table is used for its literal shape, we iterate over every key and
apply these rules based on the value:


- If the value is a:

  - string: The subject value must be of type\(subject\) == string\.

  - boolean:  A `true` subject value must be truthy, a `false` subject must
      be falsy\.

  - table:  The subject value must also be a table, and it is molded against
      this table, which follows these rules recursively\.

We apply `use` completely, including recursion, then move to `mention`\.


- Supported fields in mention:

  - just:  This is a key value map, any key must be of that value precisely
      via equality comparison\.

We will continue this list, the obvious next candidate involves metatables\.



```lua
local function mold(_use, mention)
   -- break out all mention categories as I write them:
   local just = mention and mention.just
   local function _mold(subject, use)
      use = use or _use
      for key, mold in pairs(use) do
         local value = subject[key]
         local valtype, moldtype = type(value), type(mold)
         if value then
            if mold == false then
               return nil, "subject contains forbidden key " .. key
            end
            if moldtype == 'string' then
               if valtype ~= mold then
                  return nil, "subject " .. key .. " of type " .. valtype
                              .. " not " .. mold
               end
            elseif moldtype == 'table' then
               local molded, why = _mold(value, mold)
               if not molded then
                  return nil, why
               end
            elseif mold ~= true then
               return nil , "unsupported mold shape " .. type(mold)
            end
         elseif mold == true then
            return nil, "mandatory field " .. key .. " is missing"
         end
      end

      if just then
         for key, value in pairs(just) do
            if subject[key] ~= value then
               return nil, "value of " .. key .. " is not " .. tostring(value)
            end
         end
      end

      return subject
   end

   return _mold
end
```

```lua
return mold
```
