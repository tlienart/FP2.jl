@testset "args" begin
    s1 = hardstr()
    s2 = hardstr()
    s3 = hardstr()
    s = """
        \"$s1\"\"$s2\" $s3
        """
    b = FP.args_blockifier(s)

    @test length(b) == 2
    @test b[1] // s1
    @test b[2] // s2

    s = """
        \"$s1\" $s2 \"\"\"$s3\"\"\" $s2
        """
    b = FP.args_blockifier(s)
    @test length(b) == 2
    @test FP.content(b[1]) == s1
    @test FP.content(b[2]) == s3
end


@testset "html" begin
    s = raw"""
        <!--
          comment
        -->
        <script>
          script
        </script>
        {{
          dbb
        }}
        \( inline \)
        \[ block \]
        """
    b = FP.html_blockifier(s)
    @test FP.name.(b) == [
        :comment,
        :script,
        :dbb,
        :mathi,
        :mathd
    ]
    @test b[1] // "comment"
    @test b[2] // "script"
    @test b[3] // "dbb"
    @test b[4] // "inline"
    @test b[5] // "block"
end
