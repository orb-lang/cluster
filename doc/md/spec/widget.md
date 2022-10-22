# Widget


  We've talked up widgets for a good long time now, and the new cluster needs
some sessions\.

Let us begin as we intend to continue\.

```lua
local core = require "qor:core"
local cluster = require "cluster:cluster"
local s = require "status:status" ()
```

```lua
local new, Widget, Widget_M = cluster.order()
```

Widgets can have a color and number, at base, 1 and black:

```lua
Widget.color = 'black'
Widget.number = 1
```

Which we can override with the builder:

```lua
cluster.construct(new,
   function(_, widget, color, number)
      widget.color = color
      widget.number = number
      return widget
   end)
```

Widgets can report:

```lua
local format = assert(string.format)

function Widget.report(widget)
   widget.as_reported = format("I'm a %s widget! number %d! hello!",
                 widget.color, widget.number)
   return widget.as_reported
end
```

And you can add them together, when you do, they return a new widget with the
color of the left widget and the sum of the two counts\.

We're going to be lazy and pretend there are two widgets, instead of checking,
because I haven't written `idest` yet\.

```lua
function Widget_M.__add(l_widget, r_widget)
   return new(l_widget.color, l_widget.number + r_widget.number)
end
```

See you in the session, widget\!

```lua
return new
```
