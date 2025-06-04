using Test
using CustomHashDicts

struct Edge{T}
    src::T
    dst::T
end

edge_hash(e::Edge, h) = hash(e.src, h) ⊻ hash(e.dst, h)
is_edge_equal(a::Edge, b::Edge) = a.src == b.src && a.dst == b.dst || a.src == b.dst && a.dst == b.src

d = CustomHashDict{Edge,Int,typeof(edge_hash),typeof(is_edge_equal)}()

d[Edge(1, 2)] = 1
@test haskey(d, Edge(1, 2))
@test haskey(d, Edge(2, 1))
@test d[Edge(1, 2)] == 1
@test d[Edge(2, 1)] == 1

d[Edge(2, 1)] = 2
@test haskey(d, Edge(1, 2))
@test haskey(d, Edge(2, 1))
@test d[Edge(1, 2)] == 2
@test d[Edge(2, 1)] == 2

@test length(d) == 1
