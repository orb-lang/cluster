# Cluster


  **The Comprehensive LUa System for Typing Everything Repeatedly**\.

Cluster is the basis for using the LuaJIT runtime in the bridge\-approved
fashion\.  It succeeds at this, insofar as it will, by respecting the existing
philosophy of the language\.


## Philosophy

> We can divide programming languages in two categories:
>
>  1\) Those where arrays start at 1\.
>
>  1\) Those where arrays start at 0\.
>
> \-\- Roberto Ierusalimschy, 2022\-01\-01

   If Lua has a flaw, it is this, and here we might even see the maestro cop
to it\.

So, as we must, we [tip our hat to Edsger Djikstra](https://www.cs.utexas.edu/users/EWD/ewd08xx/EWD831.PDF), as we dive back into
the waters of Knuthian programming with Wirthian characteristics\.

###  Respect the Runtime


  Lua is a carefully designed language, and was chosen carefully by your
humble author, out of admiration for the choices which were made in this
design\.

This applies even moreso to the choice of implementation, LuaJIT\.  This brings
two offerings to the table: a powerful JIT and a wonderful foreign function
interface\.



#### Meta\-Object Protocol

  One of the attractions of Lua is that it embraces the correct definition of
"object" to use when programming anywhere near the C runtime\.

This is more than just a particular layout of memory, pointer references can
make the instance of a particular object arbitrarily complex, but what an
object **is** to the C programmer needn't be defined to point out that Lua uses
it\.

Clearly, associating tables with behavior is also core to the Lua philosophy,
but this is done in a way which the authors describe as metasyntactic
extension\.  This is familiar to old Lisp hands as a meta\-object protocol, a
set of abstractions which allow the dispatch of various messages to
appropriate responders through the same syntax used to access literal slots
on the table in question\.

Note as we continue that Lisp\-land itself has a definition of object, which
centers around CLOS and *the* Meta\-Object Protocol, or MOP\.


## Types

  Cluster progressively turns the LuaJIT runtime \(with libuv and SQLite
characteristics\) into a gradually typed system\.

Type itself is heavily overloaded, and we have our work cut out in manifesting
something which gives us what we want with reasonable tradeoffs\.

The easy to spot types in Lua are two: the first are the primitives, which are
what you get from calling `type`, plus a whole right world in the `ffi.cdef`
extension, which is from Lua's perspective just called `cdata`\.

The second are what we might call relational types: any two tables which share
a common metatable are in an obvious relational harmony which can and should
be expressed through a type system\.  Lua's metasyntactic extensions are a
natural fit for a certain sort of index\-oriented module\-and\-instance pattern,
which bears up under a certain amount of careful single inheritance\.


### Angle of Attack

One of the superpowers we've unlocked with the Bridge is the ability to parse
Lua into an enriched AST within the language\.  This should let us add a
fairly standard inferred type system based on the primitive Lua functions,
operators, and primitives, which is a start\.

This is part of the Lun/Clu project, which is its own beast, but the Cluster
codex must be considered within that context\.  What we are building is
fundamentally a set of runtime constraints on a dynamic language, designed to
allow the orthogonality of the basic primitives and concepts to compose nicely
into richer abstractions\.

The intention is that this knowledge will be useful during several stages,
in order: compile time, comptime, load time, and runtime\.  We necessarily work
backward toward that goal\.


## Concepts

  Cluster \(rhymes with cluck\) brings together a bewildering number of sources,
and out of bare necessity of discovery, I barely understand how it works now,
let alone once there is code in this repository\.


### Molds

  The question we're trying to answer with types, is what sorts of behaviors
and data a given object might contain or display\.

In hoon, everyone's favorite acid trip, the mold is one of the ways of
grappling with this reality\.

For our purposes, a mold is a way of constraining the rvalue of a given lvalue\.
This returns either the value, which in the general case is an Any, or
`nil, condition`\.  We'll talk about what conditions are and imply later, it's
a form of error, mostly\.

