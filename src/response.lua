















































local s = require "status:status" ()
s.verbose = true












local autothread = require "cluster:autothread"






local Response = {}
Response.__index = Response











































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




















Response.isResponse = true




















































function Response.pack(response, ...)
   response[1] = pack(...)
   return response
end









local resume = assert(coroutine.resume)

function Response.respond(response, ...)
   response.pending = false
   local thread = response.autothread or autothread
   response:pack(...)
   if response.work == response.co then
      return resume(response.co, ...)
   else
      return thread(response.work, ...)
   end
end




























function Response.ready(response)
   return not response.pending
end











function Response.unpack(response)
   return unpack(response[1])
end








function Response.__len(response)
   if response.pending then
      return 0
   end

   return #response[1]
end



return new

