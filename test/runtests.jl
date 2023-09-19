using Test

include("testutils.jl")

@testset "tokenizers" begin
    include("tokens/md.jl")
    include("tokens/html.jl")
    include("tokens/args.jl")
end

@testset "blocks" begin
    include("blocks/args_html.jl")
end
