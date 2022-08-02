
























































































local assert = assert
local require = assert(require)
local error   = assert(error)
local getmeta, setmeta = assert(getmetatable), assert(setmetatable)
-- I'm going to shadow these because I'll forget otherwise
local getmetatable, setmetatable = nil, nil




local core = require "qor:core"
local lazyloader = assert(core.module.lazyloader)












local cluster = lazyloader { 'cluster',
                   response = "cluster:response",
                   mold     = "cluster:mold",
                   contract = "cluster:contract",
                   -- clade = "cluster:clade",
                   -- G     = "cluster:G",
                }









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



























local function idest(pred, obj)
   -- primitive
   if type(pred) == 'string' then
      return type(obj) == pred
   end
   -- try new-style first
   if type(obj) == 'table' then
      local _M = getmeta(obj)
      if _M and is_meta[_M] then
         while _M do
            if _M.__meta.seed == pred then
               return true
            end
            _M = _M.__meta.meta
         end
      elseif obj.idEst == pred then
         return true
      end
   end

   return false
end
cluster.idest = idest






































































local pairs = assert(pairs)

local function genus(order)
   local seed, tape, meta = register({}, {}, {})
   meta.__meta = {}
   setmeta(seed, { __index = tape })
   if order then
      assert(is_seed[order], "provide constructor to extend genus")
      local meta_tape = seed_tape[order]
      setmeta(tape, { __index = meta_tape })
      local _M = seed_meta[order]
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



local function order(no_table)
   if no_table then
      error "calling cluster.order with a contract is NYI"
   end
   return genus()
end

cluster.order = order


















































local compose = assert(core.fn.compose)

local function makeconstructor(builder, meta)
   return function(seed, ...)
      local instance = {}
      return setmeta(assert(builder(seed, instance, ...),
                            "builder must return the subject"),
                     meta)
   end
end

local function construct(seed, builder)
   assert(is_seed[seed], "#1 to construct must be a seed")
   -- assert(iscallable(builder), "#2 to construct must be callable")
   local meta = assert(seed_meta[seed], "missing metatable for seed!")
   meta.__meta.builder = builder
   getmeta(seed).__call = makeconstructor(builder, meta)

   return;
end

cluster.construct = construct




















local function create(seed, creator)
   assert(is_seed[seed], "#1 to construct must be a seed")
   local meta = assert(seed_meta[seed], "missing metatable for seed!")
   local function _call(...)
      return setmeta(assert(creator(...), "creator must return subject"), meta)
   end
   meta.__meta.builder = creator
   getmeta(seed).__call = _call
end

cluster.create = create













local function extendbuilder(seed, builder)
   assert(is_seed[seed], "#1 to construct must be a seed")
   local meta = assert(seed_meta[seed], "missing metatable for seed")
   local _M = meta.__meta.meta
   if not _M then
      error("can't extend a constructor with no inheritance, use construct")
   end
   local super_build = assert(_M.__meta.builder, "metatable missing a builder")
   -- true means reuse the builder
   if builder == true then
      meta.__meta.builder = super_build
      getmeta(seed).__call = makeconstructor(super_build, meta)
      return
   end
   -- we should assert callability here?

   local function _build(seed, instance, ...)
      local _inst = super_build(seed, instance, ...)
      return builder(seed, _inst, ...)
   end
   meta.__meta.builder = _build

   getmeta(seed).__call = makeconstructor(_build, meta)
end

cluster.extendbuilder = extendbuilder





cluster.extend = {}
cluster.extend.builder = extendbuilder





















local iscallable = assert(core.fn.iscallable)
local rawget = assert(rawget)

local function super(tape, message, after_method)
   assert(is_tape[tape], "#1 error: cluster.super extends a cassette")
   assert(type(message) == 'string', "#2 must be a string")
   assert(iscallable(after_method), "#3 must be callable")
   -- let's prevent this happening twice
   if rawget(tape, message) then
      error("cassette already has " .. message)
   end
   local super_method = tape[message]
   assert(iscallable(super_method), "super method value isn't callable")
   tape[message] = function(_tape, ...)
                      super_method(_tape, ...)
                      return after_method(_tape, ...)
                   end
   return;
end

cluster.super = super
cluster.extend.super = super





















local ur = {}
cluster.ur = ur








function ur.mu()
   return
end








function ur.pass(...)
   return ...
end








function ur.chain(a)
   return a
end











function ur.thru(_, ...)
   return ...
end

ur.through = ur.thru








function ur.NYI()
   error "missing method!"
end











function ur.no()
   return false
end



function ur.yes()
   return true
end




return cluster

