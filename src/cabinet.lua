



















local core = use "qor:core"
local weak = assert(core.meta.weak)









local function Cabinet()









local is_seed, is_tape, is_meta = weak 'k', weak 'k', weak 'k'





local seed_tape, tape_seed = weak 'kv', weak 'kv'
local tape_meta, meta_tape = weak 'kv', weak 'kv'
local meta_seed, seed_meta = weak 'kv', weak 'kv'





local function register(seed, tape, meta)
   is_seed[seed] = true
   is_tape[tape] = true
   is_meta[meta] = true
   seed_tape[seed] = tape
   tape_seed[tape] = seed
   tape_meta[tape] = meta
   meta_tape[meta] = tape
   meta_seed[meta] = seed
   seed_meta[seed] = meta
   return seed, tape, meta
end






















local function metafor(seed)
   if is_seed[seed] then
      local M = seed_meta[seed]
      if M then
         return M
      else
         return nil, "seed has no metatable"
      end
   else
      return nil, "this is not a recognized seed"
   end
end

local function tapefor(seed)
   if is_seed[seed] then
      local T = seed_tape[seed]
      if T then
         return T
      else
         return nil, "seed has no tape"
      end
   else
      return nil, "this is not a recognized seed"
   end
end






return {
   is_seed = is_seed,
   is_tape = is_tape,
   is_meta = is_meta,
   seed_tape = seed_tape,
   tape_seed = tape_seed,
   tape_meta = tape_meta,
   meta_tape = meta_tape,
   meta_seed = meta_seed,
   seed_meta = seed_meta,
   register = register,
   metafor = metafor,
   tapefor = tapefor,
}






end



return Cabinet

