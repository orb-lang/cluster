











local basis = {}



function basis.is(a)
   if a then return a end
end



function basis.isnot(a)
   if (not a) then return (not a) end
end



function basis.isnil(a)
   return a == nil
end



function basis.isboolean(a)
   if type(a) == 'boolean' then return a end
end



function basis.isnumber(a)
   if type(a) == 'number' then return a end
end



function basis.isstring(a)
   if type(a) == 'string' then return a end
end



function basis.isfunction(a)
   if type(a) == 'function' then return a end
end



function basis.istable(a)
   if type(a) == 'table' then return a end
end



function basis.isthread(a)
   if type(a) == 'thread' then return a end
end



function basis.isuserdata(a)
   if type(a) == 'userdata' then return a end
end



function basis.iscdata(a)
   if type(a) == 'cdata' then return a end
end

