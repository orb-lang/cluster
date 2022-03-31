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


### clade\.basal\(seed?\)

The delicate part is how Clades interact with the cluster triad\.

In Node, the various metatables are assigned directly, and some of them aren't
even metatables\.  While it would be useful \(and I have a strategy in some
cases\) to provide a constructor, it's important that constructors work
compatibly while being optional in some sense?


### clade\.phyle\(basal\)


### clade\(basal, phyle, phyle\.\.\.\)

