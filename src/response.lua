




































local s = require "status:status" ()
s.verbose = true



local autothread = require "cluster:autothread"














local Response = {}
Response.__index = Response
































local function new(co, handle)
   s:bore("created a response") --, trace %s", debug.traceback())
   local response = {}
   -- we're going to ignore the first argument and remove it
   response.co = coroutine.running()
   response.work = response.co
   response.handle = handle
   -- this should be a real flag I thing
   response[1] = response
   return setmetatable(response, Response)
end

Response.idEst = new

















Response.isResponse = true




























































function Response.pack(response, ...)
   response[1] = pack(...)
   return response
end











local resume = assert(coroutine.resume)

function Response.respond(response, ...)
   s:bore("responding") -- , debug.traceback())
   response:pack(...)
   if response.work == response.co then
      return resume(response.co, ...)
   else
      return autothread(response.work, ...)
   end
end





























function Response.ready(response)
   if response[1] == response then
      return false
   else
      return true
   end
end











function Response.unpack(response)
   return unpack(response[1])
end








function Response.__len(response)
   if response[1] == response then
      return 0
   end

   return #response[1]
end



return new

