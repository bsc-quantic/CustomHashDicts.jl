module CustomHashDicts

export CustomHashDict

struct WrapKey{K,Hash<:Function,IsEqual<:Function}
    key::K
    hash::Hash
    isequal::IsEqual
end

function Base.convert(::Type{WrapKey{K,Hash,IsEqual}}, wrap_key::WrapKey) where {K,Hash,IsEqual}
    WrapKey{K,Hash,IsEqual}(wrap_key.key, wrap_key.hash, wrap_key.isequal)
end

Base.hash(w::WrapKey, h::UInt) = w.hash(w.key, h)
Base.isequal(w1::WrapKey, w2::WrapKey) = w1.isequal(w1.key, w2.key)

struct CustomHashDict{K,V,Hash<:Function,IsEqual<:Function} <: AbstractDict{K,V}
    dict::Dict{WrapKey{K,Hash,IsEqual},V}
    hash::Hash
    isequal::IsEqual
end

CustomHashDict{K,V}() where {K,V} = CustomHashDict{K,V}(hash, isequal)

function CustomHashDict{K,V}(hash_f::Hash, isequal_f::IsEqual) where {K,V,Hash,IsEqual}
    CustomHashDict{K,V,Hash,IsEqual}(Dict{WrapKey{K,Hash,IsEqual},V}(), hash_f, isequal_f)
end

# AbstractDict interface
Base.keys(d::CustomHashDict) = Iterators.map(kw -> kw.key, keys(d.dict))
Base.values(d::CustomHashDict) = values(d.dict)

Base.haskey(d::CustomHashDict, key::WrapKey) = haskey(d.dict, key)
Base.haskey(d::CustomHashDict, key) = haskey(d.dict, WrapKey(key, d.hash, d.isequal))

Base.delete!(d::CustomHashDict, key::WrapKey) = delete!(d.dict, key)
Base.delete!(d::CustomHashDict, key) = delete!(d.dict, WrapKey(key, d.hash, d.isequal))

Base.get(d::CustomHashDict, key::WrapKey, default) = get(d.dict, key, default)
Base.get(d::CustomHashDict, key, default) = get(d.dict, WrapKey(key, d.hash, d.isequal), default)

# Iteration interface
function Base.iterate(d::CustomHashDict, state=nothing)
    res = isnothing(state) ? iterate(d.dict) : iterate(d.dict, state)
    isnothing(res) && return nothing
    p, state = res
    return p[1].key => p[2], state
end

Base.length(d::CustomHashDict) = length(d.dict)

# Indexing interface
Base.getindex(d::CustomHashDict, key::WrapKey) = getindex(d.dict, key)
Base.getindex(d::CustomHashDict, key) = getindex(d.dict, WrapKey(key, d.hash, d.isequal))

Base.setindex!(d::CustomHashDict, value, key::WrapKey) = setindex!(d.dict, value, key)
Base.setindex!(d::CustomHashDict, value, key) = setindex!(d.dict, value, WrapKey(key, d.hash, d.isequal))

end
