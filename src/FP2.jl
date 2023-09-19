module FP2

import REPL.REPLCompletions: emoji_symbols
import Base.isempty

using Automa

include("types.jl")

include("tokens/rules.jl")
include("tokens/find_tokens.jl")

include("blocks/rules.jl")
include("blocks/utils.jl")
include("blocks/find_utils.jl")
include("blocks/find_blocks.jl")

end # module FP2
