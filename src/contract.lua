













local core = require "qor:core"
















local basis = {}











function basis.some(a)
   if a then return a end
   return nil
end



function basis.none(a)
   if (not a) then
      return (not a)
   else
      return nil
   end
end








function basis.isnil(a)
   return (a == nil) or nil
end




function basis.isboolean(a)
   if type(a) == 'boolean' then return true end
   return nil
end



function basis.isnumber(a)
   if type(a) == 'number' then return a end
   return nil
end



function basis.isstring(a)
   if type(a) == 'string' then return a end
   return nil
end



function basis.isfunction(a)
   if type(a) == 'function' then return a end
   return nil
end



function basis.istable(a)
   if type(a) == 'table' then return a end
   return nil
end



function basis.isthread(a)
   if type(a) == 'thread' then return a end
   return nil
end



function basis.isuserdata(a)
   if type(a) == 'userdata' then return a end
   return nil
end



function basis.iscdata(a)
   if type(a) == 'cdata' then return a end
   return nil
end















local hasmetamethod = core.meta.hasmetamethod



local hascall;








local law = {}



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



return { basis = basis, law = law }

