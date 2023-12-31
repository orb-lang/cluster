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

Because we ignore the yield values of 'magic' coroutines, we can return
anything we want\.

The bridge protocol specifies that async processes which expect to resume
their own thread on a subsequent handle return a Response\.

This allows us to set up an environment where magic coroutines and any other
use of coroutines can cooperate with each other\.


##### About the YAGNI tag

I'm trying to clearly demarcate which parts of this interface are actually
used, and which parts are just contemplated for future use\.

It stands for You \(Ain't/Are\) Gonna Need It\.


#### imports

```lua
local s = require "status:status" ()
s.verbose = true
```


#### autothread

  Autothread is our little trick to restart coroutines which come from a
coroutine nest\.

We check a `.blue` / `.autothread` ::Deprecated:: field on the Response, which
we use if provided, defaulting to standard autothread:

```lua
local autothread = require "cluster:autothread"
```


## Response

```lua
local Response = {}
Response.__index = Response
```

The original intention of the Response was to `pack` all the resumed values,
so that the coroutine could die and they would still be accessible\.

The code still does this, although it didn't turn out to solve the problem
this module was created to solve\.

What does solve it is that reference to the coroutine\.


#### The One Weird Trick

We're using coroutine nests to implement message passing in Actors\.  This
pattern creates a version of the familiar `coroutine` table, one with new
functions named `create`, `resume` and `yield`, such that the new `resume`
will only see a coroutine created by the corresponding `create`, and yielded
by the nest's `yield`\.  Otherwise it yields itself\.  There is a `wrap` to
complete the set\.

So what we do is set up `autothread` on any input into Modeselektor\. If any
magic coroutine yields inside the event response, this gets to autothread,
which replaces the Response coroutine on `.work` with the work coroutine\.

When this is resumed, it travels all the way back to get the returned, without
breaking the Message\-passing system or losing our frame\.

If the Response sees a different value for `.work` than the original coroutine
on `.co`, it autothreads again\.  This allows control flow to move through
asynchronous callbacks in a mostly\-transparent way\.


### Response\(handle\)

The handle is attached so that some future system can override autothread with
a supervising loop which takes care of long\-running processes\.

We used to pass in the coroutine but there's no advantage in doing this\.

The running coroutine is placed at both `.co` and `.work`, since we only need
to autothread a response if these differ\.

```lua
local running = assert(coroutine.running)

local function new(handle)
   s:bore("created a response") --, trace %s", debug.traceback())
   local response = {}
   response.co = running()
   response.work = response.co
   response.handle = handle
   response.pending = true
   return setmetatable(response, Response)
end

Response.idEst = new
```


#### Response\.isResponse

We provide a simple flag for Response detection\.

I've mostly used this technique, ironically, to get past the limitations of the
`idEst` pattern\.

We're moving toward `idest` as a pervasive global with general applicability,
but it is not in fact a keyword, nor a language primitive\.

Consumers of a Response aren't expected to be producers of them\.  This flag
makes it unnecessary to require this module to enquire\.

This also avoids resolving the circular require `autothread` would otherwise
call for\.

```lua
Response.isResponse = true
```


## Interface

  The idea is that the Response contains the coroutine which will be used to
resume on the far side of the callback, and the handle which it will resume
on\.  When the callback is triggered, the Response will also `:pack` the
resumed data into `[1]`, where it can subsequently be retrieved with
`:unpack`\.

As mentioned, the usual move is to replace the coroutine and expect everything
to work out\.  If it doesn't then the Response is an opportunity to clean up
afterwards, and knowing what the callback returned with might be helpful\.

The use of responses by replacing coroutines was added after I put in all the
`:pack` and `:unpack` logic, because I hadn't thought of something which would
actually *work*\.

I'm leaving it in because, again, it's a chance to look at the response value
from the callback if things break, and architectures with a lot of coroutines
and callbacks don't leave lengthy stack traces\.

We're left with something which can do two things: restart a gnarly twist of
async code, and provide some limited introspection from outside if things go
wrong\.  It's also a hook for more complex supervisory behaviors, none
implemented\.


### Producer: :respond

  The producer follows the magic coroutine pattern by setting up an event with
a callback, then yielding the response immediately\.

The goal of the Response protocol is to support two pathways\.  The magic
pathway ignores the response completely and resumes the data returned to the
callback directly, while the autothreaded pathway replaces the Response's
coroutine with one which will get back down to the callback when `resume`d\.


#### Response:pack\(\.\.\.\) \-> response  \#YAGNI

  This is only the action of packing the response values, most applications
will use `:respond`, which calls this\.

We use `pack` itself to make a new table, which we put at `[1]`

This gets around what must be a bug in LuaJIT, where the value of `.n` is
ignored by `unpack`, but only sometimes, and never for a table created with
`pack`\.

```lua
function Response.pack(response, ...)
   response[1] = pack(...)
   return response
end
```


#### Response:respond\(co, \.\.\.\) \-> resume\(co, \.\.\.\)

  This combines packing the arguments into the Response and resuming the
coroutine\.

```lua
local resume = assert(coroutine.resume)

function Response.respond(response, ...)
   response.pending = false
   local thread = response.blue or response.autothread or autothread
   response:pack(...)
   if response.work == response.co then
      return resume(response.co, ...)
   else
      return thread(response.work, ...)
   end
end
```


### Consumer Methods: :ready and :unpack

  The primary point of returning a Response is so that the function at the top
of a yield chain can replace the original coroutine with one which will walk
down the resume chain back to the original point of yield\.

This makes it possible to use those async processes in a way which cooperates
with message passing\.

The main consumer interface is therefore replacing the value of `.work`,
rather than calling methods\.

Two are however available\.  `:ready` means the coroutine has resumed with
data, and `:unpack` will unpack that data, with no regard to any subsequent
execution prompted by the coroutine resuming\.


### Reponse:ready\(\) \-> boolean  \#YAGNI

  A predicate which may be called by the consumer side, which answers whether
the data is ready for use\.

Returns the negation of the `.pending` flag\.

```lua
function Response.ready(response)
   return not response.pending
end
```

The Response will continue to return `false` on `:ready` until the producer
calls `:pack`, or more likely `:respond`\.


### Response:unpack\(\) \-> \.\.\.  \#YAGNI

Returns the unpacked parameters\.

```lua
function Response.unpack(response)
   return unpack(response[1])
end
```

### \#Response  \#YAGNI

Returns the amount of parameters available, which will be 0 until the
response is `:ready`\.

```lua
function Response.__len(response)
   if response.pending then
      return 0
   end

   return #response[1]
end
```

```lua
return new
```


## More With Response

This is a powerful tool for control flow\. At the moment, it's doing more than
it needs to, what with `:pack` being called internally while I have yet to use
`:unpack`\.

It's capable of doing quite a bit more than threading the old needle through
the twists of the shell\.  Because we use `:respond`, we have a chance to take
conditional action, including deferring further action\.

That seems like the most interesting one: instead of resuming, we build a
thunk and exit the callback\.  The Response can call the thunk at any point to
resume execution\.

I'm dreaming up reasons to have this but it's worth waiting to actually have
one\.  The idea is that we'll add a flag, `.suspend`, which is set to `false`
on `Response`\.  If the consumer sets it to true, then we build a
thunk to resume, and exit, the Response would be restarted with `:continue`\.
