




































































































local core, cluster = use ("qor:core", "cluster:cluster")
local table, string, fn = core.table, core.string, core.fn



local new, Clade = cluster.order()









local weak = assert(core.meta.weak)
local _clade = weak 'kv'





























































local function specializer(cfg)
   return function(tape, field)
      if type(field) ~= 'string' then return nil end
      local clade = _clade[tape]
      local seed = assert(clade.seed[1], "clade is missing basis seed")
      local new, Phyle, Phyle_M = assert(cluster.genus(seed, cfg))
      clade.seed[field] = new
      clade.tape[field] = Phyle
      clade.meta[field] =  Phyle_M
      return Phyle
   end
end






local prepose = assert(fn.prepose)
local CFG_DUMMY = {}

cluster.construct(new, function(new, clade, seed, cfg)
   cfg = cfg or CFG_DUMMY
   local tape, meta = cluster.tapefor(seed), cluster.metafor(seed)
   local __index = cfg.postindex
                   and prepose(specializer(cfg), cfg.postindex)
                   or specializer(cfg)
   clade.tape = setmetatable({tape}, { __index = __index })

   -- memoize just what we use, right now, that's the tape, only
   _clade[clade.tape] = clade
   clade.seed, clade.meta = {seed}, {meta}
   clade.quality, clade.trait, clade.vector = {}, {}, {}

   return clade
end)











































function Clade.coalesce(clade)
   -- I should write Byron 0.1 for the destructuring alone
   local seed, tape, trait, quality, vector = clade.seed,
                                              clade.tape,
                                              clade.trait,
                                              clade.quality,
                                              clade.vector
   -- apply qualia
   for Q, set in pairs(quality) do
      for tag in pairs(set) do
         if not seed[tag] then
            return nil, "Clade has no phyle " .. tag .. " for quality " .. Q
         end
         tape[elem][Q] = true
      end
   end
   -- traits with collision detection
   for T, impl in pairs(trait) do
      local qual = quality[T]
      if not qual then
         return nil, "Trait " .. T .. " has no corresponding quality"
      end
      -- these are canonically message and method but we don't actually care
      for message, method in pairs(impl) do
         for tag in pairs(qual) do
            local phyle = tape[tag]
            -- handle collisions here
            tape[tag][message] = method
         end
      end
      for message, impl in pairs(vector) do
         for tag, method in pairs(impl) do
            if not seed[tag] then
               return nil, "No phyle " .. tag .. " for vector " .. message
            end
            -- collisions here are okay but we should notice it
            tape[tag][message] = method
         end
      end
   end

   return clade
end












return new

