# Clade


  This is gonna be fun\!


## Motive

In Espalier, we build the behaviors of our parsed data out of Nodes\.

It's characteristic to have a base class for a given Grammar, and hand roll
a bunch of extensions of it, then return a table of metatables\.

If a class isn't shadowed by a table, then it inherits from the base class,
which we put at `[1]` in the table\.

A Clade is a way of doing this which solves the problems with how I have
been doing this\.

Namely:


#### Verbosity

I shouldn't need to define the subfields of a clade explicitly, just start
assigning behaviors to it and get to work\.


#### Nonlocality

I have to either split the tables up into modules or cram them all into one
place\.

What I want to do is specify the specializations of a given method as a
cassette which I can add to the clade, so that something like `:toLua` lives
in one place\.

Some of these 'metatables' are entire Grammars, and do belong in their own
file\.  This means clades need to be constructable from discrete modules,
and we should do this without circular requiring squads or lazy loading\.


## Clade

Clades need the same seed/tape/metas triplet as orders do, but it behooves us
to keep them together in one table\.

The straightforward way to do this is simply to return a table with `seed`,
`tape`, and `meta` fields\.  So that's what we're going to do\.

This is probably not all the fields, since we have traits to reckon with, and
vectors\.

I'll probably make operations on the clade functions of the Clade table,
rather than giving Clade's methods which is a bit of a smell given that any
Clade manipulation should be at 'load time', a concept which is admittedly
underdefined\.

In fact, let's talk a bit about that vocabulary\.


#### Qualia, Traits, and Vectors

Qualia are how we provide cross\-cutting categories within a clade\.

This is a map of strings to a set of phyla, we call these strings 'traits',
the names of phyla we call 'tags' a la XML\.

Traits and tags share a namespace in the clade; a string must be one or the
other\.

If qualia map traits to tags, what are traits?  They map to additional state,
canonically methods, which apply to every tag with that quality\.

Vectors are named collections of additional state, think of them as
inside\-out phyla\.  The name of the *method* maps to a table where the tag or
trait is the key, and the value is to be assigned to the vector key on phyla
with that tag or trait\.

These can be used for code organization, conditional/lazy construction, and
as mixins to phyla with no protocol connection to one another\.

Any vector may have a base implementation at `[1]`\.  Similarly, a trait may
have a base implementation at `[1]`, so that e\.g\. `clade.trait.literal.report`
can have an implementation for all phyles as `clade.trait[1].report`\.



#### imports

```lua
local core, cluster = use ("qor:core", "cluster:cluster")
local table, string, fn = core.table, core.string, core.fn
```


## Clade

  This module is a callable table, so that we can present the clade API in the
same instance as the constructor\.

```lua
local Clade, Clade_M = {}, {}
setmetatable(Clade, Clade_M)
```


#### \_clade weak table

We need to retrieve the clade internally from the tape, and possibly the seed
and meta as well\.

```lua
local weak = assert(core.meta.weak)
local _clade = weak 'kv'
```


### Clade\(seed: Seed, onindex: fn\(tab:t, field\): t\): Clade

Creates and returns a clade from a given seed\.

The order is created separately, because it provides the root of lookup for
everything else, and it's quite normal to assign methods and the like to this
tape\.

#### specialize on index

The tape automatically produces genera when indexed upon, which we distribute
across the three collections\.

```lua
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
```


```lua
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
```


## Rest of the Owl Goes Here


### clade\.phyle\(basis, onindex?: fn\)



### clade\.trait\(basis,onindex?: fn\)

This returns a generator like 'phyle' but one which creates mixins, rather than
bringing to bear the full metatabular machinery\.

These are *applied* to a clade/phyle, but aren't dependent on them except
insofar as the clade must have sensible responses to the provided methods\.

`onindex` is an opportunity to do more than the default in building up index
tables\.  It should probably compose to `trait_index`, not replace it, but
that's something to test when we use it\.


#### Onward

```lua
return Clade
```
