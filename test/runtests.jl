using MetadataStreams
using Test

@testset "MetadataStreams.jl" begin
    # Write your tests here.

    io = IOBuffer()
    #ms = Metadata.test_wrapper(MetadataStream, io)
    m = Dict{Symbol,Tuple{Any,Any}}()
    ms = MetadataStream(IOBuffer(), m)

    @test isempty(metadatakeys(ms))
    m[:m1] = (1,nothing)
    @test metadata(ms, :m1) == 1

    #=
    y = share_metadata(x, ones(2, 2))
    @test y isa Metadata.MetaArray
    @test metadata(x) === metadata(y)

    y = copy_metadata(x, ones(2, 2))
    @test y isa Metadata.MetaArray
    @test metadata(x) == metadata(y)
    @test metadata(x) !== metadata(y)

    y = drop_metadata(x)
    @test !has_metadata(y)
    @test y == data
    =#

    empty!(m)

    @test position(ms) == 0
    @test !isreadonly(ms)
    @test isreadable(ms)
    @test iswritable(ms)
    @test isopen(ms)
    @test !ismarked(ms)

    s = sizeof(Int)
    write(ms, 1)
    @test position(ms) == s
    seek(ms, 0)
    @test read(ms, Int) == 1
    seek(ms, 0)
    write(ms, [1, 2])
    write(ms, view([1 , 2], :))
    write(ms, [1,2]')
    seek(ms, 0)
    @test read!(ms, Vector{Int}(undef, 2)) == [1, 2]
    skip(ms, s)
    @test position(ms) == 3s
    mark(ms)
    @test ismarked(ms)
    seek(ms, 0)
    @test reset(ms) == 3s
    @test position(ms) == 3s
    mark(ms)
    @test ismarked(ms)
    unmark(ms)
    @test !ismarked(ms)
    seekend(ms)
    @test eof(ms)
    close(ms)
    @test !isopen(ms)
end

#If I understand correctly, we don't actually require that the underlying value associated with each key be physically stored as `Tuple{Any,Any}`. It can just
