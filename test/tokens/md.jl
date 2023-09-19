@testset "basic" begin
    n = """
        A { B } C
        D } E { F
        """ |> FP.md_tokenizer .|> FP.md_name
    @test n == [
        :sos,
        :lbrace, :rbrace, :newline,
        :rbrace, :lbrace, :newline,
        :eos
    ]

    n = """
        A <!-- B --> C
        ---
        and +++
        """ |> FP.md_tokenizer .|> FP.md_name
    @test n == [
        :sos,
        :lcomment, :rcomment, :newline,
        :newline,
        :mddef,
        :eos
    ]
end
