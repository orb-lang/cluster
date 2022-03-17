





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





local format, gsub = assert(string.format), assert(string.gsub)


cluster.extend.super(Gizmo, "report",
   function(gizmo, as_widget)
      if as_widget ~= 'as-widget' then
         -- some delicate surgery
         local report = gizmo.as_reported
                           :gsub("widget", "gizmo")
                           :gsub("hello!", "my direction is %%s! hello!")
         gizmo.as_reported = format(report, gizmo.direction)
      end
      return gizmo.as_reported
   end)





return new

