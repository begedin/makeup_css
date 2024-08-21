defmodule MakeupCss.Lexer do
  import Makeup.Lexer.Combinators
  import Makeup.Lexer.Groups
  import NimbleParsec

  @behaviour Makeup.Lexer

  ###################################################################
  # Step #1: tokenize the input (into a list of tokens)
  ###################################################################

  any_char = [] |> utf8_char() |> token(:error)

  whitespace = [?\r, ?\s, ?\n, ?\f] |> ascii_string(min: 1) |> token(:whitespace)

  # Numbers
  digits = ascii_string([?0..?9], min: 1)
  integer = digits

  # Tokens for the lexer
  # Base 10
  number_integer = token(integer, :number_integer)

  # Floating point numbers
  float_scientific_notation_part =
    [?e, ?E]
    |> ascii_string(1)
    |> optional(string("-"))
    |> concat(integer)

  number_float =
    integer
    |> string(".")
    |> concat(integer)
    |> optional(float_scientific_notation_part)
    |> token(:number_float)

  property =
    "--"
    |> string()
    |> optional()
    |> concat(ascii_string([?a..?z], min: 1))
    |> optional(repeat(concat(ascii_char([?-]), ascii_string([?a..?z], min: 1))))
    |> string(":")
    |> token(:keyword_constant)

  class_selector =
    [?.]
    |> ascii_char()
    |> concat(ascii_string([?_, ?0..?9, ?A..?Z, ?a..?z], min: 1))
    |> token(:name_class)

  id_selector =
    [?#]
    |> ascii_char()
    |> concat(ascii_string([?_, ?0..?9, ?A..?Z, ?a..?z], min: 1))
    |> token(:name_constant)

  pseudo_selector =
    ":"
    |> string()
    |> optional(string(":"))
    |> concat(ascii_string([?-, ?0..?9, ?A..?Z, ?a..?z], min: 1))
    |> token(:name_constant)

  tag_selector =
    choice([ascii_string([?A..?Z, ?a..?z], min: 1), string("*")])
    |> lookahead_not(string(": "))
    |> token(:name_builtin)

  attribute_name_or_value =
    [?0..?9, ?a..?z, ?A..?Z]
    |> ascii_string(min: 1)
    |> optional(
      repeat(concat(ascii_char([?_, ?-]), ascii_string([?0..?9, ?a..?z, ?A..?Z], min: 1)))
    )

  attribute_operator = word_from_list(~w(~= |= ^= $= *= =))

  attribute_selector =
    string("[")
    |> concat(attribute_name_or_value)
    |> optional(
      choice([
        concat(attribute_operator, attribute_name_or_value),
        attribute_operator
        |> concat(string("'") |> concat(attribute_name_or_value) |> concat(string("'")))
      ])
    )
    |> concat(string("]"))
    |> token(:name_attribute)

  operator_name = word_from_list(~W(+ -  * / % ++ -- ~ ^ & && | || ! : >))
  operator = token(operator_name, :operator)

  normal_char =
    "?"
    |> string()
    |> utf8_string([], 1)
    |> token(:string_char)

  escape_char =
    "?\\"
    |> string()
    |> utf8_string([], 1)
    |> token(:string_char)

  punctuation = word_from_list(["\\\\", ";", ",", "."], :punctuation)

  delimiters_punctuation = word_from_list(~W| ( ) [ ] { } < >|, :punctuation)

  unicode_char_in_string =
    "\\u"
    |> string()
    |> ascii_string([?0..?9, ?a..?f, ?A..?F], 4)
    |> token(:string_escape)

  escaped_char = "\\" |> string() |> utf8_string([], 1) |> token(:string_escape)

  combinators_inside_string = [unicode_char_in_string, escaped_char]

  double_quoted_string = string_like("\"", "\"", combinators_inside_string, :string)
  single_quoted_string = string_like("'", "'", combinators_inside_string, :string)

  comment = string_like("/*", "*/", combinators_inside_string, :comment)

  units = word_from_list(~w(cm mm in px pt pc em ex ch rem vw vh vmin vmax %))

  length =
    integer
    |> optional(concat(string("."), integer))
    |> concat(units)
    |> token(:number_integer)

  keywords = string("important") |> token(:keyword_type)

  functions =
    ~w"""
    calc
    min max clamp
    round mod rem
    sin cos tan asin ascos atan atan2
    pow sqrt hypot log exp
    abs sign
    blur brightness contrast drop-shadow grayscale hue-rotate invert opacity saturate sepia
    rgb hsl hwb lch oklch lab oklab color color-mix color-contrast device-cmyk light-dark
    linear-gradient radial-gradient conic-gradient
    repeating-linear-gradient repeating-radial-gradient repeating-conic-gradient
    image image-set cross-fade element paint
    counter counters symbols
    circle ellipse inset rect xywh polygon path shape
    attr env url var
    fit-content minmax repeat
    stylistic styleset character-variant swash ornaments orientation
    linear cubic-bezier steps
    scroll view
    anchor anchor-size
    translateX translateY translateZ translate translate3d
    rotateX rotateY rotateZ rotate rotate3d
    scaleX scaleY scaleZ scale scale3d
    skewX skewY skew
    matrix matrix3d
    perspective
    """
    |> word_from_list()
    |> lookahead(string("("))
    |> token(:name_function)

  at_rules =
    "@"
    |> string()
    |> concat(ascii_string([?a..?z, ?-], min: 3))
    |> token(:keyword_type)

  root_element_combinator =
    choice([
      whitespace,
      # Comments
      comment,
      # Strings
      single_quoted_string,
      double_quoted_string,
      length,

      # keywords and reserved
      at_rules,
      keywords,
      functions,

      # selectors
      pseudo_selector,
      class_selector,
      id_selector,
      attribute_selector,
      tag_selector,

      # rule
      property,

      # Chars
      escape_char,
      normal_char,
      # Delimiter pairs
      delimiters_punctuation,
      comment,
      # Operators
      operator,
      # Numbers
      # Floats must come before integers
      number_float,
      number_integer,
      punctuation,
      # If we can't parse any of the above, we highlight the next character as an error
      # and proceed from there.
      # A lexer should always consume any string given as input.
      any_char
    ])

  # By default, don't inline the lexers.
  # Inlining them increases performance by ~20%
  # at the cost of doubling the compilation times...
  @inline false

  @doc false
  def __as_css_language__({ttype, meta, value}) do
    {ttype, Map.put(meta, :language, :css), value}
  end

  # Semi-public API: these two functions can be used by someone who wants to
  # embed an Elixir lexer into another lexer, but other than that, they are not
  # meant to be used by end-users.

  # @impl Makeup.Lexer
  defparsec(:root_element, map(root_element_combinator, {__MODULE__, :__as_css_language__, []}),
    inline: @inline
  )

  # @impl Makeup.Lexer
  defparsec(:root, repeat(parsec(:root_element)), inline: @inline)

  ###################################################################
  # Step #2: postprocess the list of tokens
  ###################################################################

  @impl Makeup.Lexer
  def postprocess(tokens, _opts \\ []), do: postprocess_helper(tokens)

  defp postprocess_helper([]), do: []

  # Otherwise, don't do anything with the current token and go to the next token.
  defp postprocess_helper([token | tokens]) do
    [token | postprocess_helper(tokens)]
  end

  ###################################################################
  # Step #3: highlight matching delimiters
  ###################################################################

  @impl Makeup.Lexer
  defgroupmatcher(:match_groups,
    parentheses: [
      open: [[{:punctuation, %{language: :ts}, "("}]],
      close: [[{:punctuation, %{language: :ts}, ")"}]]
    ],
    list: [
      open: [[{:punctuation, %{language: :ts}, "["}]],
      close: [[{:punctuation, %{language: :ts}, "]"}]]
    ],
    curly: [
      open: [[{:punctuation, %{language: :ts}, "{"}]],
      close: [[{:punctuation, %{language: :ts}, "}"}]]
    ],
    cast: [
      open: [[{:punctuation, %{language: :ts}, "<"}]],
      close: [[{:punctuation, %{language: :ts}, ">"}]]
    ]
  )

  @impl Makeup.Lexer
  def lex(text, opts \\ []) do
    group_prefix = Keyword.get(opts, :group_prefix, random_prefix(10))
    {:ok, tokens, "", _, _, _} = root(text)

    tokens
    |> postprocess([])
    |> match_groups(group_prefix)
  end
end
