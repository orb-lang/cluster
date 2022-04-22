
















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



return mold

