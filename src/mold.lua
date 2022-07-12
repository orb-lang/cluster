







































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



return mold

