# Response


  Returned by asynchronous instances which intend to resume their own
coroutine\.


### Background

  Bridge programs are expected to run on the UV event loop as a matter of
course\.

In order to avoid the colored functions problem, we use a pattern where an
asynchronous event `yield`s itself after starting an event handler and passing
a callback\.  The callback then `resume`s the thread with the data returned
from uv\.

This cooperates well with a simple pattern of creating one coroutine for each
instance which has need of asynchrony, and simply ignoring the fact that it
yields when it has nowhere to go\.

The function which runs in this thread looks exactly like blocking code would\.

This is well and good until we need to use coroutines for anything else\.

That's where the Response comes in\.

Because we ignore the yield values of 'magic' coroutines, we can include a
table which becomes a second copy of the return values\.

Why? I want to demonstrate that it works before getting into that\.


## Response

This should be a `species` because no extension is intended, and I would
prefer to use a simple function for `new`\.

In the meantime, I'm going to hand\-roll a meta\-compatible pattern, which is
simple enough:

```lua
local Response = {}
Response.__index = Response
```

Responses are created with an index which contains only a reference to itself
at \[1\], on the reasonable premise that `nil` might wish to be returned but
there is never any call for the process to `resume` the response itself\.


### Response\(\) \-> Reponse

```lua
local function new()
   local response = {}
   response[1] = response
   return setmetatable(response, Response)
end

Response.idEst = new
```


## Interface

The idea is that the async process returns the values two ways: by packing
them into the Response table \(which was yielded before the 'await'\), and
by resuming them into the original thread\.

The consumer interface has two methods, and the producer side one\.

We present these in the order they will be called\.

### Reponse:ready\(\) \-> boolean

  A predicate called by the consumer side, which answers whether the data is
ready for use\.

Hopefully straightforward, we're simply using the instance itself as the
placeholder, in a may\-as\-well sort of way\.

```lua
function Response.ready(response)
   if response[1] == response then
      return false
   else
      return true
   end
end
```

This is matched on the producer side with `:pack`\.


### Response:pack\(\.\.\.\) \-> response

  The intention of this method is that the async process which created the
Response, will call it on the same parameters, which it returns immediately
thereafter by resuming the coroutine which earlier yielded the response\.

This is paired with `:unpack`, and internally `pack` and `unpack` are called\.

This gets around what must be a bug in LuaJIT, where the value of `.n` is
ignored by `unpack`, but only sometimes, and never for a table created with
`pack`\.

Annoying though it is, correctness is worth the extra allocation needed in
this implementation\.

```lua
function Response.pack(response, ...)
   response[1] = pack(...)
   return response
end
```


### Response:unpack\(\) \-> \.\.\.

Returns the unpacked paramters\.

```lua
function Response.unpack(response)
   return unpack(response[1])
end
```

```lua
return new
```
