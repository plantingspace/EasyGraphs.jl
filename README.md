# EasyGraphs.jl

A Julia package meant to make it easy to specify and draw graphs.

Features:
- graphs with node and edge labels of arbitrary type
- drawing of specified graphs
- DSL for easy drawing of graphs

> Nodes can not have `Int` labels for now.

Imperative graph specification:
```
g = EasyGraph()
push!(g, ("Bob" => "Alice", :hates))
push!(g, ("Alice" => "Julia", :loves))
draw(g)
```

Declarative graph specification:
```
g = EasyGraph(("Bob" => "Alice", :hates), ("Alice" => "Julia", :loves))
draw(g)
```

Easy DSL specification:
```
@draw begin
  "Bob" => "Alice", :hates
  "Alice" => "Julia", :loves
end
```

Multigraphs use a single edge with `Set` of labels:
```
@draw begin
  "Bob" => "Alice", "hates"
  "Bob" => "Alice", "loves"
end
```

Any types can be used:
```
@draw begin
  Dict(:a => :b) => "s", [1, 2]
end
```

Self-edges are supported:
```
@draw begin
  :A => :A, :id
  :A => :B, :f
end
```

Single node with self-edge is broken due to https://github.com/JuliaPlots/GraphRecipes.jl/issues/97
