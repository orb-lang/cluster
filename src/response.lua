









































local Response = {}
Response.__index = Response










local function new()
   local response = {}
   response[1] = response
   return setmetatable(response, Response)
end

Response.idEst = new






















function Response.ready(response)
   if response[1] == response then
      return false
   else
      return true
   end
end





















function Response.pack(response, ...)
   response[1] = pack(...)
   return response
end








function Response.unpack(response)
   return unpack(response[1])
end



return new

