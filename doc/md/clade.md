#\* Clade

  Clades are a cluster protocol for creating a family of related metatables,
one where the members may not be known in advance\.

The motive is working with syntax trees, which are our primary subject of
focus in bridge\.


## Structure

  Inheritance is normally bespoke, as is the subsequent relationship between
related species\.  In clade, we generate a whole named collection of
descendants, known as phyles, which the clade maintains as a single structure\.

Clade being part of cluster, a clade is based on a single cluster genus, which
we refer to as the basis\.  This genus is created by the author, and the seed
passed to clade, which returns a clade\.

One way in which clades differ from ordinary genera is that their name is an
essential part of their identity\.  Cluster will provide a protocol for
associating names with genres, but normally the naming convention is just that,
a convention\.

The phyla of a given clade are organized by name, which we call a 'tag'\.


### The Clade Table

Within the clade, each phylum is an ordinary clusder genre, specific to the
order/genus which is its basis\.

Since each genre is a triplet of seed, tape, and meta, the clade has fields
`seed`, `tape`, and `meta`, following our usual convention of key/value maps
being in the singular\.

The basis is found at `[1]` on each of those fields\.

The tape is special, because we allow it to create a new genus when indexed\.
So we return the tape after the clade, for ergonomic reasons\.

In addition to phyla, which are based on ordinary specialization aka
inheritance, clades have a system for disciplined composition of cross\-cutting
concerns\.

These are provided with three more tables, on slots `quality`, `trait`, and
`vector`\.


### Qualia, Traits, and Vectors

Qualia are simply named features which phyla have in common\.

The `quality` slot carries a map of symbols to a set of phylum tags, the keys
of which we call traits\.

Traits and tags share a namespace in the clade; a symbol must be one or the
other\.

If qualia map traits to tags, what are traits?  They map to additional state,
canonically methods, which apply to every tag with that quality\.

Vectors are named collections of additional state, think of them as
inside\-out phyla\.  The name of the *method* maps to a table where the tag or
trait is the key, and the value is to be assigned to the vector key on phyla
with that tag or trait\.  So we might have `vector.toJson.record`,
`vector.toJson.protocol`, and so on\.

These can be used for code organization, conditional/lazy construction, and
as mixins to phyla with no protocol connection to one another\.

Any vector may have a base implementation at `[1]`\.  Similarly, a trait may
have a base implementation at `[1]`, so that e\.g\. `clade.trait.literal.report`
can have an implementation for all phyles as `clade.trait[1].report`\.

Neither the vector table nor the qualia table themselves should have values at
`[1]`, there being no sensible interpretation of either\.


#### Vectors and Mixins

The way vectors are stored is correct for the application, but weird for Lua\.

We end up where `vec.someMethod.tag` is called as `tag:someMethod()`, which is
fine, in a sense\.  It's the sort of thing which can be taught to a code
analysis tool only with difficulty\.

It may behoove me to offer a mixin concept, so that a mixin can be composed in
the familiar way, then inverted into vectors\.

Let's get the core right first\.


## Clade

Clade itself is an ordinary cluster order\.


#### imports

```lua
local core, cluster = use ("qor:core", "cluster:cluster")
local table, string, fn = core.table, core.string, core.fn
```

```lua
local new, Clade = cluster.order()
```


#### \_clade weak table

We need to retrieve the clade internally from the tape, and possibly the seed
and meta as well\.

```lua
local weak = assert(core.meta.weak)
local _clade = weak 'kv'
```


### Clade\(seed: Seed, contract?: t\): c: Clade, c\.tape

Creates and returns a clade from a given seed\.

The order is created separately, because it provides the root of lookup for
everything else, and it's quite normal to assign methods and the like to this
tape\.

Note that indexing other tables in the clade will not do things automagically\.


#### Clade Contract

  Contracts are the core Cluster mechanism, which make it a protocol and not
something else\.

The Clade doesn't have a separate Contract, in the sense that all Contract
is passed to Cluster and interpreted by the same logic\.

Contract will be the main point of developement going forward\.  Here we
briefly describe protocols of particular use to Clade, and propose others\.


##### contract\.seed\_fn

  In Node, we need the builder to be a function, because of how lpeg patterns
dispatch: on type, so lpeg will ignore the callability of a table and just
put the captures directly into it\.

This can be dealt with by wrapping the seed in a function, but we have no use
for the first step, where we make a builder and attach it to the seed table\.

Node metatable assignment is one of the hottest loops we have, and while the
JIT may fix our mistake, we prefer not to make it\.

Adding this starts with Cluster\.


##### \#Todo: dispatched endowment

`endow` is the inner Cluster function we use to either assign the appropriate
metatable, or propagate errors\.

For Clades, which are just Nodes stripped of semantics, it's normal for both
the creator function and the associated metatable to have the tag in common\.
So we could have just one creator and one endowment, both of them dispatched
against the tag\.  So the Clade Seed would have a collection of identical
functions\(presuming none were overridden\), and that function would internally
lookup on Clade Meta to assign the table\.

While this is merely an optimization, it may prove to be a considerable one
for Orb, which will have hundreds of grammars to wield\.  The current scheme
creates two closures per rule, which could be two closures *per grammar*\.

Lower big O is the kind of thing which shouldn't be left laying on the table\.



#### specialize on index

The tape automatically produces genera when indexed upon, which we distribute
across the three collections\.  This returns the tape of the phyle\.

```lua
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
```


### Clade\(\)

```lua
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
```


### Clade:coalesce\(\)

  Coalescence is when we verify everything is kosher and build the final form
of the Clade\.  It's a general cluster concept we haven't added yet, because we
don't actually use deep or complex inheritance very much at all\.

The idea is that lookup is resolved down to a single level of depth \(when
possible\), while maintaining the actual cluster contractin the metametatable\.

For clades, the assembly of the clade involves resolving all the various
moving parts into a collection of metatables and their builders which reflects
the full structure\.

This might actually return `clade.seed, clade.tape, clade.meta`, or new tables
which serve that function \(?\)\.

Some unanswered questions here about conditional vector inclusion and identity
on various transforms, what should be mutable and what shouldn't, it gets
wacky

Specifically, traits and vectors can override state on a phylum, which is not
our intended use for either\.  We don't want to forbid it, but it behooves us
to detect the condition, since it would frequently represent an error\.

Traits can also be self\-contradictory\.  If two qualia have a non\-empty
intersection, defining a trait with the same name for both qualia could result
in one or the other assigned to the phyla in the intersection, depending on
iteration order of the trait application\.  Detecting this with acceptable
complexity is going to be tricky\.

We can't have that, so we need to detect this during coalescence and throw an
error\.  This unambiguously represents an error in the model\.

It's probably the case that overriding a phyle's tape with a trait is also a
bug, but not as necessarily so\.  With vectors it might be the intention\.

The most conservative thing to do is make all three cases an error, and allow
trait and vector overrides with configuration\.

```lua
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
```


### Clade:extend\(contract?\)

  Cluster requires that all operations be functions on the seed, because we
can't block the namespace, or indeed, rely on the seed being an indexable\.

The Clade has no such limitations, so we extend with a method\.

The contract is currently passed directly through to Cluster, but Clade may
use it as well in future\.


#### The Easy Part First

  If we have a Clade which only has the basal genre, then all we need is
another Clade which extends it\.  That's the easy part\.

The fun part is rebasing any derived Phyles onto the new genre, and this is
necessary for everything we're doing here\.  This is where Cluster starts to
shine, because we *have* everything we need to decompose the existing Phyla
and build new ones\.

Unanswered question is how coalescence works with extension\.  We won't
coalesce the Clade itself, but we might coalesce a copy, and rebase the clade
on that copy\.

```lua
function Clade.extend(clade, contract)
   local basis = clade.seed[1]
   if not basis then
      return assert(nil, "clade has no basal seed?")
   end  -- we'll need meta and probably tape as well, eventually
   local seed = cluster.genus(basis, contract)
   -- #reminder: this expects [1] to be the only filled slot
   return new(seed, contract)
end
```


#### Clade\.prune\(dont\_know?\)

Thinking ahead here, because Clades themselves must specialize, which can
result in Phyla which we don't need\.  Everything else can be removed manually,
but scrubbing phyla needs to be done carefully so we also remove the seed and
meta\.


```lua
return new
```
