














































local Response = {}
Response.__index = Response
































local function new(co, handle)
   local response = {}
   response.co = co or coroutine.running()
   response.handle = handle
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

function Response.respond(response, co, ...)
   response:pack(...)
   return resume(response.co, co, ...)
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

