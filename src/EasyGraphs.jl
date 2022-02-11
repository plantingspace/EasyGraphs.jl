module EasyGraphs

include("NaturalMap.jl")

const EasyEdge = Tuple{Pair, T} where T

using Graphs
using Requires

function __init__()
    @require Plots="91a5bcdd-55d7-5caf-9e0b-520d859cae80" begin
        @require GraphRecipes="bd48cda9-67a9-57be-86fa-5b3c104eda73" begin
        using .Plots
        using .GraphRecipes

            draw(g::EasyGraph; kwargs...) = graphplot(
                g.lgraph,
                names=g.nodemap.items,
                edgelabel=edgelabels(g),
                nodeshape=:rect,
                fontsize=12,
                kwargs...
            )
        end
    end
    @require TikzGraphs="b4f28e30-c73f-5eaf-a395-8a9db949a742" begin
        function tdraw(g::EasyGraph; kwargs...)
            TikzGraphs.plot(
                g.lgraph,
                map(string, g.nodemap.items);
                edge_labels = edgelabels(g),
                edge_styles = edgestyles(g),
                options = "scale=3",
                kwargs...
            )
        end
    end
end

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

edgelabels(g::EasyGraph) = Dict(
                (k.src, k.dst) => v isa Set && length(v) == 1 ? first(v) : join(v, ", ")
                for (k, v) in g.edgelabels
            )
edgestyles(g::EasyGraph) = Dict(
    (k.src, k.dst) => "loop right"
    for (k, v) in g.edgelabels if k.src == k.dst
)

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

# ---------
# # Drawing

function draw end
function tdraw end

macro draw(ex)
    :(draw($(EasyGraph(ex))))
end

macro tdraw(ex)
    :(tdraw($(EasyGraph(ex))))
end

export EasyGraph, @EasyGraph, draw, @draw, tdraw, @tdraw

end
