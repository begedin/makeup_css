## Readme

A Makeup lexer for CSS

 
## Installation

The package can be installed by adding `makeup` and `makeup_css` in `mix.exs`:

```elixir
def deps do
  [
    {:makeup, "x.y.z"},
    {:makeup_elixir, "x.y.z"}
  ]
end
```

Documentation can be found at https://hexdocs.pm/makeup_css.

## Changes

Refer to the [Changelog](CHANGELOG.md).

## Quickstart

Adding the library will make the lexer application for CSS start automatically. At that point, you can call 

```elixir
Makeup.highlight("""
.some-css {
  color: red;
}

#id-selector {
  background: none;
}

/* etc. */
""")
```

To get the stylesheet, just 

```elixir
Makeup.stylesheet(style) # by default, the StyleMap.default style is used.
```

Basically, use makeup as normal, but you can pass in CSS now.

### Usage with NimblePublisher

If you have a NimblePublisher-powered blog, you just have to tweak your markdown parsing settings:

```elixir
use NimblePublisher
  build: MyApp.Blog.Post,
  from: Application.app_dir(:my_app, "priv/blog/**/*.md"),
  as: :posts,
  # ts and css added
  highlighters: [:makeup_elixir, :makeup_ts, :makeup_css]
```

Now, any code block declared as containing CSS should be highlighted.

## Current state

This is very much a work-in-progress, but it higlights your CSS in a useful way. It may or may not support SCSS in the future.

Contributions are welcome.