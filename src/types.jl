const SS = SubString{String}

subs(s::SS, from::Int, to::Int)::SS = @views s[from:to]
subs(s::SS, from::Int)              = subs(s, from, from)
subs(s::SS, range::UnitRange{Int})  = subs(s, range.start, range.stop)

subs(s::SS) = s
subs(s::String, a...) = subs(SS(s), a...)

parent(ss::SS)  = ss.string
from(s::String) = 1
from(ss::SS)    = 1 + ss.offset
to(s::String)   = lastindex(s)
to(ss::SS)      = lastindex(ss) + ss.offset


const SubVector{T} = SubArray{T, 1, Vector{T}, Tuple{UnitRange{Int64}}, true}

subv(v::Vector)      = @view v[1:length(v)]
subv(v::SubVector)   = v
parent(v::SubVector) = v.parent


const Token = Tuple{Int64, Int64, UInt32}

from(t::Token) = t[1]
to(t::Token)   = t[1] + t[2] - 1


const S3     = Union{String, SS}
const SV{T}  = SubVector{T}
const VSV{T} = Union{Vector{T}, SubVector{T}}


"""
    AbstractSpan

Section of a parent String with a specific meaning. All subtypes of
`AbstractSpan` must have an `span` field corresponding to the substring
associated to the block and a `name` field corresponding to a Symbol identifier
for the span.
"""
abstract type AbstractSpan end

span(s::AbstractSpan)::SS       = s.span
name(s::AbstractSpan)::Symbol   = s.name
parent(s::AbstractSpan)::String = parent(span(s))
from(s::AbstractSpan)::Int      = from(span(s))
to(s::AbstractSpan)::Int        = to(span(s))

Base.isempty(s::AbstractSpan)::Bool = isempty(strip(span(s)))


"""
    Block{case} <: AbstractSpan

Blocks are a span covering one or more tokens. Case is one of `:md`, `:html`,
or `:args` (helps the `content` function).
"""
struct Block{case} <: AbstractSpan
    name   ::Symbol
    span   ::SS
    tokens ::SubVector{Token}
end
Block{c}(name, ss::SS) where c = Block{c}(name, ss, EMPTY_TOKEN_SVEC)

"""
    Block(name, tokens)

Constructor where the span is implicitly `from(tokens[1])` to `to(tokens[end])`.
"""
function Block{c}(
            name::Symbol,
            s::String,
            tokens::SubVector{Token}
        ) where c
    return Block{c}(
        name,
        subs(s, from(tokens[1]), to(tokens[end])),
        tokens
    )
end

const md_block   = Block{:md}
const args_block = Block{:args}
const html_block = Block{:html}


"""
    BlockTemplate

Template for a block to find for the general case where a block goes from an
opening token to one of several possible closing tokens.
Blocks can allow or disallow nesting. For instance brace blocks can be nested
`{.{.}.}` but not comments.
When nesting is enabled, Franklin will try to find the closing token taking
into account the balance in opening-closing tokens.
"""
struct BlockTemplate
    name    ::Symbol
    opening ::Symbol
    closing ::NTuple{N, Symbol} where N
    nesting ::Bool
end
const BT = BlockTemplate

BlockTemplate(n, o=n, c::Symbol=o, ne=false) = BlockTemplate(n, o, (c,), ne)
BlockTemplate(n, o, c::NTuple,   ne=false) = BlockTempalte(n, o, c, ne)

const NO_CLOSING = (:none,) # is also used in find_blocks

SingleTokenBlockTemplate(n::Symbol) = BlockTemplate(n, n, NO_CLOSING)
