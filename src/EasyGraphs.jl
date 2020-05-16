module EasyGraphs

include("NaturalMap.jl")

EasyEdge = Tuple{T, Pair} where T

using LightGraphs
using GraphRecipes

struct EasyGraph <: AbstractGraph{Int}
    lgraph::SimpleDiGraph{Int}
    nodemap::NaturalMap{Any}
    "Store either only function name or function name and original return type."
    edgelabels::Dict{Edge{Int}, Any}
end

EasyGraph() = EasyGraph(SimpleDiGraph{Int}(), NaturalMap{Any}(), Dict())

function Base.push!(graph::EasyGraph, edge::EasyEdge)
    (label, (src, dst)) = edge
    if push!(graph.nodemap, src) add_vertex!(graph.lgraph) end
    if push!(graph.nodemap, dst) add_vertex!(graph.lgraph) end
    ledge = Edge(graph.nodemap[src], graph.nodemap[dst])
    add_edge!(graph.lgraph, ledge)
    push!(get!(Set, graph.edgelabels, ledge), label)
    graph
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

EasyGraph(edges::EasyEdge...) = reduce(push!, edges; init=EasyGraph())

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

draw(g::EasyGraph; kwargs...) = graphplot(
    g.lgraph,
    names=g.nodemap.items,
    edgelabel=Dict(
        (k.src, k.dst) => v isa Set && length(v) == 1 ? first(v) : join(v, ", ")
        for (k, v) in g.edgelabels
    ),
    nodeshape=:rect;
    kwargs...
)

macro draw(ex)
    :(draw($(EasyGraph(ex))))
end

export EasyGraph, draw, @draw

end