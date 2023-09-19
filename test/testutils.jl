using Test
using FP2
using Random

FP = FP2

import Base.(//)

isapproxstr(s1::AbstractString, s2::AbstractString) =
    isequal(map(s->replace(s, r"\s|\n"=>""), String.((s1, s2)))...)

# stricter than isapproxstr, just strips the outside.
(//)(s1::AbstractString, s2::AbstractString) = strip(s1) == strip(s2)
(//)(o::FP.AbstractSpan, s::AbstractString)  = FP.span(o) // s
(//)(b::FP.Block, s::AbstractString)         = FP.content(b) // s

(//)(o, t::Tuple) = (o.name == t[1] && o // t[2])

hardstr(n=20) = Random.randstring('a':'ζ', n)

function tokname(s)
    t = FP.md_tokenizer(s)
    return [FP.md_name(ti) for ti in t]
end
