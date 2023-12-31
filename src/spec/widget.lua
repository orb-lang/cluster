








local core = require "qor:core"
local cluster = require "cluster:cluster"
local s = require "status:status" ()



local new, Widget, Widget_M = cluster.order()





Widget.color = 'black'
Widget.number = 1





cluster.construct(new,
   function(_, widget, color, number)
      widget.color = color
      widget.number = number
      return widget
   end)





local format = assert(string.format)

function Widget.report(widget)
   widget.as_reported = format("I'm a %s widget! number %d! hello!",
                 widget.color, widget.number)
   return widget.as_reported
end









function Widget_M.__add(l_widget, r_widget)
   return new(l_widget.color, l_widget.number + r_widget.number)
end





return new

