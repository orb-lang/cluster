




































































































































































































































































































































local core = require "qor:core"



local cluster = {}









local weak = assert(core.meta.weak)









local is_seed, is_tape, is_meta = weak 'k', weak 'k', weak 'k'














local seed_tape, tape_seed = weak 'kv', weak 'kv'
local tape_meta, meta_tape = weak 'kv', weak 'kv'
local meta_seed, seed_meta = weak 'kv', weak 'kv'





local insert = assert(table.insert)

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




















local function genus(family)
   local seed, tape, meta = register({}, {}, {})
   meta.__meta = {}
   setmetatable(seed, { __index = tape })
   if family then
      assert(is_seed[family], "provide constructor to extend genus")
      local meta_tape = seed_tape[family]
      setmetatable(tape, { __index = meta_tape })
      local _M = seed_meta[family]
      for k, v in pairs(_M) do
         -- meta we copy
         if k == '__meta' then
            for _, __ in pairs(v) do
              meta.__meta[_] = __
            end
         else
            meta[k] = v
         end
      end
      meta.__meta.meta = _M -- ... yep.
   end
   meta.__index = tape
   meta.__meta.seed = seed
   return seed, tape, meta
end

cluster.genus = genus





































local compose = assert(core.fn.compose)

local function makeconstructor(builder, meta)
   return function(seed, ...)
      local instance = {}
      return setmetatable(builder(seed, instance, ...), meta)
   end
end

local function construct(seed, builder)
   assert(is_seed[seed], "#1 to construct must be a seed")
   -- assert(iscallable(builder), "#2 to construct must be callable")
   local meta = assert(seed_meta[seed], "missing metatable for seed!")
   meta.__meta.builder = builder
   getmetatable(seed).__call = makeconstructor(builder, meta)

   return;
end

cluster.construct = construct

















local function extendbuilder(seed, builder)
   assert(is_seed[seed], "#1 to construct must be a seed")
   local meta = assert(seed_meta[seed], "missing metatable for seed")
   local _M = meta.__meta.meta
   if not _M then
      error("can't extend a constructor with no inheritance, use construct")
   end

   local super_build = assert(_M.__meta.builder, "metatable missing a builder")
   local function _build(seed, instance, ...)
      local _inst = super_build(seed, instance, ...)
      return builder(seed, _inst, ...)
   end
   meta.__meta.builder = _build

   getmetatable(seed).__call = makeconstructor(_build, meta)
end

cluster.extendbuilder = extendbuilder





cluster.extend = {}
cluster.extend.builder = extendbuilder























local iscallable = assert(core.fn.iscallable)
local function super(tape, message, after_method)
   assert(is_tape[tape], "#1 error: cluster.super extends a cassette")
   assert(type(message) == 'string', "#2 must be a string")
   assert(iscallable(after_method), "#3 must be callable")
   -- let's prevent this happening twice
   if rawget(tape, message) then
      error("cassette already has " .. message)
   end
   local super_method = tape[message]
   assert(iscallable(super_method))
   tape[message] = function(_tape, ...)
                      super_method(_tape, ...)
                      return after_method(_tape, ...)
                   end

   return;
end

cluster.super = super
cluster.extend.super = super





return cluster

