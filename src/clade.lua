


























































































local core, cluster = use ("qor:core", "cluster:cluster")
local table, string, fn = core.table, core.string, core.fn









local Clade, Clade_M = {}, {}
setmetatable(Clade, Clade_M)









local weak = assert(core.meta.weak)
local _clade = weak 'kv'

















local function specializer(tape, field)
   if not string(field) then return nil end
   local clade = _clade[tape]
   local seed = assert(clade.seed[1], "clade is missing basis seed")
   local new, Phyle, Phyle_M = cluster.genus(seed)
   cluster.extendbuilder(new, true)
   clade.seed[field] = new
   clade.tape[field] = Phyle
   clade.meta[field] =  Phyle_M
   return Phyle
end




local prepose = assert(fn.prepose)

function Clade_M.__call(_Clade, seed, postindex)
   local tape, meta = cluster.tapefor(seed), cluster.metafor(seed)
   local __index = postindex
                   and prepose(specializer, postindex)
                   or specializer
   local clade = {}
   clade.tape = setmetatable({}, { __index = __index })
   return clade
end


























return Clade

