for case in (:args, :html)
    nname  = Symbol("$(case)_name")
    tname  = Symbol("$(case)_tokenizer")
    bname  = Symbol("$(case)_blockifier")
    tmpl   = Symbol(uppercase("$case") * "_BLOCKS")
    cblock = Symbol("$(case)_block")
    ex = quote
        function $bname(s::S3, tokens::VSV{Token})
            blocks = $cblock[]
            find_blocks!(
                blocks,
                s,
                tokens,
                $tmpl,
                $nname
            )
            return blocks
        end
        $bname(s::S3) = $bname(s, $tname(s))
    end
    eval(ex)
end

function md_blockifier(s::S3, tokens::VSV{Token})
    blocks    = Block{:md}[]
    is_active = ones(Bool, length(tokens))
    for tmpl in (MD_BLOCKS_RAW, MD_BLOCKS_CONTAINERS)
        find_blocks!(
            blocks,
            s,
            tokens,
            tmpl,
            md_name;
            is_active
        )
    end
    return blocks
end
md_blockifier(s::S3) = md_blockifier(s, md_tokenizer(s))
    


function find_blocks!(
            blocks::Vector{Block{case}},
            s::S3,
            tokens::VSV{Token},
            templates::Dict{Symbol, BlockTemplate},
            token_name::Function
            ;
            is_active::Vector{Bool} = ones(Bool, length(tokens)),
            check_newline::Bool     = false
        ) where case
    
    #
    # keep track of what was deactivated, this is useful for md parsing
    # when discarding BRACKET tokens and re-enabling the tokens inside them;
    # only the tokens deactivated by it should be re-enabled.
    # so for instance:
    #   (abc _@@d *g* @@_ ef) --> first pass will deactivate `*`
    #   --> we should only re-enable `_`.
    #
    deactivated_tokens = Int[]
    isempty(tokens) && return deactivated_tokens

    template_keys = keys(templates)
    n_tokens      = length(tokens)

    @inbounds for i in eachindex(tokens)
        # skip inactive
        is_active[i] || continue

        opening = token_name(tokens[i])

        # do we potentially have a paragraph break or something that may
        # start a line-block (blockquote candidate etc)
        if opening ∉ template_keys
            if check_newline && (opening ∈ (:newline, :sos))
                process_newline!(
                    blocks,
                    tokens,
                    i,
                    is_active
                )
            end
            continue
        end

        # template for the closing token
        template = templates[opening]
        closing  = template.closing
        nesting  = template.nesting

        # short path for e.g. html entities
        if closing === NO_CLOSING
            push!(blocks, TokenBlock(tokens, i))
            continue
        end

        # try to find the closing token keeping potential nesting in mind
        closing_index = -1
        open_depth    = 1
        for j in i+1:n_tokens
            # the tokens ahead might be inactive due to first pass
            is_active[j] || continue
            candidate = token_name(tokens[j])
            # has to happen before opener to avoid ambiguity in emphasis tokens
            if candidate in closing
                open_depth -= 1
            elseif candidate == opening && nesting
                open_depth += 1
            end
            if open_depth == 0
                closing_index = j
                break
            end
        end

        # if the block isn't closed, complain unless this is tolerated.
        if (closing_index == -1)
            opening ∈ CAN_BE_LEFT_OPEN || block_not_closed_exception(tokens[i])
            continue
        end

        # now we have a block that is properly closed, push it on the stack
        # and deactivate relevant tokens
        push!(blocks,
            Block{case}(
                template.name,
                s,
                @view tokens[i:closing_index]
            )
        )

        # for blocks that end with a line return, do not deactivate
        # that line return which might e.g. lead to the start of an item
        # see process_line_returns
        last_token    = tokens[closing_index]
        to_deactivate = i:(closing_index - (token_name(last_token) == :newline))

        # deactivate all tokens in the span of the block
        is_active[to_deactivate] .= false
        append!(
            deactivated_tokens,
            collect(to_deactivate)
        )
    end
    return deactivated_tokens
end
