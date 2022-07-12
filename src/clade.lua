

























































local clade = {}















local function _basal(basis)
   -- ignore basis for now
   local basal = {} -- make note of this?
   return basal
end
clade.basal = _basal












local function _phyle(basis)
   local phyle = {basis}
   return phyle
end

clade.phyle = _phyle















local function trait_index(mixin, field)
   mixin[field] = {}
   return mixin[field]
end

local trait_M = { __index = trait_index }

function clade.trait(onindex)
   local _M;
   if onindex then
      _M = { __index = onindex }
   else
      _M = trait_M
   end
   return setmetatable({}, _M)
end

