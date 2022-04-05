# Autothread


  Recursively resumes responses\.


## The Challenge

  Our asynchronous functions yield a response, which they later call\.  This
works right up until we try to do something else with coroutines, then it
falls flat\.

The middle layer of the solution uses coroutine nests, and the top and bottom
use `autothread`\.

```lua
local create, status = assert(coroutine.create), assert(coroutine.status)
local yield, resume = assert(coroutine.yield), assert(coroutine.resume)

local function autothread(thread, ...)
   local work;
   if type(thread) == 'thread' then
      work = thread
   else
      work = create(thread)
   end
   local res = pack(resume(work, ...))
   local ok, response, state = res[1], res[2], status(work)
   if ok and state == 'dead' then
      return select(2, unpack(res))
   elseif not ok then
      error(response)
   elseif type(response) == 'table' and response.isResponse then
      response.work = work
   else
      yield(select(2, unpack(res)))
   end

   return nil
end
```

```lua
return autothread
```
