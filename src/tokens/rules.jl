const MD_TOKENS_MAP = [
    # Links related
    :lparen       => re"\(",
    :rparen       => re"\)",
    :lbracket     => re"\[",
    :lbracket_img => re"!\[",
    :rbracket     => re"]",
    :rbracket_ref => re"]:",
    :autolink     => re"<[^!][^\t >]+>",  # this is lazy, could try to be stricter

    # Latex-like
    :lbrace    => re"{",
    :rbrace    => re"}",
    :lxcom     => re"\\[a-zA-Z][a-zA-Z_0-9]*",
    :linebreak => re"\\\\",

    # Math related
    :mathi  => re"$",
    :mathd  => re"$$",
    :lmathd => re"\\\[",
    :rmathd => re"\\]",

    # Inputs
    :rawinput  => re"\?\?\?",
    :htmlinput => re"~~~",
    :lxinput   => re"%%%",
    :lcomment  => re"<!--",
    :rcomment  => re"-->",

    # Mddefs
    :mddef  => re"\+\+\+\r?\n",
    :mddefi => re"@def[ \t]",

    # Divs
    :ldiv => re"@@[a-zA-Z][a-zA-Z0-9\-_,:/]*",
    :rdiv => re"@@",

    # Headers
    :h6 => re"######[ \t]",
    :h5 => re"#####[ \t]",
    :h4 => re"####[ \t]",
    :h3 => re"###[ \t]",
    :h2 => re"##[ \t]",
    :h1 => re"#[ \t]",

    # Emphasis
    :em_strong_a => re"___",
    :strong_a    => re"__",
    :em_a        => re"_",
    :em_strong_b => re"\*\*\*",
    :strong_b    => re"\*\*",
    :em_b        => re"\*",

    # Code
    :code5  => re"`````",
    :code4  => re"````",
    :code3  => re"```",
    :code2  => re"``",
    :code1  => re"`",

    # Misc
    :pipe    => re"\|",
    :emoji   => re":[a-zA-Z0-9\+\-_]+:",
    :newline => re"\r?\n",

    # Special chars
    :char_42  => re"\\\*",
    :char_95  => re"\\_",
    :char_96  => re"\\`",
    :char_64  => re"\\@",
    :char_35  => re"\\#",
    :char_123 => re"\\{",
    :char_125 => re"\\}",
    :char_36  => re"\\$",
    :char_126 => re"\\~",
    :char_33  => re"\\!",
    :char_37  => re"\\%",
    :char_38  => re"\\&",
    :char_63  => re"\\\?",
    :char_124 => re"\\\|",

    # Html entity (still requires a validator after)
    :entity   => re"&[a-zA-Z]+[0-9]*;" | re"&#[0-9]+;" | re"&#x[0-9a-f]+;",
]


const HTML_TOKENS_MAP = [
    :ldbrace => re"{{",
    :rdbrace => re"}}",

    :lcomment  => re"<!--",
    :rcomment  => re"-->",

    :lmathi => re"\\\(",
    :rmathi => re"\\\)",
    :lmathd => re"\\\[",
    :rmathd => re"\\]",

    :lscript => re"<script>",
    :rscript => re"</script>",
]


const ARGS_TOKENS_MAP = [
    :triple_quote => re"\"\"\"",
    :single_quote => re"\""
]
