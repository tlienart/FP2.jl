using FP2
using BenchmarkTools

txt = read(joinpath(@__DIR__, "_x_foo.txt"), String);
html = read(joinpath(@__DIR__, "_x_foo.html"), String);

#
# last run: Sep 14, 2023
#

@btime FP2.md_tokenizer($txt)     # should take < 150μsq
@btime FP2.html_blockifier($html) # should take < 150μsq
