module MetadataStreams

using DataAPI
using DataAPI: metadata, metadata!, metadatakeys, deletemetadata!, emptymetadata!

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

A subtype of `IO` for storing metadata alongside an IO stream. This
"""
struct MetadataStream{S<:IO,M<:Union{AbstractDict{Symbol},AbstractDict{String}}} <: IO
    stream::S
    metadata::M

    @inline MetadataStream(s, m) = new{typeof(s),typeof(m)}(s, m)
end

_getmd(ms::MetadataStream) = getfield(ms, :metadata)
_stream(ms::MetadataStream) = getfield(ms, :stream)

#region metadata interface
function DataAPI.metadata(ms::MetadataStream, key::Union{AbstractString,Symbol}; style::Bool=false)
    style ? _getmd(ms)[key] : getfield(_getmd(ms)[key], 1)
end
function DataAPI.metadata!(ms::MetadataStream, key::Union{AbstractString,Symbol}, val; style=nothing)
    setindex!(_getmd(ms), (val, style), key)
end
function DataAPI.deletemetadata!(ms::MetadataStream, key::Union{AbstractString,Symbol})
    delete!(_getmd(ms), key)
end
DataAPI.emptymetadata!(ms::MetadataStream) = empty!(_getmd(ms))
DataAPI.metadatakeys(ms::MetadataStream) = keys(_getmd(ms))
#endregion

#region IOContext support
# Base.in(p::Pair, ms::MetadataStream) = in(p, _stream(ms))
Base.haskey(ms::MetadataStream, key) = haskey(_stream(ms), key)
Base.getindex(ms::MetadataStream, key) = getindex(_stream(ms), key)
Base.get(ms::MetadataStream, key, default) = get(_stream(ms), key, default)
Base.keys(ms::MetadataStream) = keys(_stream(ms))
#endregion

#region IO interface
Base.fd(ms::MetadataStream) = fd(_stream(ms))
Base.isreadonly(ms::MetadataStream) = isreadonly(_stream(ms))
Base.isreadable(ms::MetadataStream) = isreadable(_stream(ms))
Base.iswritable(ms::MetadataStream) = iswritable(_stream(ms))
Base.stat(ms::MetadataStream) = stat(_stream(ms))
Base.eof(ms::MetadataStream) = eof(_stream(ms))
Base.position(ms::MetadataStream) = position(_stream(ms))
Base.close(ms::MetadataStream) = close(_stream(ms))
@static if isdefined(Base, :closewrite)
    Base.closewrite(ms::MetadataStream) = closewrite(_stream(ms))
end
Base.readavailable(ms::MetadataStream) = readavailable(_stream(ms))
Base.peek(ms::MetadataStream, ::Type{T}) where {T} = peek(_stream(ms), T)
Base.isopen(ms::MetadataStream) = isopen(_stream(ms))
Base.ismarked(ms::MetadataStream) = ismarked(_stream(ms))
Base.mark(ms::MetadataStream) = mark(_stream(ms))
Base.unmark(ms::MetadataStream) = unmark(_stream(ms))
Base.reset(ms::MetadataStream) = reset(_stream(ms))
Base.eachline(ms::MetadataStream; kwargs...) = eachline(_stream(ms); kwargs...)
Base.skip(ms::MetadataStream, n::Integer) = skip(_stream(ms), n)
Base.seekend(ms::MetadataStream) = seekend(_stream(ms))
Base.seek(ms::MetadataStream, n::Integer) = seek(_stream(ms), n)
Base.read(ms::MetadataStream, n::Integer) = read(_stream(ms), n)
Base.read!(ms::MetadataStream, n::Ref) = read!(_stream(ms), n)
Base.read!(ms::MetadataStream, n::AbstractArray) = read!(_stream(ms), n)
Base.read!(ms::MetadataStream, n::Array{UInt8}) = read!(_stream(ms), n)
Base.read!(ms::MetadataStream, n::BitArray) = read!(_stream(ms), n)
function Base.readuntil(ms::MetadataStream, c::UInt8; keep::Bool=false)
    readuntil(_stream(ms), c; keep=keep)
end
function Base.unsafe_read(ms::MetadataStream, p::Ptr{UInt8}, n::Integer)
    unsafe_read(_stream(ms), p, n)
end

Base.write(ms::MetadataStream, n::UInt8) = write(_stream(ms), n)
Base.write(ms::MetadataStream, n::BitArray) = write(_stream(ms), n)
Base.write(ms::MetadataStream, n::Base.CodeUnits) = write(_stream(ms), n)
function Base.write(ms::MetadataStream, n::Union{Float16, Float32, Float64, Int128, Int16, Int32, Int64, UInt128, UInt16, UInt32, UInt64})
    write(_stream(ms), n)
end
function Base.write(ms::MetadataStream, x::SubArray{T,N,P,I,L} where L where I where P<:Array) where {T, N}
    write(_stream(ms), x)
end
Base.flush(ms::MetadataStream) = Base.flush(_stream(ms))
Base.take!(ms::MetadataStream) = Base.take!(_stream(ms))
function Base.unsafe_write(ms::MetadataStream, p::Ptr{UInt8}, n::UInt)
    unsafe_write(_stream(ms), p, n)
end

Base.displaysize(ms::MetadataStream) = displaysize(_stream(ms))
Base.bytesavailable(ms::MetadataStream) = bytesavailable(_stream(ms))
#endregion

@specialize

# these caused many invalidations, so let's see how far we can get without them
# Base.write(ms::MetadataStream, n::Array) = write(_stream(ms), n)
# Base.write(ms::MetadataStream, n::AbstractArray) = write(_stream(ms), n)
# Base.trylock(ms::MetadataStream) = trylock(_stream(ms))
# Base.unlock(ms::MetadataStream) = unlock(_stream(ms))
# Base.lock(ms::MetadataStream) = lock(_stream(ms))

end
