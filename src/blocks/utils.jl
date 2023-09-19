"""
    span_between(b, i, j)

Span (substring) between token `i` and `j` of the block `b`.
"""
function span_between(b::Block, i::Int, j::Int)::SS
    s = parent(span(b))
    if j <= 0
        return subs(s,
            nextind(s, to(b.tokens[i])),
            prevind(s, from(b.tokens[end + j]))
        )
    end
    return subs(s,
        nextind(s, to(b.tokens[i])),
        prevind(s, from(b.tokens[j]))
    )
end


"""
    content(block)

Return the relevant content of a `Block`, for instance the content of a `{...}`
block would be `...`. Note EOS is a special '0 length' case to  deal with the
fact that a text can end with a token (which would then be an overlapping token
and an EOS).
"""
content(b::Block{:args})::SS = _content(b)

function content(b::Block{:html})::SS
    nb = name(b)
    nb == :dbb && return span_between(b, 1, 0)
    return _content(b)
end

function content(b::Block{:md})::SS
    nb = name(b)
    if nb == :text
        return span(b)

    elseif nb == :div
        return lstrip(span_between(b, 1, 0))

    elseif nb == :blockquote
        return strip(replace(
            span(b),
            r"(?:(?:^>)|(?:\n>))[ \t]*" => "\n")
        )

    elseif nb == :env
        return span_between(b, 3, -2)

    elseif nb == :dbb
        return span_between(b, 2, -1)

    elseif nb == :ref
        ps = parent(span(b))
        return subs(ps, 
            nextind(ps, next_index(b.tokens[2]), 2), # skip the `:⎵`
            to(b.ss)
        )
    end

    return _content(b)
end

function _content(b::Block)::SS
    s    = parent(span(b))
    idxo = nextind(s, to(b.tokens[1]))
    c    = b.tokens[end]
    t    = from(c)
    idxc = ifelse(is_eos(c), t, prevind(s, t))
    return subs(s, idxo, idxc)
end
