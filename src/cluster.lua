
























































































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






















function cluster.metafor(seed)
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

function cluster.tapefor(seed)
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

local function genus(order, contract)
   if order then
      local meta_tape = seed_tape[order]
      if not meta_tape then
         return nil, "provide seed to extend genus"
      end
      local seed, tape, meta = register({}, {}, {__meta = {}})
      setmeta(seed, { __index = tape })
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
      meta.__index = tape
      meta.__meta.seed = seed
      return seed, tape, meta
   else
      return nil, "genus must be called on an existing genre/order"
   end
end

cluster.genus = genus



local function order(no_table)
   local seed, tape, meta = register({}, {}, {__meta = {}})
   setmeta(seed, { __index = tape })
   meta.__index = tape
   meta.__meta.seed = seed
   return seed, tape, meta
end

cluster.order = order


















































local compose = assert(core.fn.compose)

local function makeconstructor(builder, meta)
   return function(seed, ...)
      local instance = {}
      local subject, err = builder(seed, instance, ...)
      if subject == nil then
         error(err or "bulder must return the subject")
      end
      return setmeta(subject, meta), err
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


























local function makecreator(creator, meta)
   return function(...)
      local subject, err = creator(...)
      if subject == nil then
         error(err or "creator must return subject")
      end
      return setmeta(subject, meta), err
   end
end

local function create(seed, creator)
   assert(is_seed[seed], "#1 to construct must be a seed")
   local meta = assert(seed_meta[seed], "missing metatable for seed!")

   meta.__meta.builder = creator
   meta.__meta.builder_creates_instance = true
   getmeta(seed).__call = makecreator(creator, meta)
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
   local created = _M.__meta.builder_creates_instance
   local maker = created
                 and makecreator
                 or makeconstructor
   -- true means reuse the builder
   if builder == true then
      meta.__meta.builder = super_build
      getmeta(seed).__call = maker(super_build, meta)
      return
   end
   -- we should assert callability here?
   local _build;
   if created then
      _build = function(seed, ...)
         local _inst = super_build(seed, ...)
         return builder(seed, _inst, ...)
      end
   else
      _build = function (seed, instance, ...)
         local _inst = super_build(seed, instance, ...)
         return builder(seed, _inst, ...)
      end
   end

   meta.__meta.builder = _build
   getmeta(seed).__call = maker(_build, meta)
   meta.__meta.builder_creates_instance = created
end

cluster.extendbuilder = extendbuilder





cluster.extend = {}
cluster.extend.builder = extendbuilder





















local iscallable = assert(core.fn.iscallable)
local rawget = assert(rawget)

local function super(tape, message, after_method)
   assert(is_tape[tape], "#1 error: cluster.super extends a tape")
   assert(type(message) == 'string', "#2 must be a string")
   assert(iscallable(after_method), "#3 must be callable")
   -- let's prevent this happening twice
   if rawget(tape, message) then
      error("tape already has " .. message)
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

