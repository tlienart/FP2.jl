"""
    process_newline!(blocks, tokens, i)

Process a line return followed by any number of white spaces and one or more
characters. Depending on these characters, it will lead to a different
interpretation and an update of the token.

if the next non-space character(s) is/are:

* another lret      --> interpret as paragraph break (double line skip)
* two -,* or _      --> a hrule that will need to be validated later
* one *, +, -, etc. --> an item candidate
* |                 --> table row candidate
* >                 --> a blockquote (startswith >).

We disambiguate the different cases based on the **two** characters after the
whitespaces of the line return (the line return token captures `\n[ \t]*`).
"""
function process_line_return!(
            blocks::Vector{Block},
            tokens::Vector{Token},
            i::Int,
            is_active::Vector{Bool}
        )::Nothing

    t = tokens[i]
    N = length(tokens)
    #
    # We base the analysis on the two chars immediately following the token
    # (ignoring whitespaces) with one special cases: if t is near EOS; in that
    # case there may not be two chars (`c` below will be empty in that
    # situation).
    #
    t_is_sos        = is_sos(t)
    t_is_sos_and_lr = false
    if t_is_sos
        if first(t.ss) == '\n'
            c = next_chars(t, 2)
            t_is_sos_and_lr = true
        else
            c = [first(t.ss), next_chars(t, 1)...]
        end
    else
        c = next_chars(t, 2)
    end

    #
    # If there isn't two chars beyond the token, `c` will be empty.
    # This is the case if we're at the end of the string so there's nothing
    # to do. Likewise, if the second character is EOS, then we don't care
    # and skip (and deactivate all tokens in range).
    #
    if (length(c) < 2) || c[2] == EOS
        is_active[i:end] .= false

    #
    # If the immediate next character is a line return, then we have a
    # double \n\n -> line skip; this also means that the immediate next
    # token is a LINE_RETURN which we can deactivate.
    #
    elseif c[1] == '\n'
        push!(blocks,
            Block(
                :P_BREAK,
                @view tokens[i:i+1]
            )
        )
        # we only mark the base line return as inactive as the next one may
        # trigger something else such as an item (e.g. \n\n* foo\n)
        is_active[i] = false
        t_is_sos && (is_active[i+1] = false)

    else
        # 
        # We're now in a situation where the span between the token and
        # the next LINE_RETURN (or EOS) will form the block.
        #
        #   - hrule (---, ***, ___)
        #   - item starter (+ ..., - ..., * ...)
        #   - table row ( | ... )
        #   - block quote 
        #
        # if this is validated, we mark all tokens between the first line
        # return (included) and the next one (not-included *) as inactive.
        # (*) see comment above with only marking token[i] is inactive.
        # 
        j = i+1+Int(t_is_sos_and_lr)
        while j < N && name(tokens[j]) ∉ (:LINE_RETURN, :EOS)
            j += 1
        end
        next_line_return = tokens[min(j, N)]
        # in the standard case of a line return, take string until the char
        # that precedes it. However, in the case of EOS, need to take the
        # string until the end.
        eol = ifelse(
            is_eos(next_line_return),
            from(next_line_return),
            prev_index(next_line_return)
        )
        rge  = ifelse(t_is_sos, from(t):eol, next_index(t):eol)
        line = subs(parent_string(t), rge)

        bpush! = name -> begin
            push!(blocks, Block(
                name,
                line,
                @view tokens[i+1:j]
            ))
            is_active[i:j-1] .= false
        end

        # HRULE
        if c[1] == c[2] && c[1] ∈ ('-', '_', '*')
            check = match(HR_PAT, line)
            isnothing(check) || bpush!(:HRULE)

        # ITEM STARTER (UN-ORDERED)
        elseif (c[1] in ('+', '-', '*')) && (c[2] in (' ', '\t'))
            bpush!(:ITEM_U_CAND)

        # ITEM STARTER (ORDERED)
        elseif (c[1] ∈ NUM_CHAR) && (c[2] in vcat(NUM_CHAR, ['.', ')']))
            check = match(OL_ITEM_PAT, line)
            isnothing(check) || bpush!(:ITEM_O_CAND)
 
        # BLOCKQUOTE
        elseif c[1] == '>'
            bpush!(:BLOCKQUOTE_LINE)

        # TABLE ROW (must be last because requires a check in the if)
        elseif !isnothing(match(ROW_CAND_PAT, line))
            bpush!(:TABLE_ROW_CAND)

        end
    end
    return
end
