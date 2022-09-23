module MetadataStreams

using DataAPI
using DataAPI: metadata, metadata!, metadatakeys, deletemetadata!, emptymetadata!
using PropertyDicts

export
    MetadataStream,
    metadata,
    metadata!,
    metadatakeys,
    deletemetadata!,
    emptymetadata!

@nospecialize

"""
    MetadataStream(stream, metadata::AbstractDict)

A subtype of `IO` for storing metadata alongside an IO stream. Interaction with metadata
is supported
"""
struct MetadataStream{S<:IO,M<:PropertyDict} <: IO
    stream::S
    metadata::M

    @inline MetadataStream(s, m::PropertyDict) = new{typeof(s),typeof(m)}(s, m)
    MetadataStream(s, m) = MetadataStream(s, PropertyDict(m))
    MetadataStream(s; kwargs...) = MetadataStream(p, PropertyDict(; kwargs...))
end

#region metadata interface
function DataAPI.metadata(ms::MetadataStream, key::AbstractString; style::Bool=false)
    style ? getproperty(getfield(ms, :metadata), key) : getfield(getproperty(getfield(ms, :metadata), key), 1)
end
function DataAPI.metadata(ms::MetadataStream, key::Symbol; style::Bool=false)
    style ? getproperty(getfield(ms, :metadata), key) : getfield(getproperty(getfield(ms, :metadata), key), 1)
end
function DataAPI.metadata!(ms::MetadataStream, key::AbstractString, val; style=nothing)
    setproperty!(getfield(ms, :metadata), key, (val, style))
end
function DataAPI.metadata!(ms::MetadataStream, key::Symbol, val; style=nothing)
    setproperty!(getfield(ms, :metadata), key, (val, style))
end
function DataAPI.deletemetadata!(ms::MetadataStream, key::Symbol)
    delete!(getfield(ms, :metadata), key)
end
function DataAPI.deletemetadata!(ms::MetadataStream, key::AbstractString)
    delete!(getfield(ms, :metadata), key)
end
DataAPI.emptymetadata!(ms::MetadataStream) = empty!(getfield(ms, :metadata))
DataAPI.metadatakeys(ms::MetadataStream) = keys(getfield(ms, :metadata))
#endregion

#region IOContext support
Base.in(p::Pair, ms::MetadataStream) = in(p, getfield(ms, :stream))
Base.haskey(ms::MetadataStream, key) = haskey(getfield(ms, :stream), key)
Base.getindex(ms::MetadataStream, key) = getindex(getfield(ms, :stream), key)
Base.get(ms::MetadataStream, key, default) = get(getfield(ms, :stream), key, default)
Base.keys(ms::MetadataStream) = keys(getfield(ms, :stream))
#endregion

#region IO interface
Base.isreadonly(ms::MetadataStream) = isreadonly(getfield(ms, :stream))
Base.isreadable(ms::MetadataStream) = isreadable(getfield(ms, :stream))
Base.iswritable(ms::MetadataStream) = iswritable(getfield(ms, :stream))
Base.stat(ms::MetadataStream) = stat(getfield(ms, :stream))
Base.eof(ms::MetadataStream) = eof(getfield(ms, :stream))
Base.position(ms::MetadataStream) = position(getfield(ms, :stream))
Base.close(ms::MetadataStream) = close(getfield(ms, :stream))
Base.closewrite(ms::MetadataStream) = closewrite(getfield(ms, :stream))
Base.isopen(ms::MetadataStream) = isopen(getfield(ms, :stream))
Base.ismarked(ms::MetadataStream) = ismarked(getfield(ms, :stream))
Base.mark(ms::MetadataStream) = mark(getfield(ms, :stream))
Base.unmark(ms::MetadataStream) = unmark(getfield(ms, :stream))
Base.reset(ms::MetadataStream) = reset(getfield(ms, :stream))
Base.seekend(ms::MetadataStream) = seekend(getfield(ms, :stream))
Base.countlines(ms::MetadataStream; kwargs...) = countlines(getfield(ms, :stream); kwargs...)
Base.eachline(ms::MetadataStream; kwargs...) = eachline(getfield(ms, :stream); kwargs...)
Base.skip(ms::MetadataStream, n::Integer) = skip(getfield(ms, :stream), n)
function Base.skipchars(p, ms::MetadataStream; linecomment=nothing)
    skipchars(p, getfield(ms, :stream); linecomment=linecomment)
end
Base.seek(ms::MetadataStream, n::Integer) = seek(getfield(ms, :stream), n)
Base.read(ms::MetadataStream, n::Integer) = read(getfield(ms, :stream), n)
Base.read!(ms::MetadataStream, n::Ref) = read!(getfield(ms, :stream), n)
Base.read!(ms::MetadataStream, n::AbstractArray) = read!(getfield(ms, :stream), n)
Base.read!(ms::MetadataStream, n::Array{UInt8}) = read!(getfield(ms, :stream), n)
Base.read!(ms::MetadataStream, n::BitArray) = read!(getfield(ms, :stream), n)
Base.write(ms::MetadataStream, n::Array) = write(getfield(ms, :stream), n)
Base.write(ms::MetadataStream, n::AbstractArray) = write(getfield(ms, :stream), n)
Base.write(ms::MetadataStream, n::BitArray) = write(getfield(ms, :stream), n)
Base.write(ms::MetadataStream, n::Base.CodeUnits) = write(getfield(ms, :stream), n)
function Base.write(ms::MetadataStream, n::Union{Float16, Float32, Float64, Int128, Int16, Int32, Int64, UInt128, UInt16, UInt32, UInt64})
    write(getfield(ms, :stream), n)
end
function Base.write(ms::MetadataStream, x::SubArray{T,N,P,I,L} where L where I where P<:Array) where {T, N}
    write(getfield(ms, :stream), x)
end
Base.flush(ms::MetadataStream) = Base.flush(getfield(ms, :stream))
Base.take!(ms::MetadataStream) = Base.take!(getfield(ms, :stream))
#endregion

@specialize

end
