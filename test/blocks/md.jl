@testset "raw" begin
    s = """
    abc
    ??? <!-- ???
    def
    """
    b = FP.md_blockifier(s)
    @test b[1] // (:rawinput, "<!--")
end

@testset "containers-basic" begin
    s1 = hardstr()
    s2 = hardstr()
    s3 = hardstr()

    b = """
    <!--$s1-->~~~$s2~~~
    +++
    $s3
    +++
    """ |> FP.md_blockifier
    @test b[1] // (:comment, s1)
    @test b[2] // (:htmlinput, s2)
    @test b[3] // (:mddef, s3)
end
    