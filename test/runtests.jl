using MetadataStreams
using Test

# Write your tests here.

io = IOBuffer()
#ms = Metadata.test_wrapper(MetadataStream, io)
m = Dict{Symbol,Tuple{Any,Any}}()
ms = MetadataStream(IOBuffer(), m)

@testset "metadata interface" begin
    @test isempty(metadatakeys(ms))
    m[:m1] = (1,nothing)
    @test metadata(ms, :m1) == 1
    metadata!(ms, :m2, 2)
    deletemetadata!(ms, :m2)
    @test !haskey(m, :m2)
    emptymetadata!(ms)
    @test isempty(m)
end

@testset "IO Interface" begin
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

@testset "IOContext support" begin
    ms = MetadataStream(IOContext(IOBuffer(), :compact => true, :limit => true), m)
    @test haskey(ms, :limit)
    @test ms[:limit]
    @test get(ms, :limit, nothing)
    @test in(:compact, keys(ms))
end
