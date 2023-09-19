include("../testutils.jl")


@testset "SubString" begin
    s  = randstring('a':'ζ', 25)
    ss = P.subs(s, nextind(s, 7), nextind(s, 17))
    @test s[P.from(ss):P.to(ss)] == ss
    @test P.parent(ss) === s
    @test s[P.from(s):P.to(s)] == s
end

@testset "SubVector" begin
    v  = shuffle(1:500)
    a  = 23
    b  = 78
    vv = @view v[a:b]
    @test vv isa P.SubVector{Int}
    @test P.parent(vv) === v
end

@testset "Token" begin
    t = (1, 5, UInt32(2))
    @test t isa P.Token
    @test P.from(t) == 1
    @test P.to(t) == 1 + 5
end

@testset "Block" begin
    b = P.Block(
        :abc,
        P.subs("abcdef"),
        P.subv(
            [
                (1, 0, -UInt32(1)),
                (1, 1, UInt32(1)),
                (2, 1, UInt32(2)),
                (lastindex("abcdef"), 0, -UInt32(2))
            ]
        )
    )
    @test P.name(b) == :abc
    @test P.span(b) == "abcdef"
end
