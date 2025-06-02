# CustomHashDicts.jl

`Dict`s with customizable `hash` and `isequal` keys.

Ever wanted to use some custom type as the key of some `Dict` but run into problems because it doesn't matter the order
of the fields that they are equivalent? For example, let's take an edge of an undirected graph.

```julia
julia> struct Edge
           src::Int
           dst::Int
       end
```

If we want to map values to the edges, we will found out that `Dict` will distinguish between `Edge(1,2)` and `Edge(2,1)`
when we want them to be equivalent in this context.

```julia
julia> d = Dict{Edge,Int}()
Dict{Edge, Int64}()

julia> d[Edge(1,2)] = 1
1

julia> d[Edge(2,1)]
ERROR: KeyError: key Edge(2, 1) not found
Stacktrace:
 [1] getindex(h::Dict{Edge, Int64}, key::Edge)
   @ Base ./dict.jl:477
 [2] top-level scope
   @ REPL[14]:1
```

The solution to this is to specialize `hash` and `isequal` to trick `Dict` that the two elements are in fact the same.
But changing `hash` and `isequal` for the key type might be a change too large to assume.
Instead, `CustomHashDict` allows you to pass a couple of custom functions that replace `hash` and `isequal` just for the
context of this dictionary.

```julia
julia> edge_hash(e::Edge, h::UInt) = hash(e.src, h) ⊻ hash(e.dst, h)
edge_hash (generic function with 1 method)

julia> is_edge_equal(a::Edge, b::Edge) = a.src == b.src && a.dst == b.dst || a.src == b.dst && a.dst == b.src
is_edge_equal (generic function with 1 method)

julia> d = CustomHashDict{Edge,Int}(edge_hash, is_edge_equal)
CustomHashDict{Edge, Int64, typeof(edge_hash), typeof(is_edge_equal)}()

julia> d[Edge(1,2)] = 1
1

julia> d
CustomHashDict{Edge, Int64, typeof(edge_hash), typeof(is_edge_equal)} with 1 entry:
  Edge(1, 2) => 1

julia> d[Edge(2,1)] = 42
42

julia> d
CustomHashDict{Edge, Int64, typeof(edge_hash), typeof(is_edge_equal)} with 1 entry:
  Edge(2, 1) => 42

julia> haskey(d, Edge(2,1))
true

julia> haskey(d, Edge(1,2))
true
```
