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


## Design

  A Clade is built from a `base`, one or more `cassettes` which extend the
base, and the `clade` proper, which is constructed from the base and cassettes\.

Somehow the clade needs to become an ordinary Cluster triad, and I don't get
that part yet\.

Not ready to implement yet, but the basics are all here\.

The first version of this is going to be a bit clunky, I expect\.  The design
brief is really "write syntax sugar making Nodes easier to work with", and
Nodes don't really come with constructors\. Is this an inevitable property of
clades?  Probably not\.

```lua
local clade = {}
```


### clade\.basal\(base?\)

The delicate part is how Clades interact with the cluster triad\.

In Node, the various metatables are assigned directly, and some of them aren't
even metatables\.  While it would be useful \(and I have a strategy in some
cases\) to provide a constructor, it's important that constructors work
compatibly while being optional in some sense?

For now, `basal` doesn't even extend with a `base`, but it should\.

```lua
local function _basal(basis)
   -- ignore basis for now
   local basal = {} -- make note of this?
   return basal
end
clade.basal = _basal
```


### clade\.phyle\(basal, onindex?: fn\)

Phyle needs to automatically create metatables when indexed, and I should
probably provide some rational basis for making `Phyle.Table` autocreate a
`.table` field, not a `Table` field\.

This is a case where the behavior I need isn't a sensible default\.

```lua
local function _phyle(basis)
   local phyle = {basis}
   return phyle
end

clade.phyle = _phyle
```


### clade\.trait\(onindex?: fn\)

This returns a generator like 'phyle' but one which creates mixins rather than
bringing to bear the full metatabular machinery\.

These are *applied* to a clade/phyle, but aren't dependent on them except
insofar as the clade must have sensible responses to the provided methods\.

`onindex` is an opportunity to do more than the default in building up index
tables\.

```lua
local function trait_index(mixin, field)
   mixin[field] = {}
   return mixin[field]
end

local trait_M = { __index = trait_index }

function clade.trait(onindex)
   local _M;
   if onindex then
      _M = { __index = onindex }
   else
      _M = trait_M
   end
   return setmetatable({}, _M)
end
```


### clade\(basal, phyle, traits: \.\.\.\)


