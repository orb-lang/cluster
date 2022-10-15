


































































































































































































































































































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
                      clade = "cluster:clade",
                   -- G     = "cluster:G",
                }


















local cab = use "cluster:cabinet" ()














local is_seed, is_tape, is_meta = assert(cab.is_seed),
                                  assert(cab.is_tape),
                                  assert(cab.is_meta)





local seed_tape, tape_seed = assert(cab.seed_tape), assert(cab.tape_seed)
local tape_meta, meta_tape = assert(cab.tape_meta), assert(cab.meta_tape)
local meta_seed, seed_meta = assert(cab.meta_seed), assert(cab.seed_meta)





local register = cab.register









cluster.tapefor = assert(cab.tapefor)
cluster.metafor = assert(cab.metafor)


















































local function idest(pred, obj)
   -- primitive
   if type(pred) == 'string' then
      return type(obj) == pred
   end
   -- try new-style first
   if type(obj) == 'table' then
      local _M = getmeta(obj)
      if _M and is_meta[_M] then
         -- make the first check an assert, then drop
         if _M.sunt and _M.sunt[pred] then
            return true
         end
      elseif obj.idEst == pred then
         return true
      end
   end

   return false
end

cluster.idest = idest














local CONTRACT_DEFAULT = {}




















































































































local Set = assert(core.set)

local function newmeta(seed)
   return { __meta = {},
            __sunt = Set {seed} }
end













local closedSeed;

local function order(contract)
   local seed_is_table = true
   contract = contract or CONTRACT_DEFAULT
   local seed, tape, meta;
   if contract.seed_fn then
      -- do seed_fn stuff
      seed_is_table = false
      meta = newmeta()
      seed = closedSeed(contract.seed_fn, meta)
      if not seed then
         return nil, "contract did not result in seed"
      end
      meta.__sunt[seed] = true
   else
      seed = {}
      meta = newmeta(seed)
   end
   seed, tape, meta = register(seed, {}, meta)
   if seed_is_table then
      setmeta(seed, { __index = tape })
   end
   meta.__index = tape
   meta.__meta.seed = seed
   return seed, tape, meta
end

cluster.order = order



















local pairs = assert(pairs)

local function genus(order, contract)
   if order then
      local meta_tape = seed_tape[order]
      if not meta_tape then
         return nil, "provide seed to extend genus"
      end
      local seed_is_table = true
      contract = contract or CONTRACT_DEFAULT
      local seed, meta;
      local tape = {}
      if contract.seed_fn then
         -- do seed_fn stuff
         seed_is_table = false
         meta = newmeta()
         seed = closedSeed(contract.seed_fn, meta)
         if not seed then
            return nil, "contract did not result in seed"
         end
         meta.__sunt[seed] = true
      else
         seed = {}
         meta = newmeta(seed)
      end
      register(seed, tape, meta)
      if seed_is_table then
         setmeta(seed, { __index = tape })
      end
      setmeta(tape, { __index = meta_tape })
      local _M = seed_meta[order]
      if not _M then
         return nil, "no meta for generic party"
      end
      for k, v in pairs(_M) do
         -- meta we copy
         -- we could stand to be more detailed here
         if k == '__meta' then
            for _, __ in pairs(v) do
              meta.__meta[_] = __
            end
         elseif k == '__sunt' then
            -- union of sets
            meta[k] = meta[k] + v
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














function closedSeed(seed_fn, meta)
   return function(...)
      local subject, err = seed_fn(...)
      if subject then
         return setmetatable(subject, meta), err
      else
         return subject, err
      end
   end
end


























































local fn = core.fn
local curry, iscallable = assert(fn.curry), assert(fn.iscallable)











local function endow(meta, subject, err)
   if subject == nil then
      return nil, err or "builder must return the subject"
   else
      return setmeta(subject, meta), err
   end
end









local function creatorbuilder(builder)
   return function(seed, ...)
      return builder(seed, {}, ...)
   end
end








local function makeconstructor(builder, meta)
   local creator = creatorbuilder(builder)
   return function(seed, ...)
      return endow(meta, creator(seed, ...))
   end, creator
end





local function construct(seed, builder)
   if not is_seed[seed] then
      return nil, "#1 to construct must be a seed"
   end
   if not iscallable(builder) then
      return nil, "#2 to construct must be callable"
   end
   local meta = seed_meta[seed]
   if not meta then
      return nil, "missing metatable for seed"
   end
   meta.__meta.builder = builder
   getmeta(seed).__call, meta.__meta.creator = makeconstructor(builder, meta)

   return true
end

cluster.construct = construct

















local function makecreator(creator, meta)
   return function(...)
      return endow(meta, creator(...))
   end
end

local function create(seed, creator)
   if not is_seed[seed] then
      return nil, "#1 to construct must be a seed"
   end
   local meta = seed_meta[seed]
   if not meta then
      return nil, "missing metatable for seed"
   end
   meta.__meta.creator = creator
   getmeta(seed).__call = makecreator(creator, meta)
   return true
end

cluster.create = create


























local function extendbuilder(seed, builder)
   if not is_seed[seed] then
      return nil, "#1 to construct must be a seed"
   end
   local meta = seed_meta[seed]
   if not meta then
      return nil,  "missing metatable for seed"
   end
   -- this is where we need to check for function seeds and take a whole
   -- different branch
   local seed_M = getmeta(seed)
   local _M = meta.__meta.meta
   if not _M then
      return nil, "can't extend a constructor with no generic, use construct"
   end
   -- it's the creator which we extend, read "extend with builder"
   local gen_creator = _M.__meta.creator
   if not gen_creator then
      return nil, "generic metatable missing a creator"
   end
   -- true means reuse the builder
   if builder == true then
      meta.__meta.creator = gen_creator
      seed_M.__call = makecreator(gen_creator, meta)
      return true
   end

   if not iscallable(builder) then
      return nil, "builder of type " .. type(builder) .. " is not callable"
   end

   local function creator(seed, ...)
      local subject, err = gen_creator(seed, ...)
      if not subject then
         return nil, err
      end
      return builder(seed, subject, ...), err
   end

   meta.__meta.builder = builder
   meta.__meta.creator = creator
   seed_M.__call = makecreator(creator, meta)

   return true
end

cluster.extendbuilder = extendbuilder





cluster.extend = {}
cluster.extend.builder = extendbuilder





















local rawget = assert(rawget)

local function super(tape, message, after_method)
   if not is_tape[tape] then
      return nil, "#1 error: cluster.super extends a tape"
   end
   if type(message) ~= 'string' then
      return nil, "#2 must be a string"
   end
   if not iscallable(after_method) then
      return nil, "#3 must be callable"
   end
   -- let's prevent this happening twice
   if rawget(tape, message) then
      return nil, "tape already has " .. message
   end
   local super_method = tape[message]
   if not iscallable(super_method) then
      return nil,  "value of message ."
                    .. tape .. " isn't callable, type is "
                    .. type(super_method)
   end
   tape[message] = function(_tape, ...)
                      super_method(_tape, ...)
                      return after_method(_tape, ...)
                   end
   return true
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

