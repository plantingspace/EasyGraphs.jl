module EasyGraphs

include("NaturalMap.jl")

EasyEdge = Tuple{Pair, T} where T

using LightGraphs, Plots, GraphRecipes, TikzGraphs

struct EasyGraph <: AbstractGraph{Int}
    lgraph::SimpleDiGraph{Int}
    nodemap::NaturalMap{Any}
    "Store either only function name or function name and original return type."
    edgelabels::Dict{Edge{Int}, Any}
end

EasyGraph() = EasyGraph(SimpleDiGraph{Int}(), NaturalMap{Any}(), Dict())

function Base.push!(graph::EasyGraph, edge::EasyEdge)
    ((src, dst), label) = edge
    if push!(graph.nodemap, src) add_vertex!(graph.lgraph) end
    if push!(graph.nodemap, dst) add_vertex!(graph.lgraph) end
    ledge = Edge(graph.nodemap[src], graph.nodemap[dst])
    add_edge!(graph.lgraph, ledge)
    if !isnothing(label)
        push!(get!(Set, graph.edgelabels, ledge), label)
    end
    graph
end

function Base.push!(graph::EasyGraph, edge::Pair)
    push!(graph, (edge, nothing))
end

function Base.delete!(graph::EasyGraph, vertex::Any)
    index = graph.nodemap[vertex]
    lastindex = length(graph.nodemap.items)
    rem_vertex!(graph.lgraph, graph.nodemap[vertex])
    delete!(graph.nodemap, vertex)
    for (edge, label) in graph.edgelabels
        if edge.src == index || edge.dst == index
            delete!(graph.edgelabels, edge)
        elseif edge.src != lastindex && edge.dst != lastindex
            continue
        end
        newsrc = edge.src == lastindex ? index : edge.src
        newdst = edge.dst == lastindex ? index : edge.dst
        graph.edgelabels[Edge(newsrc => newdst)] = label
    end
    graph
end

EasyGraph(edges::Union{EasyEdge, Pair}...) = reduce(push!, edges; init=EasyGraph())

function EasyGraph(ex::Expr)
    if ex.head == :block
        edges = filter(e -> !(e isa LineNumberNode), ex.args)
    else
        edges = [ex]
    end
    :(EasyGraph($(edges...)))
end

macro EasyGraph(ex)
    EasyGraph(ex)
end

edgelabels(g::EasyGraph) = Dict(
    (k.src, k.dst) => v isa Set && length(v) == 1 ? first(v) : join(v, ", ")
      for (k, v) in g.edgelabels
)

draw(g::EasyGraph; kwargs...) = graphplot(
    g.lgraph,
    names=g.nodemap.items,
    edgelabel= edgelabels(g),
    nodeshape=:rect,
    fontsize=12,
    kwargs...
)

edgestyles(g::EasyGraph) = Dict(
    (k.src, k.dst) => "loop right"
      for (k, v) in g.edgelabels if k.src == k.dst
)

tdraw(g::EasyGraph; kwargs...) = TikzGraphs.plot(
    g.lgraph,
    map(string, g.nodemap.items);
    edge_labels = edgelabels(g),
    edge_styles = edgestyles(g),
    options = "scale=3",
    kwargs...
)

macro draw(ex)
    :(draw($(EasyGraph(ex))))
end

macro tdraw(ex)
    :(tdraw($(EasyGraph(ex))))
end


export EasyGraph, @EasyGraph, draw, @draw, tdraw, @tdraw

end
