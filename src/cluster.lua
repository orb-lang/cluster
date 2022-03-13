

































































































































































































































































































































local core = require "qor:core"



local cluster = {}









local weak = assert(core.meta.weak)









local is_seed, is_tape, is_meta = weak 'k', weak 'k', weak 'k'














local seed_tape = weak 'kv'
local tape_meta = weak 'kv'
local meta_seed = weak 'kv'







local seed_meta, tape_seed, meta_tape = meta_seed, seed_tape, tape_meta





local function store(map, a, b)
   map[a] = b
   map[b] = a
end

local function register(seed, tape, meta)
   is_seed[seed] = true
   is_tape[tape] = true
   is_meta[meta] = true
   store(seed_tape, seed, tape)
   store(tape_meta, tape, meta)
   store(meta_seed, meta, seed)
   return seed, tape, meta
end




















local function genus(family)
   local seed, tape, meta = register({}, {}, {})
   meta.__meta = {}
   if not family then
      -- set em up fresh
      setmetatable(seed, {__index = tape})
   else
      assert(is_seed[family], "provide constructor to extend genus")
      local _M = seed_meta[family]
      setmetatable(tape, _M)
      for k, v in pairs(_M) do
         -- except __meta!
         if (not k == '__meta') then
            meta[k] = v
         else
            for _, __ in pairs(v) do
              meta.__meta[_] = __
            end
         end
      end
      meta.__meta.meta = _M -- ... maybe? probably.
   end
   meta.__index = tape
   meta.__meta.seed = seed
   return seed, tape, meta
end

cluster.genus = genus
























local compose = assert(core.fn.compose)

local function construct(seed, builder)
   assert(is_seed[seed], "#1 to construct must be a seed")
   -- assert(iscallable(builder), "#2 to construct must be callable")
   local meta = assert(seed_meta[seed], "missing metatable for seed!")
   local function post(instance)
      return setmetatable(instance, meta)
   end
   getmetatable(seed).__call = compose(builder, post)

   return;
end

cluster.construct = construct








return cluster

