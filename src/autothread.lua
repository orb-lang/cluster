






























































local create, status = assert(coroutine.create), assert(coroutine.status)
local yield, resume = assert(coroutine.yield), assert(coroutine.resume)

local function autothreader(thread)
   return function(...)
      local work;
      if type(thread) == 'thread' then
         work = thread
      elseif type(thread) == 'function' then
         work = create(thread)
      else -- if thread isn't callable this will break
         work = create(function(...)
                          return thread(...)
                       end)
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
end

local autothread = function(thread, ...) return autothreader(thread)(...) end




return autothread

