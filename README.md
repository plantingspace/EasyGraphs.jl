# EasyGraphs.jl

A Julia package meant to make it easy to specify and draw graphs.

Features:
- graphs with node and edge labels of arbitrary type
- drawing of specified graphs
- DSL for easy drawing of graphs

> Nodes can not have Int labels for now.

Imperative graph specification:
```
g = EasyGraph()
push!(g, (:hates, "Bob" => "Alice"))
push!(g, (:loves, "Alice" => "Julia"))
draw(g)
```

Declarative graph specification:
```
g = EasyGraph((:hates, "Bob" => "Alice"), (:loves, "Alice" => "Julia"))
draw(g)
```

Easy DSL specification:
```
@draw begin
  :hates, "Bob" => "Alice"
  :loves, "Alice" => "Julia"
end
```

Multigraphs use a single edge with `Set` of labels:
```
@draw begin
  "hates", "Bob" => "Alice"
  "loves", "Bob" => "Alice"
end
```

Any types can be used:
```
@draw begin
  [1, 2], Dict(:a => :b) => "s"
end
```
