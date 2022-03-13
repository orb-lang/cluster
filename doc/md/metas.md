# The Meta Metatable, \_\_meta


  The central vehicle for extension of the Lua Metaobject Protocol is the
metafield `__meta`\.

The first, and always load\-bearing, purpose of the `__meta` metaslot is to
handle any inheritance of metamethods to a metatable which deviates from the
master formula implemented by `cluster.meta`\.
