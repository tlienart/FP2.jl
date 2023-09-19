const ARGS_BLOCKS = Dict{Symbol,BT}(
    e.opening => e for e in [
        BT(:string, :single_quote),
        BT(:string, :triple_quote),
    ]
)

const HTML_BLOCKS = Dict{Symbol, BT}(
   e.opening => e for e in [
        BT(:comment, :lcomment, :rcomment),
        BT(:script,  :lscript,  :rscript),
        BT(:dbb,     :ldbrace,  :rdbrace),
        BT(:mathi,   :lmathi,   :rmathi),
        BT(:mathd,   :lmathd,   :rmathd),
    ]
)


const END_OF_LINE = (:newline, :eos)

#
# Can contain anything including malformed blocks (which is why it's done first)
#
const MD_BLOCKS_RAW = Dict{Symbol, BT}(
    e.opening => e for e in [
        BT(:rawinput, :rawinput, :rawinput)
    ]
)

const MD_BLOCKS_CONTAINERS = Dict{Symbol, BT}(
    e.opening => e for e in [
        # basic
        BT(:comment, :lcomment, :rcomment),
        BT(:htmlinput),
        BT(:lxinput),
        BT(:mddef),
        # inline def
        BT(:mddefi, :mddefi, END_OF_LINE),
        # code
        BT(:code5),
        BT(:code4),
        BT(:code3),
        BT(:code2),
        BT(:code1),
        # math
        BT(:mathi),
        BT(:mathd),
        BT(:mathd_b, :lmathd, :rmathd),
    ]
)


# const MD_BLOCKS = Dict{Symbol, BlockTemplate}(e.opening => e for e in [

   
   #
#    BT(:EMPH_EM,        :EM_OPEN,        (:EM_CLOSE,        :EM_MX        ), nesting=true),
#    BT(:EMPH_EM,        :EM_MX,          (:EM_CLOSE,        :EM_MX        ), nesting=true),
#    BT(:EMPH_STRONG,    :STRONG_OPEN,    (:STRONG_CLOSE,    :STRONG_MX    ), nesting=true),
#    BT(:EMPH_STRONG,    :STRONG_MX,      (:STRONG_CLOSE,    :STRONG_MX    ), nesting=true),
#    BT(:EMPH_EM_STRONG, :EM_STRONG_OPEN, (:EM_STRONG_CLOSE, :EM_STRONG_MX ), nesting=true),
#    BT(:EMPH_EM_STRONG, :EM_STRONG_MX,   (:EM_STRONG_CLOSE, :EM_STRONG_MX ), nesting=true),
#    #
#    BT(:AUTOLINK,        :AUTOLINK_OPEN,  :AUTOLINK_CLOSE ),
#    # these blocks are disabled in find_blocks if they're not attached in
#    # a link/img/... context
#    BT(:BRACKETS,    :BRACKET_OPEN,    :BRACKET_CLOSE,    nesting=true),
#    BT(:SQ_BRACKETS, :SQ_BRACKET_OPEN, :SQ_BRACKET_CLOSE, nesting=true),
#    # code
#    BT(:CODE_BLOCK,      :CODE_PENTA,   :CODE_PENTA  ),
#    BT(:CODE_BLOCK,      :CODE_QUAD,    :CODE_QUAD   ),
#    BT(:CODE_BLOCK,      :CODE_TRIPLE,  :CODE_TRIPLE ),
#    BT(:CODE_INLINE,     :CODE_DOUBLE,  :CODE_DOUBLE ),
#    BT(:CODE_INLINE,     :CODE_SINGLE,  :CODE_SINGLE ),
#    # maths
#    BT(:MATH_INLINE,  :MATH_INLINE,       :MATH_INLINE        ),
#    BT(:MATH_DISPL_A, :MATH_DISPL_A,      :MATH_DISPL_A       ),
#    BT(:MATH_DISPL_B, :MATH_DISPL_B_OPEN, :MATH_DISPL_B_CLOSE ),
#    # md def one line
#    BT(:MD_DEF, :MD_DEF_OPEN, END_OF_LINE ),
#    # div and braces
#    BT(:DIV,         :DIV_OPEN, :DIV_CLOSE,               nesting=true),
#    BT(:CU_BRACKETS, :CU_BRACKET_OPEN, :CU_BRACKET_CLOSE, nesting=true),
#    # headers
#    BT(:H1, :H1_OPEN, END_OF_LINE ),
#    BT(:H2, :H2_OPEN, END_OF_LINE ),
#    BT(:H3, :H3_OPEN, END_OF_LINE ),
#    BT(:H4, :H4_OPEN, END_OF_LINE ),
#    BT(:H5, :H5_OPEN, END_OF_LINE ),
#    BT(:H6, :H6_OPEN, END_OF_LINE ),
#    # Direct blocks
#    SingleTokenBT(:LINEBREAK ),
#    SingleTokenBT(:HRULE     ),
#    # Direct blocks -- latex objects
#    SingleTokenBT(:LX_NEWENVIRONMENT ),
#    SingleTokenBT(:LX_NEWCOMMAND     ),
#    SingleTokenBT(:LX_COMMAND        ),
#    SingleTokenBT(:LX_BEGIN          ),
#    SingleTokenBT(:LX_END            )
#    ])
