using AutoHashEquals

@auto_hash_equals struct NaturalMap{T}
    items::Vector{T}
    indices::Dict{T, Int}
    function NaturalMap{T}() where T
        new{T}([], Dict())
    end
    function NaturalMap(items::Vector{T})::NaturalMap{T} where T
        new{T}(items, Dict(e => i for (i, e) in enumerate(items)))
    end
end

function Base.getindex(nat::NaturalMap{T}, key::T)::Integer where T
    getindex(nat.indices, key)
end
function Base.getindex(nat::NaturalMap, key::Integer)
    getindex(nat.items, key)
end
function Base.get(nat::NaturalMap{T}, key::T)::Union{Integer, Nothing} where T
    get(nat.indices, key, nothing)
end
function Base.push!(nat::NaturalMap{T}, item::T) where T
    if !haskey(nat, item)
        push!(nat.items, item)
        nat.indices[item] = length(nat.items)
        true
    else
        false
    end
end
function Base.haskey(nat::NaturalMap{T}, key::T) where T
    haskey(nat.indices, key)
end
function Base.haskey(nat::NaturalMap, index::Integer)
    index <= length(nat.items)
end
function Base.delete!(nat::NaturalMap{T}, key::T) where T
    nat.items[nat.indices[key]] = nat.items[end]
    pop!(nat.items)
    delete!(nat.indices, key)
end
function Base.delete!(nat::NaturalMap, index::Integer)
    delete!(nat.indices, nat.items[index])
    nat.items[index] = nat.items[end]
    pop!(nat.items)
end