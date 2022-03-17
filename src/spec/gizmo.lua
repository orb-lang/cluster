





local core = require "qor:core"
local cluster = require "cluster:cluster"
local Widget = require "cluster:spec/widget"



local new, Gizmo, Gizmo_M = cluster.genus(Widget)





Gizmo.direction = 'up'





cluster.extendbuilder(new,
   function(_new, gizmo, color, number, direction)
      gizmo.direction = direction
      return gizmo
   end)





return new

