# EZ Loader


  The idea is dead simple, it's a table which pulls all the project names out
of the database, and so we can say `ez.core.set` or `ez.deque.deque` and
just get them\.

It ends with a require string, this isn't so hard to do actually\. hmm\.

The refinement is we need to distinguish in many cases between eg\.
`project:mod` \(which is `ez.project.mod`\) and `project:mod/submod`, which must
be `ez.project.mod.submod`\.  Solution: **iff** a field has both a module and
modules related to it, the table it returns is callable as well as indexable,
so `ez.project.mod()` gets `require "project:mod"`\.

We also allow `ez.proj()`, giving what we currently call `"proj:proj"` though
we want to change the database a bit to make `"proj"` the unambiguous short
form for this\.


```lua
local conn = assert(require "bridge" . modules_conn)
```

#### Project ID table

We need all the project names and IDs first, no better time than load time\.

```sql
SELECT project_id as project, name FROM project;
```

Which we obtain immediately, mapping names to projects:

```lua
local project = {}

for i, id, name in conn:prepare(get_all_project):cols() do
   project[name] = id
end
```

To fetch the modules we prep a statement in advance:

```sql
SELECT DISTINCT module_id as ID, name FROM module
WHERE module.project = :id
GROUP BY name
ORDER BY MAX(module.time) DESC
```


#### EZ

We need a fancy index for this:

```lua
local EZ = {}
```

```lua
local get_mods = conn:prepare(get_distinct_modules)

function EZ.__index(tab, key)
   if project[key] then
      local modmap = {}
      for i, id, name in get_mods :bind(project[key]) :cols() do
         modmap[name] = id
      end
      -- we need one more metatable
      return modmap
   end
end
```


```lua
return setmetatable({}, EZ)
```
