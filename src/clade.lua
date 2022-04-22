

























































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

