






local N_G = {
   _OG = _G,
   setmeta = setmetatable,
   getmeta = getmetatable,
   yield   = assert(coroutine.yield),
   resume  = assert(coroutine.resume),
   _VERSION = _VERSION,
   arg = arg,
   assert = assert,
   bit = bit,
   collectgarbage = collectgarbage,
   debug = debug,
   dofile = dofile,
   error = error,
   gcinfo = gcinfo,
   getfenv = getfenv,
   io = io,
   ipairs = ipairs,
   jit = jit,
   load = load,
   loadfile = loadfile,
   loadstring = loadstring,
   math = math,
   newproxy = newproxy,
   next = next,
   os = os,
   pack = pack,
   package = package,
   pairs = pairs,
   pcall = pcall,
   print = print,
   rawequal = rawequal,
   rawget = rawget,
   rawlen = rawlen,
   rawset = rawset,
   require = require,
   select = select,
   setfenv = setfenv,
   string = string,
   table = table,
   tonumber = tonumber,
   tostring = tostring,
   type = type,
   unpack = unpack,
   xpcall = xpcall,
}













local create = assert(coroutine.create)
local coro = setmetatable({}, { __call = function(_, fn)
                                            return create(fn)
                                         end })
for k,v in pairs(coroutine) do
   coro[k] = v
end

N_G.coro = coro



return N_G

