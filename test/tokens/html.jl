@testset "basic" begin
    n = """
        A {{ B }} <!-- C -->
        <script> hello </script>
        """ |> FP.html_tokenizer .|> FP.html_name
    @test n == [
        :sos,
        :ldbrace, :rdbrace, :lcomment, :rcomment,
        :lscript, :rscript,
        :eos
    ]
end
