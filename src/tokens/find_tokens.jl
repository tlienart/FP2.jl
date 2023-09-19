const TOKENS_MAPS  = (;
    md   = MD_TOKENS_MAP,
    html = HTML_TOKENS_MAP,
    args = ARGS_TOKENS_MAP
)
const TOKENS_NAMES = (;
    md   = first.(TOKENS_MAPS.md),
    html = first.(TOKENS_MAPS.html),
    args = first.(TOKENS_MAPS.args)
)
const TOKENS_RULES = (;
    md   = last.(TOKENS_MAPS.md),
    html = last.(TOKENS_MAPS.html),
    args = last.(TOKENS_MAPS.args)
)
const TOKENS_NAMES_MAPS = (;
    md   = Dict(s => UInt32(i) for (i, (s,_)) in enumerate(TOKENS_MAPS.md)),
    html = Dict(s => UInt32(i) for (i, (s,_)) in enumerate(TOKENS_MAPS.html)),
    args = Dict(s => UInt32(i) for (i, (s,_)) in enumerate(TOKENS_MAPS.args))
)


const SOS = -UInt32(1)
const EOS = -UInt32(2)

is_sos(t) = (t[3] == SOS)
is_eos(t) = (t[3] == EOS)

#
# Define
#   md_map, html_map, args_map  
#   md_name, html_name, args_name 
#   md_tokenizer, html_tokenizer, args_tokenizer
#

for (i, case) in enumerate((:md, :html, :args))
    fmap  = Symbol("$(case)_map")
    fname = Symbol("$(case)_name")
    tname = Symbol("$(case)_tokenizer")
    ex = quote
        make_tokenizer(TOKENS_RULES.$case, version=$i) |> eval
        $tname(s) = begin
            raw_tokens = collect(tokenize(UInt32, s, $i))
            filter!(rt -> !iszero(rt[3]), raw_tokens)
            n  = lastindex(s)
            nt = length(raw_tokens)

            tokens      = fill((0,0,UInt32(0)), nt+2)
            tokens[1]   = (1, 0, SOS)
            tokens[end] = (n, 0, EOS)
            @inbounds for k in 1:nt
                tokens[k+1] = raw_tokens[k]
            end
            return tokens
        end
        $fmap(n)  = TOKENS_NAMES_MAPS.$case[n]
        $fname(t) = begin
            is_sos(t) && return :sos
            is_eos(t) && return :eos
            return TOKENS_NAMES.$case[t[3]]            
        end
    end
    eval(ex)
end
