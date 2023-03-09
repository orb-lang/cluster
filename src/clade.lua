




































































































local core, cluster = use ("qor:core", "cluster:cluster")
local table, string, fn = core.table, core.string, core.fn



local new, Clade = cluster.order()









local weak = assert(core.meta.weak)
local _clade = weak 'kv'






































































local function specializer(contract)
   return function(tape, field)
      if type(field) ~= 'string' then return nil end

      local clade = _clade[tape]
      local seed = assert(clade.seed[1], "clade is missing basis seed")
      local new, Phyle, Phyle_M = assert(cluster.genus(seed, contract))
      clade.seed[field] = new
      clade.tape[field] = Phyle
      clade.meta[field] =  Phyle_M

      return Phyle
   end
end






local prepose = assert(fn.prepose)

cluster.construct(new, function(new, clade, seed, contract)
   contract = contract or {}
   local tape, meta = cluster.tapefor(seed), cluster.metafor(seed)
   local __index = contract.postindex
                   and prepose(specializer(contract), contract.postindex)
                   or specializer(contract)
   clade.tape = setmetatable({tape}, { __index = __index })

   -- memoize just what we use, right now, that's the tape, only
   -- open question: is the below even useful?
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
   local anomalies, anom_Q, anom_T, anom_V = {}, {}, {}, {}

   for Q, set in pairs(quality) do
      for tag in pairs(set) do
         if not seed[tag] then
            anomalies.quality = anom_Q
            anom_Q[Q] = anom_Q[Q] or {}
            anom_Q[Q][tag] = "Clade has no phyle " .. tag
                          .. " for quality " .. Q
         end
         tape[tag][Q] = true
      end
   end

   -- traits with collision detection
   for T, impl in pairs(trait) do
      local qual = quality[T]
      if not qual then
         anomalies.trait = anom_T
         anom_T[qual] = "Trait " .. T .. " has no corresponding quality "
                        .. qual
      else
         -- these are canonically message and method
         for message, method in pairs(impl) do
            for tag in pairs(qual) do
               local phyle = tape[tag]
               -- handle collisions here
               tape[tag][message] = method
            end
         end
      end
   end

   -- vector application last
   for message, impl in pairs(vector) do
      for tag, method in pairs(impl) do
         if not seed[tag] then
            anomalies.vector = anom_V
            anom_V[message] = anom_V[message] or {}
            anom_V[message][tag] = "No phyle " .. tag
                                .. " for vector " .. message
         else
            -- collisions here are okay but we make note of it
            if tape[tag][message] then
               anom_V[message] = anom_V[message] or {}
               anom_V[message][tape] = "(at least one) duplicate method"
            end
            tape[tag][message] = method
         end
      end
   end
   if table.nkeys(anomalies) > 0 then
      clade.anomalies = anomalies
   end

   return clade
end





































function Clade.extend(clade, contract)
   local basis = clade.seed[1]
   if not basis then
      return assert(nil, "clade has no basal seed?")
   end  -- we'll need meta and probably tape as well, eventually
   local seed = cluster.genus(basis, contract)
   -- #reminder: this expects [1] to be the only filled slot
   return new(seed, contract)
end












return new

